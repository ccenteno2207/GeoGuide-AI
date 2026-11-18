import { describe, expect, it } from 'vitest';
import { oidcConfigured } from './auth';

describe('OIDC startup gate', () => {
  it('keeps administrative access unavailable without an authority and client id', () => {
    expect(oidcConfigured({})).toBe(false);
    expect(oidcConfigured({ authority: 'https://issuer.example', clientId: ' ' })).toBe(false);
  });

  it('accepts a provisioned standard OIDC authority and public client id', () => {
    expect(oidcConfigured({ authority: 'https://issuer.example', clientId: 'geoguide-admin' })).toBe(true);
  });
});
