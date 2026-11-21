export type ApiConfig = { baseUrl: string; getToken: () => Promise<string | null>; renewToken?: () => Promise<string | null> };
export type ApiFieldError = { field: string; code: string; message: string };
export class AdminApiError extends Error {
  constructor(readonly status: number, readonly code: string, message: string, readonly fieldErrors: ApiFieldError[] = [], readonly requestId?: string) {
    super(message); this.name = 'AdminApiError';
  }
}
export type EditorialState = 'DRAFT' | 'PENDING_REVIEW' | 'OBSERVED' | 'APPROVED' | 'SUSPENDED' | 'PUBLISHED' | 'REJECTED' | 'ARCHIVED';
export type ImportBatch = { id: string; fileName: string; sha256: string; cutoff: string | null; total: number; candidates: number; quarantined: number; poiDrafts: number; destinationDrafts: number; unassignedCandidates: number };
export type PageResult<T> = { content: T[]; page: number; size: number; totalElements: number; totalPages?: number };
export type ImportRecord = { id: string; sourceRecordId: string; rowNumber: number; name: string; sourceCategory: string; sourceType: string | null; suggestedPoiCategoryCode: string | null; region: string; province: string; district: string; sourceUrl: string; rawLatitude: string; rawLongitude: string; normalizedLatitude: number | null; normalizedLongitude: number | null; normalizationRule: string; validationEvidence: string; status: string; quarantineReason: string | null; hasEditorialRecord: boolean; hasDestinationEditorialRecord: boolean; reviewClassification: string };
export type EditorialRecord = { id: string; importRecordId: string | null; sourceRecordId: string | null; name: string; description: string | null; administrativeContext: string | null; categoryCode: string; latitude: number | null; longitude: number | null; rawLatitude: string | null; rawLongitude: string | null; normalizationRule: string | null; coordinateEvidence: string | null; geographicReviewStatus: string; identityReviewStatus: string; identityReviewEvidence: string | null; state: EditorialState; sourceLicense: string | null; sourceAttribution: string | null; sourceUrl: string | null; publishedPoiId: string | null; active: boolean; targetPoiId: string | null; version: number };
export type AdminPoi = { id: string; name: string; description: string | null; categoryCode: string; categoryName: string; active: boolean; updatedAt: string; sourceSystem: string | null; sourceRecordId: string | null; sourceUrl: string | null; license: string | null; attribution: string | null };
export type DuplicateCandidate = { entityType: 'POI' | 'DESTINATION'; entityId: string; name: string; distanceMeters: number | null };
export type MediaAsset = { id: string; poiId: string; contentType: string; sha256: string; sizeBytes: number; width: number; height: number; author: string; sourceUrl: string | null; license: string | null; attribution: string | null; evidenceReference: string | null; rightsStatus: string; state: string; primary: boolean; version: number; altText: string; displayOrder: number; sourceType?: 'OWN_PHOTOGRAPH' | 'EXTERNAL_SOURCE'; captureDate?: string | null; capturePlace?: string | null; authorDeclarationAccepted?: boolean; authorDeclarationVersion?: string | null; authorDeclarationBy?: string | null; authorDeclarationAt?: string | null; authorDeclarationText?: string | null };
export type PoiOperationalInfo = {
  timeZone: string;
  weeklyHours: Array<{ day: string; periods: Array<{ opensAt: string; closesAt: string }> }>;
  items: Array<{ id: string; type: 'PERFORMANCE' | 'PROMOTION'; title: string; description: string | null; scheduleText: string | null; validFrom: string | null; validUntil: string | null; terms: string | null; active: boolean }>;
  version: number;
};

