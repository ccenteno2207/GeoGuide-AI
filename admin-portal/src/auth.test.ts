import { describe, expect, it } from 'vitest';
import { oidcConfigured, oidcRedirectUris } from './auth';

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
      postLogoutRedirectUri: 'https://example.test:5443/admin/',
    });
  });
});
