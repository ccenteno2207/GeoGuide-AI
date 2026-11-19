import { UserManager, WebStorageStateStore } from 'oidc-client-ts';

export type OidcEnvironment = {
  authority?: string;
  clientId?: string;
  scope?: string;
};

export function oidcConfigured(env: OidcEnvironment): boolean {
  return Boolean(env.authority?.trim() && env.clientId?.trim());
}

export function oidcRedirectUris(origin: string, baseUrl: string): { redirectUri: string; postLogoutRedirectUri: string } {
  const basePath = baseUrl.endsWith('/') ? baseUrl : `${baseUrl}/`;
  return { redirectUri: `${origin}${basePath}auth/callback`, postLogoutRedirectUri: `${origin}${basePath}` };
}

export function createUserManager(env: OidcEnvironment): UserManager | null {
  if (!oidcConfigured(env)) return null;
  const redirects = oidcRedirectUris(window.location.origin, import.meta.env.BASE_URL);
  return new UserManager({
    authority: env.authority!.trim(),
    client_id: env.clientId!.trim(),
    redirect_uri: redirects.redirectUri,
    post_logout_redirect_uri: redirects.postLogoutRedirectUri,
    response_type: 'code',
    disablePKCE: false,
    scope: env.scope?.trim() || 'openid profile',
    userStore: new WebStorageStateStore({ store: window.sessionStorage }),
    stateStore: new WebStorageStateStore({ store: window.sessionStorage }),
    automaticSilentRenew: false,
    monitorSession: false,
    loadUserInfo: false,
  });
}

export const adminUserManager = createUserManager({
  authority: import.meta.env.VITE_OIDC_AUTHORITY,
  clientId: import.meta.env.VITE_OIDC_CLIENT_ID,
  scope: import.meta.env.VITE_OIDC_SCOPE,
});
