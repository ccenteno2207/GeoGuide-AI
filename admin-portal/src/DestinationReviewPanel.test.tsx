import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { AdminApi } from './api';
import { DestinationReviewPanel } from './DestinationReviewPanel';

const destination = {
  id: 'dest-1', importRecordId: 'import-1', sourceRecordId: '237', canonicalName: 'Laguna de prueba',
  destinationType: 'Sitios Naturales', administrativeContext: 'Ica — Ica — Ica', latitude: -14.1,
  longitude: -75.7, rawLatitude: '-7.57', rawLongitude: '-14.1', normalizationRule: 'snapshot-hash-rule',
  coordinateEvidence: 'reviewed map evidence', sourceUrl: 'https://example.invalid/237', sourceLicense: null,
  sourceAttribution: null, geographicReviewStatus: 'APPROVED', identityReviewStatus: 'PENDING',
  identityReviewEvidence: null,
  accessReviewStatus: 'PENDING', accessReviewEvidence: null, state: 'DRAFT', publishedDestinationId: null, version: 1,
};

describe('destination editorial UI', () => {
  afterEach(() => cleanup());

  it('requires and sends concrete evidence for a separate identity decision', async () => {
    const get = vi.fn(async (path: string) => path.includes('/duplicates')
      ? [] : { content: [destination], page: 0, size: 100, totalElements: 1 });
    const post = vi.fn(async () => ({ ...destination, identityReviewStatus: 'NO_DUPLICATE',
      identityReviewEvidence: 'Compared source code and existing destination identities.', version: 2 }));
    const api = { get, post, put: vi.fn() } as unknown as AdminApi;

    render(<DestinationReviewPanel api={api} />);
    fireEvent.click(await screen.findByRole('button', { name: /Laguna de prueba/ }));
    fireEvent.change(screen.getByLabelText('Evidencia de identidad'), {
      target: { value: 'Compared source code and existing destination identities.' },
    });
    fireEvent.change(screen.getByLabelText('Razón de auditoría'), { target: { value: 'Identity reviewed' } });
    fireEvent.click(screen.getByRole('button', { name: 'Confirmar sin duplicado' }));

    await waitFor(() => expect(post).toHaveBeenCalledWith('/api/v1/admin/destination-records/dest-1/identity-review', {
      expectedVersion: 1, noDuplicate: true, reason: 'Identity reviewed',
      evidence: 'Compared source code and existing destination identities.',
    }));
  });

  it('keeps access review a separate evidenced action and explains destination versus POI eligibility', async () => {
    const get = vi.fn(async (path: string) => {
      if (path.includes('/duplicates')) return [];
      if (path.includes('destination-poi-relationships')) return { content: [], page: 0, size: 100, totalElements: 0 };
      return { content: [destination], page: 0, size: 100, totalElements: 1 };
    });
    const post = vi.fn(async () => ({ ...destination, accessReviewStatus: 'APPROVED', version: 2 }));
    const api = { get, post, put: vi.fn() } as unknown as AdminApi;

    render(<DestinationReviewPanel api={api} />);
    expect(await screen.findByText('Laguna de prueba')).toBeTruthy();
    fireEvent.click(screen.getByRole('button', { name: /Laguna de prueba/ }));
    fireEvent.change(screen.getByLabelText('Evidencia de acceso/llegada'), {
      target: { value: 'synthetic route reaches reviewed access point' },
    });
    fireEvent.change(screen.getByLabelText('Razón de auditoría'), { target: { value: 'Reviewed in local fixture' } });
    fireEvent.click(screen.getByRole('button', { name: 'Aprobar acceso' }));

    await waitFor(() => expect(post).toHaveBeenCalledWith('/api/v1/admin/destination-records/dest-1/access-review', {
      expectedVersion: 1, approve: true, reason: 'Reviewed in local fixture',
      evidence: 'synthetic route reaches reviewed access point',
    }));
    expect(screen.getByText(/elegibilidad de destino es independiente de POI/i)).toBeTruthy();
    expect(screen.getByText(/no publica ni sincroniza ubicaciones o estados/i)).toBeTruthy();
  });
});
