import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import App from './App';

let capturedRequests: Array<{ url: string; init?: RequestInit }> = [];
let includeMinceturCandidate = false;
let includeArchivedEditorialRecord = false;
let hasReopenedEditorialRecord = false;
let archiveRecordAfterConflict = false;
let simulateArchiveConflict = false;

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
    capturedRequests = [];
    includeMinceturCandidate = false;
    includeArchivedEditorialRecord = false;
    hasReopenedEditorialRecord = false;
    archiveRecordAfterConflict = false;
    simulateArchiveConflict = false;
    vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const url = String(input);
      capturedRequests.push({ url, init });
      const archivedRecord = {
        id: 'fdfeb867-576f-4fb5-bcbf-8784e54c2f3a', importRecordId: 'import-1851', sourceRecordId: '1851',
        name: 'Sitio Arqueológico Cantamarca', description: null, administrativeContext: 'CANTA — Canta — Lima',
        categoryCode: 'ARCHAEOLOGICAL_SITE', latitude: -11.438714, longitude: -76.591777,
        rawLatitude: '-7.659.177.699.999.990', rawLongitude: '-11.438.714', normalizationRule: 'synthetic',
        coordinateEvidence: 'synthetic', geographicReviewStatus: 'PENDING', identityReviewStatus: 'PENDING',
        identityReviewEvidence: null, state: 'ARCHIVED', sourceLicense: 'synthetic license',
        sourceAttribution: 'synthetic attribution', sourceUrl: 'https://example.test/1851',
        publishedPoiId: null, active: false, targetPoiId: null, version: 12,
      };
      const minceturRecord = {
        id: 'import-1851', sourceRecordId: '1851', rowNumber: 717, name: 'Sitio Arqueológico Cantamarca',
        sourceCategory: '2. MANIFESTACIONES CULTURALES', sourceType: 'Sitios Arqueológicos',
        suggestedPoiCategoryCode: 'ARCHAEOLOGICAL_SITE', region: 'Lima', province: 'Canta', district: 'Canta',
        sourceUrl: 'https://example.test/1851', rawLatitude: '-7.659.177.699.999.990', rawLongitude: '-11.438.714',
        normalizedLatitude: -11.438714, normalizedLongitude: -76.591777, normalizationRule: 'synthetic',
        validationEvidence: 'synthetic', status: 'NORMALIZED_PENDING_REVIEW', quarantineReason: null,
        hasEditorialRecord: false, hasDestinationEditorialRecord: false, reviewClassification: 'UNASSIGNED_CANDIDATE',
      };
      const batch = { id: 'batch-1', fileName: 'synthetic.csv', sha256: 'A'.repeat(64), cutoff: '2026-11-10',
        total: 1, candidates: 1, quarantined: 0, poiDrafts: 0, destinationDrafts: 0, unassignedCandidates: 1 };
      const staleRecord = { ...archivedRecord, state: 'OBSERVED', version: 11, geographicReviewStatus: 'APPROVED', identityReviewStatus: 'NO_DUPLICATE' };
      const reopenedRecord = { ...archivedRecord, state: 'DRAFT', version: 13, geographicReviewStatus: 'PENDING', identityReviewStatus: 'PENDING', publishedPoiId: null, active: false };
      const body = init?.method === 'POST' && url.endsWith('/api/v1/admin/records')
        ? { id: 'draft-1', importRecordId: null, sourceRecordId: null, name: 'POI sintético', description: null,
            administrativeContext: 'Canta', categoryCode: 'MONUMENT', latitude: null, longitude: null,
            rawLatitude: null, rawLongitude: null, normalizationRule: null, coordinateEvidence: null,
            geographicReviewStatus: 'PENDING', identityReviewStatus: 'PENDING', identityReviewEvidence: null,
            state: 'DRAFT', sourceLicense: null, sourceAttribution: null, sourceUrl: null, publishedPoiId: null, active: false, targetPoiId: null, version: 0 }
        : url.includes('/api/v1/admin/records/fdfeb867-576f-4fb5-bcbf-8784e54c2f3a/reopen') && init?.method === 'POST'
          ? (hasReopenedEditorialRecord = true, reopenedRecord)
        : url.includes('/api/v1/admin/records/fdfeb867-576f-4fb5-bcbf-8784e54c2f3a/archive')
          && init?.method === 'POST' && archiveRecordAfterConflict
          ? new Response(JSON.stringify({ status: 409, detail: 'El recurso cambió o la transición solicitada no está permitida.' }), { status: 409, headers: { 'Content-Type': 'application/problem+json' } })
        : url.includes('/api/v1/admin/records/fdfeb867-576f-4fb5-bcbf-8784e54c2f3a/archive')
          && init?.method === 'POST' ? (archiveRecordAfterConflict = true, new Response(JSON.stringify({ status: 409, detail: 'El recurso cambió o la transición solicitada no está permitida.' }), { status: 409, headers: { 'Content-Type': 'application/problem+json' } }))
        : url.includes('/duplicates') ? []
        : url.endsWith('/api/v1/admin/records/fdfeb867-576f-4fb5-bcbf-8784e54c2f3a')
          ? hasReopenedEditorialRecord ? reopenedRecord : archiveRecordAfterConflict ? archivedRecord : includeArchivedEditorialRecord ? archivedRecord : staleRecord
        : url.includes('/api/v1/admin/records?') && (includeArchivedEditorialRecord || simulateArchiveConflict)
          ? { content: [hasReopenedEditorialRecord ? reopenedRecord : simulateArchiveConflict && !archiveRecordAfterConflict ? staleRecord : archivedRecord], page: 0, size: 50, totalElements: 1, totalPages: 1 }
        : url.endsWith('/api/v1/admin/imports') && includeMinceturCandidate ? [batch]
        : url.includes('/api/v1/admin/imports/batch-1/records') && includeMinceturCandidate
          ? { content: [minceturRecord], page: 0, size: 100, totalElements: 1, totalPages: 1 }
        : url.includes('/api/v1/admin/pois?') || url.includes('/api/v1/admin/records') || url.includes('/api/v1/admin/destination-records')
          || url.includes('/api/v1/admin/destination-poi-relationships')
          ? { content: [], page: 0, size: 50, totalElements: 0 }
          : [];
      if (body instanceof Response) return body;
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

  it('creates a manual private draft without inventing coordinates or publishing it', async () => {
    render(<App />);

    await screen.findByRole('heading', { name: 'Catálogo turístico' });
    await screen.findByLabelText('Nombre del POI manual');
    fireEvent.change(screen.getByLabelText('Nombre del POI manual'), { target: { value: 'POI sintético' } });
    fireEvent.change(screen.getByLabelText('Localidad del POI manual'), { target: { value: 'Canta' } });
    fireEvent.change(screen.getByLabelText('Categoría del POI manual'), { target: { value: 'MONUMENT' } });
    fireEvent.click(screen.getByRole('button', { name: 'Crear borrador deshabilitado para Rutea' }));

    await screen.findByText('Raw MINCETUR: — / —');
    const createRequest = capturedRequests.find(({ url, init }) => url.endsWith('/api/v1/admin/records') && init?.method === 'POST');
    expect(createRequest).toBeTruthy();
    const body = JSON.parse(String(createRequest?.init?.body)) as Record<string, unknown>;
    expect(body.name).toBe('POI sintético');
    expect(body.administrativeContext).toBe('Canta');
    expect(body.latitude).toBeNull();
    expect(body.longitude).toBeNull();
    expect(capturedRequests.some(({ url }) => url.includes('/publish') || url.endsWith('/approve'))).toBe(false);
    expect(await screen.findByText('DRAFT · DESACTIVADO · v0')).toBeTruthy();
  });

  it('uses the exact MINCETUR type mapping and persists its P3 category for each candidate', async () => {
    includeMinceturCandidate = true;
    render(<App />);

    const batchButton = await screen.findByRole('button', { name: /synthetic.csv/ });
    fireEvent.click(batchButton);
    await screen.findByText('Sitio Arqueológico Cantamarca');

    const category = screen.getByLabelText('Categoría P3 1851') as HTMLSelectElement;
    const createButton = screen.getByRole('button', { name: 'Crear borrador POI' }) as HTMLButtonElement;
    expect(category.value).toBe('ARCHAEOLOGICAL_SITE');
    expect(screen.getByText('Mapeo exacto por tipo MINCETUR: Sitios Arqueológicos → ARCHAEOLOGICAL_SITE')).toBeTruthy();
    expect(createButton.disabled).toBe(false);
    fireEvent.click(createButton);

    await screen.findByText('Raw MINCETUR: — / —');
    const createRequest = capturedRequests.find(({ url, init }) => url.endsWith('/api/v1/admin/records') && init?.method === 'POST');
    expect(createRequest).toBeTruthy();
    expect(JSON.parse(String(createRequest?.init?.body))).toEqual({ importRecordId: 'import-1851', categoryCode: 'ARCHAEOLOGICAL_SITE' });
  });

  it('explains archived records and disables every editorial mutation', async () => {
    includeArchivedEditorialRecord = true;
    render(<App />);

    fireEvent.click(await screen.findByRole('button', { name: /Sitio Arqueológico Cantamarca/ }));

    expect((await screen.findByRole('status')).textContent).toContain('ARCHIVED');
    expect(screen.getByRole('status').textContent).toContain('No crea duplicados');
    expect((screen.getByLabelText('Nombre editorial') as HTMLInputElement).matches(':disabled')).toBe(true);
    const editorialControls = screen.getByLabelText('Nombre editorial').closest('fieldset');
    expect(editorialControls?.disabled).toBe(true);
    expect(Array.from(editorialControls?.querySelectorAll('button, input, select') ?? []).every(control => control.matches(':disabled'))).toBe(true);
    expect(capturedRequests.some(({ url, init }) => init?.method === 'POST' && /\/(approve|archive|geographic-review|identity-review)$/.test(url))).toBe(false);
  });

  it('reopens the same archived MINCETUR record to an inactive draft with a reason and reset reviews', async () => {
    includeArchivedEditorialRecord = true;
    render(<App />);
    fireEvent.click(await screen.findByRole('button', { name: /Sitio Arqueológico Cantamarca/ }));

    fireEvent.change(await screen.findByLabelText('Motivo de reapertura'), { target: { value: 'Revisar evidencia actualizada' } });
    fireEvent.click(screen.getByRole('button', { name: 'Reabrir expediente a borrador' }));

    expect(await screen.findByText('DRAFT · DESACTIVADO · v13')).toBeTruthy();
    expect(screen.getByText('Raw MINCETUR: -7.659.177.699.999.990 / -11.438.714')).toBeTruthy();
    const request = capturedRequests.find(({ url, init }) => url.endsWith('/api/v1/admin/records/fdfeb867-576f-4fb5-bcbf-8784e54c2f3a/reopen') && init?.method === 'POST');
    expect(request).toBeTruthy();
    expect(JSON.parse(String(request?.init?.body))).toEqual({ expectedVersion: 12, reason: 'Revisar evidencia actualizada' });
    expect(screen.getByText('DRAFT · geo PENDING · identidad PENDING')).toBeTruthy();
    expect(capturedRequests.some(({ url, init }) => init?.method === 'POST' && /\/(approve|activation)$/.test(url))).toBe(false);
    expect(hasReopenedEditorialRecord).toBe(true);
  });

  it('refreshes an archived status after HTTP 409 while preserving unsaved editor text', async () => {
    simulateArchiveConflict = true;
    render(<App />);
    fireEvent.click(await screen.findByRole('button', { name: /Sitio Arqueológico Cantamarca/ }));
    const name = await screen.findByLabelText('Nombre editorial') as HTMLInputElement;
    fireEvent.change(name, { target: { value: 'Texto sin guardar' } });
    fireEvent.change(screen.getByLabelText('Razón de auditoría'), { target: { value: 'Prueba sintética' } });
    fireEvent.change(screen.getByLabelText('Evidencia de decisión editorial'), { target: { value: 'Fixture HTTP 409' } });
    fireEvent.click(screen.getByRole('button', { name: 'Archivar' }));

    expect((await screen.findByRole('alert')).textContent).toContain('HTTP 409');
    expect(screen.getByRole('alert').textContent).toContain('el expediente está ARCHIVED');
    expect((screen.getByLabelText('Nombre editorial') as HTMLInputElement).value).toBe('Texto sin guardar');
    expect((screen.getByLabelText('Nombre editorial') as HTMLInputElement).matches(':disabled')).toBe(true);
    expect(capturedRequests.some(({ url, init }) => url.endsWith('/api/v1/admin/records/fdfeb867-576f-4fb5-bcbf-8784e54c2f3a') && !init?.method)).toBe(true);
  });

  it('sends locality, exact category, state, and name filters only to the admin catalog endpoint', async () => {
    render(<App />);
    await screen.findByRole('heading', { name: 'Catálogo turístico' });
    fireEvent.change(screen.getByLabelText('Buscar'), { target: { value: 'plaza' } });
    fireEvent.change(screen.getByLabelText('Localidad editorial'), { target: { value: 'Canta' } });
    fireEvent.change(screen.getByLabelText('Categoría editorial'), { target: { value: 'MONUMENT' } });
    fireEvent.change(screen.getByLabelText('Estado editorial'), { target: { value: 'DRAFT' } });
    fireEvent.click(screen.getByRole('button', { name: 'Filtrar catálogo' }));
    await waitFor(() => expect(capturedRequests.some(({ url }) => url.includes('category=MONUMENT')
      && url.includes('locality=Canta') && url.includes('state=DRAFT') && url.includes('q=plaza'))).toBe(true));
  });
});
