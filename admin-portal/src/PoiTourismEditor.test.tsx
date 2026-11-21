import { cleanup, fireEvent, render, waitFor } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { PoiTourismEditor } from './PoiTourismEditor';
import type { AdminPoi } from './api';

const poi: AdminPoi = { id: 'poi-1', name: 'Lugar de prueba', description: 'Descripción existente', categoryCode: 'MONUMENT', categoryName: 'Monumento', active: true, updatedAt: '', sourceSystem: 'fixture', sourceRecordId: 'test', sourceUrl: null, license: null, attribution: null };
const content = { summary: 'Resumen publicado', description: 'Texto vigente', history: '', significance: '', visitorExperience: '', interestingFacts: [], recommendations: [], practicalInfo: '', officialUrl: '' };
const empty = { summary: '', description: '', history: '', significance: '', visitorExperience: '', interestingFacts: [], recommendations: [], practicalInfo: '', officialUrl: '' };
const curatedPoi = { name: 'Nombre oficial del lugar', categoryCode: 'MONUMENT', categoryName: 'Monumento', description: 'Descripción curada ya visible en Rutea', sourceSystem: 'fixture', sourceRecordId: 'test-1', sourceUrl: 'https://example.test', license: 'CC BY', attribution: 'Equipo de prueba' };
const initial: { poiId: string; curatedPoi: typeof curatedPoi; draftVersion: number; draftState: string; draftContent: typeof content; publishedVersion: number | null; publishedContent: typeof content; publishedAt: string | null; revisions: Array<{ id: string; version: number; state: string; createdBy: string; createdAt: string }> } = { poiId: 'poi-1', curatedPoi, draftVersion: 0, draftState: 'NONE', draftContent: content, publishedVersion: 1, publishedContent: content, publishedAt: '2026-01-01T00:00:00Z', revisions: [] };

function apiMock(record = initial) {
  const api = {
    get: vi.fn(async (path: string) => path.endsWith('/media') ? [] : path.endsWith('/operational-info') ? { timeZone: 'America/Lima', weeklyHours: [], items: [], version: 1 } : record),
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
    const view = render(<PoiTourismEditor poi={poi} api={api as never} onClose={() => undefined} onManageMedia={() => undefined} />);
    const description = await view.findByLabelText('Descripción turística');
    expect(view.container.querySelector('.phone-screen h2')?.textContent).toBe('Lugar de prueba');
    expect(view.container.querySelector('.phone-screen .poi-summary')?.textContent).toBe('Resumen publicado');
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
    const view = render(<PoiTourismEditor poi={poi} api={api as never} onClose={() => undefined} onManageMedia={() => undefined} />);
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

  it('shows curated existing data without persisting it and offers an explicit draft initialization', async () => {
    const api = apiMock({ ...initial, publishedVersion: null, publishedContent: empty, draftContent: empty });
    const view = render(<PoiTourismEditor poi={{ ...poi, description: curatedPoi.description }} api={api as never} onClose={() => undefined} onManageMedia={() => undefined} />);
    await view.findByText('Datos curados actuales · solo lectura');
    expect(view.getAllByText(curatedPoi.description)).toHaveLength(2);
    expect(view.container.querySelector('.phone-screen h2')?.textContent).toBe(poi.name);
    expect(view.container.querySelector('.phone-screen')?.textContent).toContain(curatedPoi.description);
    expect((view.getByLabelText('Descripción turística') as HTMLTextAreaElement).value).toBe('');
    fireEvent.click(view.getByRole('button', { name: 'Iniciar borrador desde descripción curada' }));
    expect((view.getByLabelText('Descripción turística') as HTMLTextAreaElement).value).toBe(curatedPoi.description);
    expect(api.put).not.toHaveBeenCalled();
  });

  it('keeps the official name as preview title and blocks provisional copy from review', async () => {
    const api = apiMock();
    const view = render(<PoiTourismEditor poi={poi} api={api as never} onClose={() => undefined} onManageMedia={() => undefined} />);
    await view.findByLabelText('Descripción turística');
    fireEvent.change(view.getByLabelText('Resumen para resultados'), { target: { value: 'Que va aquí' } });
    expect(view.container.querySelector('.phone-screen h2')?.textContent).toBe(poi.name);
    expect(view.getByRole('alert').textContent).toContain('texto provisional');
    expect((view.getByRole('button', { name: 'Enviar a revisión' }) as HTMLButtonElement).disabled).toBe(true);
  });

  it('allows valid practical wording that contains the word todo', async () => {
    const api = apiMock();
    const view = render(<PoiTourismEditor poi={poi} api={api as never} onClose={() => undefined} onManageMedia={() => undefined} />);
    await view.findByLabelText('Descripción turística');
    fireEvent.change(view.getByLabelText('Descripción turística'), { target: { value: 'Abierto todo el año.' } });
    fireEvent.change(view.getByLabelText('Razón de auditoría'), { target: { value: 'Texto turístico revisado' } });
    expect(view.queryByRole('alert')).toBeNull();
    expect((view.getByRole('button', { name: 'Enviar a revisión' }) as HTMLButtonElement).disabled).toBe(true);
    fireEvent.click(view.getByRole('button', { name: 'Guardar borrador' }));
    await waitFor(() => expect(api.put).toHaveBeenCalledOnce());
    fireEvent.click(view.getByRole('button', { name: 'Enviar a revisión' }));
    await waitFor(() => expect(api.post).toHaveBeenCalledOnce());
  });
});