export class AdminApi {
  constructor(private readonly config: ApiConfig) {}
  private async request<T>(path: string, init: RequestInit = {}): Promise<T> {
    const token = await this.config.getToken();
    if (!token) throw new AdminApiError(401, 'SESSION_UNAVAILABLE', 'No hay una sesión utilizable.');
    const url = `${this.config.baseUrl.replace(/\/$/, '')}${path}`;
    const send = (accessToken: string) => fetch(url, {
      ...init,
      headers: { ...(init.body instanceof FormData ? {} : { 'Content-Type': 'application/json' }), Authorization: `Bearer ${accessToken}`, ...init.headers },
    });
    let response = await send(token);
    if (response.status === 401 && this.config.renewToken) {
      const renewedToken = await this.config.renewToken();
      const method = (init.method ?? 'GET').toUpperCase();
      if (method !== 'GET') {
        if (renewedToken && renewedToken !== token) {
          throw new AdminApiError(401, 'SESSION_RENEWED_WRITE_NOT_RETRIED', 'La sesión se renovó, pero por seguridad no se repitió esta escritura. Comprueba si se guardó antes de volver a ejecutarla.');
        }
        throw new AdminApiError(401, 'SESSION_RENEWAL_FAILED', 'No se pudo renovar la sesión.');
      }
      const retryToken = renewedToken && renewedToken !== token
        ? renewedToken
        : await this.config.getToken();
      if (retryToken && retryToken !== token) {
        response = await send(retryToken);
      } else {
        throw new AdminApiError(401, 'SESSION_RENEWAL_FAILED', 'No se pudo renovar la sesión.');
      }
    }
    if (!response.ok) {
      let problem: { code?: unknown; detail?: unknown; errors?: unknown } = {};
      try { problem = await response.json() as typeof problem; } catch { /* Gateways may return an empty or non-JSON body. */ }
      const fieldErrors = Array.isArray(problem.errors) ? problem.errors.flatMap(item => {
        if (!item || typeof item !== 'object') return [];
        const value = item as Record<string, unknown>;
        return typeof value.field === 'string' && typeof value.code === 'string' && typeof value.message === 'string'
          ? [{ field: value.field, code: value.code, message: value.message }] : [];
      }) : [];
      const code = typeof problem.code === 'string' ? problem.code : `HTTP_${response.status}`;
      const safeDetail = typeof problem.detail === 'string' ? problem.detail : 'La operación no pudo completarse.';
      throw new AdminApiError(response.status, code, safeDetail, fieldErrors, response.headers.get('X-Request-Id') ?? undefined);
    }
    if (response.status === 204) return undefined as T;
    return response.json() as Promise<T>;
  }
  get<T>(path: string) { return this.request<T>(path); }
  post<T>(path: string, body: unknown) { return this.request<T>(path, { method: 'POST', body: JSON.stringify(body) }); }
  put<T>(path: string, body: unknown) { return this.request<T>(path, { method: 'PUT', body: JSON.stringify(body) }); }
  patch<T>(path: string, body: unknown) { return this.request<T>(path, { method: 'PATCH', body: JSON.stringify(body) }); }
  upload<T>(path: string, form: FormData) { return this.request<T>(path, { method: 'POST', body: form }); }
  async getBlob(path: string): Promise<Blob> {
    let token = await this.config.getToken();
    if (!token) throw new AdminApiError(401, 'SESSION_UNAVAILABLE', 'No hay una sesión utilizable para consultar la imagen.');
    const url = `${this.config.baseUrl.replace(/\/$/, '')}${path}`;
    const send = (accessToken: string) => fetch(url, { headers: { Authorization: `Bearer ${accessToken}` } });
    let response = await send(token);
    if (response.status === 401 && this.config.renewToken) {
      const renewed = await this.config.renewToken();
      const current = renewed && renewed !== token ? renewed : await this.config.getToken();
      if (current && current !== token) {
        token = current;
        response = await send(token);
      } else {
        throw new AdminApiError(401, 'SESSION_RENEWAL_FAILED', 'No se pudo renovar la sesión para consultar la imagen.');
      }
    }
    if (!response.ok) throw new AdminApiError(response.status, `HTTP_${response.status}`, 'No se pudo cargar la vista previa de la imagen.');
    return response.blob();
  }
}
