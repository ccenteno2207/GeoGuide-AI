import { UserManager, WebStorageStateStore } from 'oidc-client-ts';

export type OidcEnvironment = {
  authority?: string;
  clientId?: string;
  scope?: string;
};

export function oidcConfigured(env: OidcEnvironment): boolean {
  return Boolean(env.authority?.trim() && env.clientId?.trim());
}

export function oidcRedirectUris(origin: string, baseUrl: string): { redirectUri: string; silentRedirectUri: string; postLogoutRedirectUri: string } {
  const basePath = baseUrl.endsWith('/') ? baseUrl : `${baseUrl}/`;
  return {
    redirectUri: `${origin}${basePath}auth/callback`,
    silentRedirectUri: `${origin}${basePath}auth/silent-callback`,
    postLogoutRedirectUri: `${origin}${basePath}`,
  };
}

export type OidcTokenUser = { access_token: string; expires_at?: number; expired?: boolean };
export type OidcTokenManager = {
  getUser(): Promise<OidcTokenUser | null>;
  signinSilent(): Promise<OidcTokenUser | null>;
};

const TOKEN_REFRESH_SKEW_SECONDS = 60;
let silentRenewal: Promise<string | null> | null = null;

function renewOnce(manager: OidcTokenManager, nowSeconds = Math.floor(Date.now() / 1000)): Promise<string | null> {
  if (silentRenewal) return silentRenewal;
  silentRenewal = (async () => {
    try {
      const renewed = await manager.signinSilent();
      return renewed?.access_token && (renewed.expires_at ?? 0) > nowSeconds + 5
        ? renewed.access_token
        : null;
    } catch {
      return null;
    } finally {
      silentRenewal = null;
    }
  })();
  return silentRenewal;
}

export async function getValidAccessToken(
  manager: OidcTokenManager | null,
  nowSeconds = Math.floor(Date.now() / 1000),
): Promise<string | null> {
  if (!manager) return null;
  const user = await manager.getUser();
  if (!user) return null;
  const expiresAt = user.expires_at ?? 0;
  if (expiresAt > nowSeconds + TOKEN_REFRESH_SKEW_SECONDS) return user.access_token;

  try {
    const renewed = await renewOnce(manager, nowSeconds);
    if (renewed) return renewed;
  } catch {
    // Keep the failure local to this API call; callers can ask the user to sign in again.
  }

  if (expiresAt > nowSeconds + 5) return user.access_token;
  return null;
}

export async function renewAccessToken(manager: OidcTokenManager | null): Promise<string | null> {
  if (!manager) return null;
  return renewOnce(manager);
}

export function createUserManager(env: OidcEnvironment): UserManager | null {
  if (!oidcConfigured(env)) return null;
  const redirects = oidcRedirectUris(window.location.origin, import.meta.env.BASE_URL);
  return new UserManager({
    authority: env.authority!.trim(),
    client_id: env.clientId!.trim(),
    redirect_uri: redirects.redirectUri,
    silent_redirect_uri: redirects.silentRedirectUri,
    post_logout_redirect_uri: redirects.postLogoutRedirectUri,
    response_type: 'code',
    disablePKCE: false,
    scope: env.scope?.trim() || 'openid profile',
    userStore: new WebStorageStateStore({ store: window.sessionStorage }),
    stateStore: new WebStorageStateStore({ store: window.sessionStorage }),
    // API calls coordinate proactive renewal through getValidAccessToken;
    // avoid racing the OIDC timer against concurrent requests.
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
