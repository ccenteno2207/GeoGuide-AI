import { cleanup, fireEvent, render, waitFor } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { PoiMediaGallery } from './PoiMediaGallery';

afterEach(cleanup);

describe('POI media gallery inside tourism editor', () => {
  it('shows rights/state metadata, opens management, and reads the audit history', async () => {
    const api = { get: vi.fn(async () => [{ actor: 'reviewer', action: 'PUBLISH', reason: 'rights checked', priorState: 'PENDING_REVIEW', nextState: 'PUBLISHED', details: '{}', occurredAt: '2026-11-20T12:00:00Z' }]) };
    const onManage = vi.fn();
    const view = render(<PoiMediaGallery poiId="poi-1" api={api as never} assets={[{ id: 'asset-1', poiId: 'poi-1', contentType: 'image/jpeg', sha256: 'sha', sizeBytes: 100, width: 40, height: 30, author: 'Test author', sourceUrl: 'synthetic fixture', license: 'TEST', attribution: 'Synthetic', rightsEvidence: 'fixture', rightsStatus: 'DOCUMENTED', state: 'PUBLISHED', primary: true, version: 2, altText: 'Synthetic image', displayOrder: 0 }]} previews={{ 'asset-1': 'blob:test' }} onManage={onManage} />);
    expect(view.getByText('Fotografía principal')).toBeTruthy();
    expect(view.getByText(/Licencia: TEST · Fuente: synthetic fixture/)).toBeTruthy();
    fireEvent.click(view.getByRole('button', { name: 'Administrar fotografías' }));
    expect(onManage).toHaveBeenCalledOnce();
    fireEvent.click(view.getByRole('button', { name: 'Historial' }));
    await waitFor(() => expect(view.getByText(/PUBLISH: PENDING_REVIEW → PUBLISHED/)).toBeTruthy());
    expect(api.get).toHaveBeenCalledWith('/api/v1/admin/media/asset-1/history');
  });
});
