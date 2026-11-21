export type MediaUploadFields = 'poiId' | 'file' | 'author' | 'sourceUrl' | 'altText';
export type MediaUploadErrors = Partial<Record<MediaUploadFields, string>>;
export type MediaRightsFields = 'license' | 'attribution' | 'evidenceReference' | 'reason';
export type MediaRightsErrors = Partial<Record<MediaRightsFields, string>>;
export const DEFAULT_MEDIA_MAX_BYTES = 10 * 1024 * 1024;

function formatByteLimit(bytes: number): string {
  return bytes === DEFAULT_MEDIA_MAX_BYTES ? '10 MiB' : `${bytes.toLocaleString('es-PE')} bytes`;
}

export function validMediaSource(value: string): boolean {
  try { const url = new URL(value); return url.protocol === 'https:' && Boolean(url.hostname); } catch { return false; }
}

export function validateMediaUpload(input: {
  poiId: string; file: File | null; author: string; sourceUrl: string; altText: string; maxBytes?: number;
}): MediaUploadErrors {
  const errors: MediaUploadErrors = {};
  if (!input.poiId) errors.poiId = 'Selecciona primero el POI al que pertenece la fotografía.';
  if (!input.file) errors.file = 'Selecciona un archivo JPEG o PNG válido.';
  else if (input.file.size === 0 || !['image/jpeg', 'image/png'].includes(input.file.type)) errors.file = 'Selecciona un archivo JPEG o PNG válido.';
  else if (input.file.size > (input.maxBytes ?? DEFAULT_MEDIA_MAX_BYTES)) errors.file = `El archivo supera el tamaño máximo permitido de ${formatByteLimit(input.maxBytes ?? DEFAULT_MEDIA_MAX_BYTES)}.`;
  if (!input.author.trim()) errors.author = 'Indica el autor o titular de derechos.';
  if (input.author.length > 200) errors.author = 'El autor no debe superar 200 caracteres.';
  if (!input.sourceUrl.trim()) errors.sourceUrl = 'Indica una fuente HTTPS válida.';
  else if (!validMediaSource(input.sourceUrl.trim())) errors.sourceUrl = 'Usa una URL HTTPS completa con dominio, por ejemplo: https://archivo.example/foto/123.';
  else if (input.sourceUrl.length > 2048) errors.sourceUrl = 'La referencia de fuente no debe superar 2048 caracteres.';
  // Private drafts may be uploaded without alt text; publication still requires it.
  if (input.altText.length > 500) errors.altText = 'El texto alternativo no debe superar 500 caracteres.';
  return errors;
}

export function validateMediaRights(input: { license: string; attribution: string; evidenceReference: string; reason: string }): MediaRightsErrors {
  const errors: MediaRightsErrors = {};
  if (!input.license.trim()) errors.license = 'Indica la licencia concedida o la base documentada de autorización.';
  if (!input.attribution.trim()) errors.attribution = 'Indica la atribución que debe acompañar a la fotografía.';
  if (!input.evidenceReference.trim()) errors.evidenceReference = 'Adjunta o describe la evidencia verificable de autorización de uso.';
  if (!input.reason.trim()) errors.reason = 'Indica el motivo de auditoría de esta modificación.';
  return errors;
}
