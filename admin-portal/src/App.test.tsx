import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import App from './App';

let capturedRequests: Array<{ url: string; init?: RequestInit }> = [];

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
    vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const url = String(input);
      capturedRequests.push({ url, init });
      const body = init?.method === 'POST' && url.endsWith('/api/v1/admin/records')
        ? { id: 'draft-1', importRecordId: null, sourceRecordId: null, name: 'POI sintético', description: null,
            administrativeContext: 'Canta', categoryCode: 'MONUMENT', latitude: null, longitude: null,
            rawLatitude: null, rawLongitude: null, normalizationRule: null, coordinateEvidence: null,
            geographicReviewStatus: 'PENDING', identityReviewStatus: 'PENDING', identityReviewEvidence: null,
            state: 'DRAFT', sourceLicense: null, sourceAttribution: null, sourceUrl: null, publishedPoiId: null, active: false, targetPoiId: null, version: 0 }
        : url.includes('/duplicates') ? []
        : url.includes('/api/v1/admin/pois?') || url.includes('/api/v1/admin/records') || url.includes('/api/v1/admin/destination-records')
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

  it('creates a manual private draft without inventing coordinates or publishing it', async () => {
    render(<App />);

    await screen.findByRole('heading', { name: 'Catálogo turístico' });
    await screen.findByLabelText('Nombre del POI manual');
    fireEvent.change(screen.getByLabelText('Nombre del POI manual'), { target: { value: 'POI sintético' } });
    fireEvent.change(screen.getByLabelText('Localidad del POI manual'), { target: { value: 'Canta' } });
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
