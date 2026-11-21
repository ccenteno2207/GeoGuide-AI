import { describe, expect, it } from 'vitest';
import { validateMediaUpload } from './mediaUploadValidation';

const validFile = () => new File([new Uint8Array([1, 2, 3])], 'photo.png', { type: 'image/png' });

describe('private POI media upload client validation', () => {
  it('requires file, author, HTTPS source and a selected POI before sending', () => {
    expect(validateMediaUpload({ poiId: '', file: null, author: '', sourceUrl: '', altText: '' })).toEqual({
      poiId: 'Selecciona primero el POI al que pertenece la fotografía.',
      file: 'Selecciona un archivo JPEG o PNG válido.',
      author: 'Indica el autor o titular de derechos.',
      sourceUrl: 'Indica una fuente HTTPS válida.',
    });
  });

  it('rejects unsupported types, non-HTTPS references and files above the server limit', () => {
    const svg = new File(['<svg/>'], 'photo.svg', { type: 'image/svg+xml' });
    expect(validateMediaUpload({ poiId: 'poi-1', file: svg, author: 'Author', sourceUrl: 'http://example.test/photo', altText: 'Photo' }))
      .toMatchObject({ file: 'Selecciona un archivo JPEG o PNG válido.', sourceUrl: expect.stringContaining('HTTPS') });
    const large = new File([new Uint8Array(1025)], 'large.png', { type: 'image/png' });
    expect(validateMediaUpload({ poiId: 'poi-1', file: large, author: 'Author', sourceUrl: 'https://example.test/photo', altText: 'Photo', maxBytes: 1024 }).file)
      .toContain('1,024 bytes');
  });

  it('allows optional alt text on a private draft and validates rights separately', () => {
    expect(validateMediaUpload({ poiId: 'poi-1', file: validFile(), author: 'María Pérez', sourceUrl: 'https://archive.example/photo/1', altText: 'Church facade' }))
      .toEqual({});
    expect(validateMediaUpload({ poiId: 'poi-1', file: validFile(), author: 'María Pérez', sourceUrl: 'https://archive.example/photo/1', altText: '' }))
      .toEqual({});
  });

  it('requires auditable rights fields before marking rights documented', async () => {
    const { validateMediaRights } = await import('./mediaUploadValidation');
    expect(validateMediaRights({ license: '', attribution: '', evidenceReference: '', reason: '' })).toMatchObject({
      license: expect.stringContaining('licencia'),
      attribution: expect.stringContaining('atribución'),
      evidenceReference: expect.stringContaining('evidencia'),
      reason: expect.stringContaining('auditoría'),
    });
  });
});
