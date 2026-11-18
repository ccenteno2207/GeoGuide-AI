import { UserManager, WebStorageStateStore } from 'oidc-client-ts';

export type OidcEnvironment = {
  authority?: string;
  clientId?: string;
  scope?: string;
};

export function oidcConfigured(env: OidcEnvironment): boolean {
  return Boolean(env.authority?.trim() && env.clientId?.trim());
}

export function createUserManager(env: OidcEnvironment): UserManager | null {
  if (!oidcConfigured(env)) return null;
  return new UserManager({
    authority: env.authority!.trim(),
    client_id: env.clientId!.trim(),
    redirect_uri: `${window.location.origin}/auth/callback`,
    post_logout_redirect_uri: window.location.origin,
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
