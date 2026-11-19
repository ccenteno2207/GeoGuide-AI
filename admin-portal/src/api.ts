export type ApiConfig = { baseUrl: string; getToken: () => Promise<string | null> };
export type EditorialState = 'DRAFT' | 'PENDING_REVIEW' | 'OBSERVED' | 'APPROVED' | 'SUSPENDED' | 'PUBLISHED' | 'REJECTED' | 'ARCHIVED';
export type ImportBatch = { id: string; fileName: string; sha256: string; cutoff: string | null; total: number; candidates: number; quarantined: number; poiDrafts: number; destinationDrafts: number; unassignedCandidates: number };
export type PageResult<T> = { content: T[]; page: number; size: number; totalElements: number; totalPages?: number };
export type ImportRecord = { id: string; sourceRecordId: string; rowNumber: number; name: string; sourceCategory: string; region: string; province: string; district: string; sourceUrl: string; rawLatitude: string; rawLongitude: string; normalizedLatitude: number | null; normalizedLongitude: number | null; normalizationRule: string; validationEvidence: string; status: string; quarantineReason: string | null; hasEditorialRecord: boolean; hasDestinationEditorialRecord: boolean; reviewClassification: string };
export type EditorialRecord = { id: string; importRecordId: string | null; sourceRecordId: string | null; name: string; description: string | null; administrativeContext: string | null; categoryCode: string; latitude: number | null; longitude: number | null; rawLatitude: string | null; rawLongitude: string | null; normalizationRule: string | null; coordinateEvidence: string | null; geographicReviewStatus: string; identityReviewStatus: string; identityReviewEvidence: string | null; state: EditorialState; sourceLicense: string | null; sourceAttribution: string | null; sourceUrl: string | null; publishedPoiId: string | null; active: boolean; targetPoiId: string | null; version: number };
export type AdminPoi = { id: string; name: string; description: string | null; categoryCode: string; categoryName: string; active: boolean; updatedAt: string; sourceSystem: string | null; sourceRecordId: string | null; sourceUrl: string | null; license: string | null; attribution: string | null };
export type DuplicateCandidate = { entityType: 'POI' | 'DESTINATION'; entityId: string; name: string; distanceMeters: number | null };
export type MediaAsset = { id: string; poiId: string; contentType: string; sha256: string; sizeBytes: number; width: number; height: number; author: string; sourceUrl: string; license: string | null; attribution: string | null; rightsEvidence: string | null; rightsStatus: string; state: string; primary: boolean; version: number };

export class AdminApi {
  constructor(private readonly config: ApiConfig) {}
  private async request<T>(path: string, init: RequestInit = {}): Promise<T> {
    const token = await this.config.getToken();
    if (!token) throw new Error('Inicie sesión con el proveedor OIDC configurado.');
    const response = await fetch(`${this.config.baseUrl.replace(/\/$/, '')}${path}`, {
      ...init,
      headers: { ...(init.body instanceof FormData ? {} : { 'Content-Type': 'application/json' }), Authorization: `Bearer ${token}`, ...init.headers },
    });
    if (!response.ok) throw new Error(`API ${response.status}: ${await response.text()}`);
    if (response.status === 204) return undefined as T;
    return response.json() as Promise<T>;
  }
  get<T>(path: string) { return this.request<T>(path); }
  post<T>(path: string, body: unknown) { return this.request<T>(path, { method: 'POST', body: JSON.stringify(body) }); }
  put<T>(path: string, body: unknown) { return this.request<T>(path, { method: 'PUT', body: JSON.stringify(body) }); }
  patch<T>(path: string, body: unknown) { return this.request<T>(path, { method: 'PATCH', body: JSON.stringify(body) }); }
  upload<T>(path: string, form: FormData) { return this.request<T>(path, { method: 'POST', body: form }); }
}
