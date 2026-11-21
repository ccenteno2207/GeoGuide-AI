import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { PoiOperationalEditor } from './PoiOperationalEditor';
import type { AdminApi, AdminPoi, PoiOperationalInfo } from './api';
import { AdminFeedbackProvider } from './AdminFeedback';

const poi: AdminPoi = {
  id: 'poi-active-1', name: 'Museo sintético', description: null, categoryCode: 'MUSEUM',
  categoryName: 'Museo', active: true, updatedAt: '2026-11-20T10:00:00Z', sourceSystem: null,
  sourceRecordId: null, sourceUrl: null, license: null, attribution: null,
};

const emptyInfo: PoiOperationalInfo = {
  timeZone: 'America/Lima', version: 0,
  weeklyHours: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']
    .map((day) => ({ day, periods: [] })),
  items: [],
};

describe('POI operational editor', () => {
  it('edits hours and promotions in place without an approval action', async () => {
    const api = {
      get: vi.fn().mockResolvedValue(emptyInfo),
      put: vi.fn().mockImplementation(async (_path: string, body: PoiOperationalInfo & { expectedVersion: number }) => ({
        ...body, version: 1,
      })),
    } as unknown as AdminApi;

    render(<AdminFeedbackProvider><PoiOperationalEditor poi={poi} api={api} onClose={() => undefined} /></AdminFeedbackProvider>);
    await screen.findByLabelText('Horario Lunes');
    fireEvent.change(screen.getByLabelText('Horario Lunes'), { target: { value: '09:00-17:00' } });
    fireEvent.click(screen.getByRole('button', { name: 'Agregar promoción' }));
    fireEvent.change(screen.getByLabelText('Título de función o promoción'), { target: { value: 'Entrada 2x1' } });
    fireEvent.change(screen.getByLabelText('Descripción de función o promoción'), { target: { value: 'Oferta de prueba' } });
    fireEvent.click(screen.getByRole('button', { name: 'Guardar información operativa' }));

    await waitFor(() => expect(api.put).toHaveBeenCalledOnce());
    const [path, body] = vi.mocked(api.put).mock.calls[0] as unknown as [string, Record<string, unknown>];
    expect(path).toBe('/api/v1/admin/pois/poi-active-1/operational-info');
    expect(body.expectedVersion).toBe(0);
    expect(body.weeklyHours).toEqual(expect.arrayContaining([{
      day: 'MONDAY', periods: [{ opensAt: '09:00:00', closesAt: '17:00:00' }],
    }]));
    expect(body.items).toEqual([expect.objectContaining({ type: 'PROMOTION', title: 'Entrada 2x1', active: true })]);
    expect((await screen.findByRole('status')).textContent).toContain('Información operativa actualizada.');
    expect(screen.queryByRole('button', { name: /Aprobar|Enviar a revisión/ })).toBeNull();
  });
});
