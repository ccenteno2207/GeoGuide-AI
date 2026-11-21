import { describe, expect, it } from 'vitest';
import { getValidAccessToken, oidcConfigured, oidcRedirectUris } from './auth';

describe('OIDC startup gate', () => {
  it('keeps administrative access unavailable without an authority and client id', () => {
    expect(oidcConfigured({})).toBe(false);
    expect(oidcConfigured({ authority: 'https://issuer.example', clientId: ' ' })).toBe(false);
  });

  it('accepts a provisioned standard OIDC authority and public client id', () => {
    expect(oidcConfigured({ authority: 'https://issuer.example', clientId: 'geoguide-admin' })).toBe(true);
  });

  it('keeps the PKCE callback under the deployed admin base path', () => {
    expect(oidcRedirectUris('https://example.test:5443', '/admin/')).toEqual({
      redirectUri: 'https://example.test:5443/admin/auth/callback',
      silentRedirectUri: 'https://example.test:5443/admin/auth/silent-callback',
      postLogoutRedirectUri: 'https://example.test:5443/admin/',
    });
  });

  it('renews a token before expiry and uses the renewed access token', async () => {
    const manager = {
      getUser: async () => ({ access_token: 'old', expires_at: 1_050 }),
      signinSilent: async () => ({ access_token: 'fresh', expires_at: 1_600 }),
    };
    await expect(getValidAccessToken(manager, 1_000)).resolves.toBe('fresh');
  });

  it('does not return an expired token when silent renewal fails', async () => {
    const manager = {
      getUser: async () => ({ access_token: 'expired', expires_at: 900 }),
      signinSilent: async () => { throw new Error('OIDC session unavailable'); },
    };
    await expect(getValidAccessToken(manager, 1_000)).resolves.toBeNull();
  });

  it('fails closed and renews when token expiry metadata is missing', async () => {
    const manager = {
      getUser: async () => ({ access_token: 'unknown-expiry' }),
      signinSilent: async () => ({ access_token: 'fresh', expires_at: 1_600 }),
    };
    await expect(getValidAccessToken(manager, 1_000)).resolves.toBe('fresh');
  });
});
