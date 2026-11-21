import { cleanup, fireEvent, render, waitFor } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { PoiTourismEditor } from './PoiTourismEditor';
import type { AdminPoi } from './api';

const poi: AdminPoi = { id: 'poi-1', name: 'Lugar de prueba', description: 'Descripción existente', categoryCode: 'MONUMENT', categoryName: 'Monumento', active: true, updatedAt: '', sourceSystem: 'fixture', sourceRecordId: 'test', sourceUrl: null, license: null, attribution: null };
const content = { summary: 'Resumen publicado', description: 'Texto vigente', history: '', significance: '', visitorExperience: '', interestingFacts: [], recommendations: [], practicalInfo: '', officialUrl: '' };
const initial = { poiId: 'poi-1', draftVersion: 0, draftState: 'NONE', draftContent: content, publishedVersion: 1, publishedContent: content, publishedAt: '2026-01-01T00:00:00Z', revisions: [] };

function apiMock() {
  const api = {
    get: vi.fn(async (path: string) => path.endsWith('/media') ? [] : path.endsWith('/operational-info') ? { timeZone: 'America/Lima', weeklyHours: [], items: [], version: 1 } : initial),
    put: vi.fn(async (_path: string, body: { content: typeof content }) => ({ ...initial, draftVersion: 1, draftState: 'DRAFT', draftContent: body.content })),
    post: vi.fn(async (path: string) => ({ ...initial, draftVersion: path.endsWith('/publish') ? 2 : 1, draftState: path.endsWith('/submit') ? 'PENDING_REVIEW' : path.endsWith('/publish') ? 'PUBLISHED' : 'PUBLISHED', draftContent: content, publishedContent: content })),
    getBlob: vi.fn(),
  };
  return api;
}

afterEach(cleanup);

describe('POI tourism visual editor', () => {
  it('previews edits immediately and saves a draft without publishing', async () => {
    const api = apiMock();
    const view = render(<PoiTourismEditor poi={poi} api={api as never} onClose={() => undefined} onOpenMedia={() => undefined} />);
    const description = await view.findByLabelText('Descripción turística');
    expect(view.container.querySelector('.phone-screen')?.textContent).toContain('Resumen publicado');
    fireEvent.change(description, { target: { value: 'Nuevo texto del borrador' } });
    expect(view.container.querySelector('.phone-screen')?.textContent).toContain('Nuevo texto del borrador');
    fireEvent.change(view.getByLabelText('Razón de auditoría'), { target: { value: 'Corrección editorial aprobada' } });
    fireEvent.click(view.getByRole('button', { name: 'Guardar borrador' }));
    await waitFor(() => expect(api.put).toHaveBeenCalledTimes(1));
    expect(api.post).not.toHaveBeenCalled();
    expect(view.getByText('Borrador guardado. El contenido público no cambió.')).toBeTruthy();
  });

  it('requires submit before the explicit publish action', async () => {
    const api = apiMock();
    const view = render(<PoiTourismEditor poi={poi} api={api as never} onClose={() => undefined} onOpenMedia={() => undefined} />);
    await view.findByLabelText('Descripción turística');
    expect(view.getAllByRole('button', { name: 'Publicar versión' }).every(button => (button as HTMLButtonElement).disabled)).toBe(true);
    fireEvent.change(view.getByLabelText('Razón de auditoría'), { target: { value: 'Revisión completada' } });
    fireEvent.click(view.getByRole('button', { name: 'Guardar borrador' }));
    await waitFor(() => expect(api.put).toHaveBeenCalledTimes(1));
    fireEvent.click(view.getByRole('button', { name: 'Enviar a revisión' }));
    await waitFor(() => expect(api.post).toHaveBeenCalledTimes(1));
    expect(api.post.mock.calls[0]?.[0]).toContain('/submit');
    expect((view.getAllByRole('button', { name: 'Publicar versión' })[0] as HTMLButtonElement).disabled).toBe(false);
    fireEvent.click(view.getAllByRole('button', { name: 'Publicar versión' })[0]!);
    await waitFor(() => expect(api.post).toHaveBeenCalledTimes(2));
    expect(api.post.mock.calls[1]?.[0]).toContain('/publish');
  });
});
