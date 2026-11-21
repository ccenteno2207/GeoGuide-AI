import { useState } from 'react';
import type { AdminApi, MediaAsset } from './api';

type AuditEvent = { actor: string; action: string; reason: string; priorState: string | null; nextState: string | null; details: string; occurredAt: string };

/** Visible gallery summary in the tourism editor; the existing private workflow remains the source of media actions. */
export function PoiMediaGallery({
  poiId, api, assets, previews, onManage,
}: {
  poiId: string;
  api: AdminApi;
  assets: MediaAsset[];
  previews: Record<string, string>;
  onManage: () => void;
}) {
  const [historyFor, setHistoryFor] = useState<string | null>(null);
  const [history, setHistory] = useState<AuditEvent[]>([]);
  const [historyError, setHistoryError] = useState('');
  const [loadingHistory, setLoadingHistory] = useState(false);
  const visible = [...assets].filter(asset => asset.state !== 'WITHDRAWN')
    .sort((a, b) => Number(b.primary) - Number(a.primary) || a.displayOrder - b.displayOrder);

  const showHistory = async (assetId: string) => {
    if (historyFor === assetId) { setHistoryFor(null); return; }
    setHistoryFor(assetId); setHistoryError(''); setLoadingHistory(true);
    try { setHistory(await api.get<AuditEvent[]>(`/api/v1/admin/media/${assetId}/history`)); }
    catch (error) { setHistoryError(error instanceof Error ? error.message : 'No se pudo cargar el historial.'); }
    finally { setLoadingHistory(false); }
  };

  return <section className="poi-media-gallery" aria-label={`Fotografías de ${poiId}`}>
    <div className="section-head"><div><h3>Fotografías del POI</h3><p>Galería privada y derechos registrados. Solo las imágenes publicadas y autorizadas aparecen en Rutea.</p></div><button type="button" onClick={onManage}>Administrar fotografías</button></div>
    {visible.length === 0 ? <p className="empty">No hay fotografías disponibles para este POI. Puede cargar una imagen autorizada desde la gestión privada.</p> : <div className="poi-media-thumbnails">
      {visible.map(asset => <article className="poi-media-thumbnail" key={asset.id}>
        {previews[asset.id] ? <img src={previews[asset.id]} alt={asset.altText || 'Vista previa de fotografía sin texto alternativo'} /> : <div className="poi-media-placeholder" role="img" aria-label="Vista previa no disponible">Vista previa no disponible</div>}
        <div><strong>{asset.primary ? 'Fotografía principal' : `Fotografía · orden ${asset.displayOrder + 1}`}</strong><p>{asset.state} · derechos {asset.rightsStatus}</p><p>{asset.author || 'Autor no registrado'}{asset.attribution ? ` · ${asset.attribution}` : ''}</p><p>Licencia: {asset.license || 'Pendiente'} · Fuente: {asset.sourceUrl || 'No registrada'}</p><small>{asset.altText || 'Texto alternativo pendiente'}</small>
          <button type="button" className="secondary" onClick={() => void showHistory(asset.id)} aria-expanded={historyFor === asset.id}>Historial</button>
          {historyFor === asset.id && <div aria-live="polite">{loadingHistory ? <p role="status">Cargando historial…</p> : historyError ? <p role="alert">{historyError}</p> : history.length ? history.map((event, index) => <p key={`${event.occurredAt}-${index}`}>{event.action}: {event.priorState || '—'} → {event.nextState || '—'} · {event.actor} · {event.reason} · {event.occurredAt}</p>) : <p>Sin eventos de auditoría.</p>}</div>}
        </div>
      </article>)}
    </div>}
  </section>;
}
