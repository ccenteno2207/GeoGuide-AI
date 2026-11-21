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

  it('never replays a mutation automatically after 401', async () => {
    const fetchMock = vi.fn().mockResolvedValue(new Response('expired', { status: 401 }));
    vi.stubGlobal('fetch', fetchMock);
    const api = new AdminApi({ baseUrl: '', getToken: async () => 'old-token', renewToken: async () => 'new-token' });

    await expect(api.post('/api/v1/admin/pois/test/activation', {})).rejects.toThrow('no se repitió automáticamente');
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });
});
