import { cleanup, render, screen, waitFor } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import App from './App';

vi.mock('./auth', () => ({
  adminUserManager: {
    getUser: vi.fn().mockResolvedValue({ access_token: 'synthetic-test-token', profile: { name: 'Synthetic admin' } }),
    signinRedirectCallback: vi.fn(),
    signoutRedirect: vi.fn(),
    signinRedirect: vi.fn(),
  },
  oidcConfigured: vi.fn().mockReturnValue(true),
}));

describe('POI media audit controls', () => {
  beforeEach(() => {
    vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL) => {
      const url = String(input);
      const body = url.includes('/api/v1/admin/records') || url.includes('/api/v1/admin/destination-records')
        || url.includes('/api/v1/admin/destination-poi-relationships')
        ? { content: [], page: 0, size: 50, totalElements: 0 }
        : [];
      return new Response(JSON.stringify(body), { status: 200, headers: { 'Content-Type': 'application/json' } });
    }));
  });

  afterEach(() => {
    cleanup();
    vi.unstubAllGlobals();
  });

  it('exposes an independent audit reason when no editorial record is selected', async () => {
    render(<App />);

    const reason = await screen.findByLabelText('Razón de auditoría de media');
    await waitFor(() => expect(screen.getByRole('heading', { name: 'Media privada del POI' })).toBeTruthy());

    expect(reason).toBeTruthy();
    expect(screen.queryByLabelText('Razón de auditoría')).toBeNull();
    expect(screen.getByText('1 / 1')).toBeTruthy();
  });
});
