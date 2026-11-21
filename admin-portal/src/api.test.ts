import { afterEach, describe, expect, it, vi } from 'vitest';
import { AdminApi } from './api';

afterEach(() => vi.unstubAllGlobals());

describe('AdminApi token recovery', () => {
  it('reports an expired local session as recoverable without signing out first', async () => {
    const api = new AdminApi({ baseUrl: '', getToken: async () => null, renewToken: async () => null });
    await expect(api.get('/api/v1/admin/pois')).rejects.toThrow('API 401: No hay una sesión utilizable');
  });

  it('renews once and retries an idempotent GET after 401', async () => {
    const fetchMock = vi.fn()
      .mockResolvedValueOnce(new Response('expired', { status: 401 }))
      .mockResolvedValueOnce(new Response(JSON.stringify({ content: [] }), { status: 200 }));
    vi.stubGlobal('fetch', fetchMock);
    const api = new AdminApi({ baseUrl: '', getToken: async () => 'old-token', renewToken: async () => 'new-token' });

    await expect(api.get('/api/v1/admin/pois')).resolves.toEqual({ content: [] });
    expect(fetchMock).toHaveBeenCalledTimes(2);
    expect(fetchMock.mock.calls[0][1]?.headers).toMatchObject({ Authorization: 'Bearer old-token' });
    expect(fetchMock.mock.calls[1][1]?.headers).toMatchObject({ Authorization: 'Bearer new-token' });
  });

  it('uses a token refreshed concurrently when silent renewal returns the current token', async () => {
    const fetchMock = vi.fn()
      .mockResolvedValueOnce(new Response('expired', { status: 401 }))
      .mockResolvedValueOnce(new Response(JSON.stringify({ content: [] }), { status: 200 }));
    vi.stubGlobal('fetch', fetchMock);
    let tokenRead = 0;
    const api = new AdminApi({
      baseUrl: '',
      getToken: async () => (++tokenRead === 1 ? 'old-token' : 'fresh-token'),
      renewToken: async () => 'old-token',
    });

    await expect(api.get('/api/v1/admin/pois')).resolves.toEqual({ content: [] });
    expect(fetchMock).toHaveBeenCalledTimes(2);
    expect(fetchMock.mock.calls[1][1]?.headers).toMatchObject({ Authorization: 'Bearer fresh-token' });
  });

  it('does not retry a safe GET more than once after session renewal', async () => {
    const fetchMock = vi.fn().mockResolvedValue(new Response('expired', { status: 401 }));
    vi.stubGlobal('fetch', fetchMock);
    const api = new AdminApi({ baseUrl: '', getToken: async () => 'old-token', renewToken: async () => 'new-token' });

    await expect(api.get('/api/v1/admin/pois')).rejects.toThrow('sigue sin autorización');
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it('never replays a mutation automatically after 401', async () => {
    const fetchMock = vi.fn().mockResolvedValue(new Response('expired', { status: 401 }));
    vi.stubGlobal('fetch', fetchMock);
    const api = new AdminApi({ baseUrl: '', getToken: async () => 'old-token', renewToken: async () => 'new-token' });

    await expect(api.post('/api/v1/admin/pois/test/activation', {})).rejects.toThrow('no se repitió automáticamente');
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it('renews and retries an image GET at most once after 401', async () => {
    const fetchMock = vi.fn()
      .mockResolvedValueOnce(new Response('expired', { status: 401 }))
      .mockResolvedValueOnce(new Response(new Blob(['synthetic-image']), { status: 200 }));
    vi.stubGlobal('fetch', fetchMock);
    const api = new AdminApi({ baseUrl: '', getToken: async () => 'old-token', renewToken: async () => 'new-token' });

    await expect(api.getBlob('/api/v1/admin/media/asset/content')).resolves.toBeInstanceOf(Blob);
    expect(fetchMock).toHaveBeenCalledTimes(2);
    expect(fetchMock.mock.calls[1][1]?.headers).toMatchObject({ Authorization: 'Bearer new-token' });
  });

  it('does not loop when a refreshed image GET is still unauthorized', async () => {
    const fetchMock = vi.fn().mockResolvedValue(new Response('expired', { status: 401 }));
    vi.stubGlobal('fetch', fetchMock);
    const api = new AdminApi({ baseUrl: '', getToken: async () => 'old-token', renewToken: async () => 'new-token' });

    await expect(api.getBlob('/api/v1/admin/media/asset/content')).rejects.toThrow('sigue sin autorización');
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });
});
