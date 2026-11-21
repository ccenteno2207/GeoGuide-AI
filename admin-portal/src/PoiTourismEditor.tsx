import { useEffect, useMemo, useState } from 'react';
import type { AdminApi, AdminPoi, MediaAsset, PoiOperationalInfo } from './api';

type Content = {
  summary: string | null; description: string | null; history: string | null;
  significance: string | null; visitorExperience: string | null;
  interestingFacts: string[]; recommendations: string[];
  practicalInfo: string | null; officialUrl: string | null;
};
type Revision = { id: string; version: number; state: string; createdBy: string; createdAt: string };
type AdminContent = { poiId: string; draftVersion: number; draftState: string; draftContent: Content; publishedVersion: number | null; publishedContent: Content; publishedAt: string | null; revisions: Revision[] };
type ScalarContentKey = 'summary' | 'description' | 'history' | 'significance' | 'visitorExperience' | 'practicalInfo' | 'officialUrl';
const empty: Content = { summary: '', description: '', history: '', significance: '', visitorExperience: '', interestingFacts: [], recommendations: [], practicalInfo: '', officialUrl: '' };
const text = (value: string | null | undefined) => value ?? '';
const lines = (value: string) => value.split('\n').map(x => x.trim()).filter(Boolean);

export function PoiTourismEditor({ poi, api, onClose, onOpenMedia }: { poi: AdminPoi; api: AdminApi; onClose: () => void; onOpenMedia: () => void }) {
  const [record, setRecord] = useState<AdminContent | null>(null);
  const [draft, setDraft] = useState<Content>(empty);
  const [media, setMedia] = useState<MediaAsset[]>([]);
  const [operational, setOperational] = useState<PoiOperationalInfo | null>(null);
  const [previews, setPreviews] = useState<Record<string, string>>({});
  const [reason, setReason] = useState('');
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [previewMode, setPreviewMode] = useState<'draft' | 'published'>('draft');
  const dirty = useMemo(() => record != null && JSON.stringify(draft) !== JSON.stringify(record.draftContent), [draft, record]);
  const load = async () => {
    setLoading(true); setError('');
    try {
      const [content, assets, operations] = await Promise.all([
        api.get<AdminContent>(`/api/v1/admin/pois/${poi.id}/content`),
        api.get<MediaAsset[]>(`/api/v1/admin/pois/${poi.id}/media`),
        api.get<PoiOperationalInfo>(`/api/v1/admin/pois/${poi.id}/operational-info`).catch(() => null),
      ]);
      setRecord(content); setDraft(content.draftState === 'NONE' ? content.publishedContent ?? empty : content.draftContent ?? empty);
      setMedia(assets); setOperational(operations);
    } catch (e) { setError(e instanceof Error ? e.message : 'No se pudo cargar el editor.'); }
    finally { setLoading(false); }
  };
  useEffect(() => { void load(); return () => Object.values(previews).forEach(URL.revokeObjectURL); }, [poi.id]);
  useEffect(() => {
    let cancelled = false;
    for (const item of media) {
      if (previews[item.id] || item.state === 'WITHDRAWN') continue;
      void api.getBlob(`/api/v1/admin/media/${item.id}/content`).then(blob => {
        if (cancelled) return;
        const url = URL.createObjectURL(blob);
        setPreviews(current => ({ ...current, [item.id]: url }));
      }).catch(() => undefined);
    }
    return () => { cancelled = true; };
  }, [media, api]);
  const run = async (action: () => Promise<void>) => {
    setBusy(true); setError(''); setNotice('');
    try { await action(); } catch (e) { setError(e instanceof Error ? e.message : 'La operación no pudo completarse.'); }
    finally { setBusy(false); }
  };
  const mutate = (key: ScalarContentKey, value: string) => setDraft(current => ({ ...current, [key]: value }));
  const save = () => run(async () => {
    if (!record || !reason.trim()) throw new Error('Indique una razón de auditoría.');
    const content: Content = { ...draft, interestingFacts: typeof draft.interestingFacts === 'string' ? lines(draft.interestingFacts as unknown as string) : draft.interestingFacts, recommendations: typeof draft.recommendations === 'string' ? lines(draft.recommendations as unknown as string) : draft.recommendations };
    const next = await api.put<AdminContent>(`/api/v1/admin/pois/${poi.id}/content/draft`, { expectedVersion: record.draftVersion, content, reason });
    setRecord(next); setDraft(next.draftContent); setPreviewMode('draft'); setNotice('Borrador guardado. El contenido público no cambió.');
  });
  const transition = (action: 'submit' | 'publish') => run(async () => {
    if (!record || !reason.trim()) throw new Error('Indique una razón de auditoría.');
    const next = await api.post<AdminContent>(`/api/v1/admin/pois/${poi.id}/content/${action}`, { expectedVersion: record.draftVersion, reason });
    setRecord(next); setDraft(next.draftContent); setPreviewMode(action === 'publish' ? 'published' : 'draft');
    setNotice(action === 'publish' ? 'Versión turística publicada; el POI conserva su activación.' : 'Borrador enviado a revisión.');
  });
  const revert = (revisionId: string) => run(async () => {
    if (!record || !reason.trim()) throw new Error('Indique una razón de auditoría.');
    const next = await api.post<AdminContent>(`/api/v1/admin/pois/${poi.id}/content/revert`, { revisionId, expectedVersion: record.draftVersion, reason });
    setRecord(next); setDraft(next.draftContent); setPreviewMode('draft'); setNotice('La revisión se copió a un borrador nuevo; no se publicó.');
  });
  const previewContent = previewMode === 'published' ? record?.publishedContent : draft;
  const orderedMedia = [...media].filter(x => x.state !== 'WITHDRAWN' && (previewMode === 'draft' || x.state === 'PUBLISHED')).sort((a,b) => Number(b.primary)-Number(a.primary) || a.displayOrder-b.displayOrder);
  if (loading) return <section className="panel"><p role="status">Cargando ficha turística…</p></section>;
  return <section className="panel tourism-editor" aria-label={`Editor turístico de ${poi.name}`}>
    <div className="section-head"><div><h2>Ficha turística · {poi.name}</h2><p>Edición de contenido separada de identidad, ubicación y activación del POI.</p></div><button className="secondary" onClick={onClose}>Cerrar editor</button></div>
    {error && <p role="alert" className="alert error">{error}</p>}{notice && <p role="status" className="notice">{notice}</p>}
    {record && <div className="tourism-editor-grid">
      <div className="tourism-fields">
        <span className="pill">POI {poi.active ? 'ACTIVO' : 'DESACTIVADO'} · borrador v{record.draftVersion} · {record.draftState}</span>
        <label>Resumen para resultados<textarea maxLength={500} value={text(draft.summary)} onChange={e=>mutate('summary',e.target.value)} /></label>
        <label>Descripción turística<textarea maxLength={6000} value={text(draft.description)} onChange={e=>mutate('description',e.target.value)} /></label>
        <label>Historia<textarea maxLength={6000} value={text(draft.history)} onChange={e=>mutate('history',e.target.value)} /></label>
        <label>Importancia cultural, histórica o natural<textarea maxLength={4000} value={text(draft.significance)} onChange={e=>mutate('significance',e.target.value)} /></label>
        <label>Qué puede conocer el visitante<textarea maxLength={4000} value={text(draft.visitorExperience)} onChange={e=>mutate('visitorExperience',e.target.value)} /></label>
        <label>Datos interesantes, uno por línea<textarea value={(draft.interestingFacts ?? []).join('\n')} onChange={e=>setDraft(x=>({...x,interestingFacts:lines(e.target.value)}))} /></label>
        <label>Recomendaciones, una por línea<textarea value={(draft.recommendations ?? []).join('\n')} onChange={e=>setDraft(x=>({...x,recommendations:lines(e.target.value)}))} /></label>
        <label>Información práctica<textarea maxLength={4000} value={text(draft.practicalInfo)} onChange={e=>mutate('practicalInfo',e.target.value)} /></label>
        <label>Enlace oficial HTTPS<input type="url" value={text(draft.officialUrl)} onChange={e=>mutate('officialUrl',e.target.value)} placeholder="https://…" /></label>
        <label>Razón de auditoría<input value={reason} onChange={e=>setReason(e.target.value)} /></label>
        <div className="action-row"><button disabled={busy||!reason.trim()} onClick={()=>void save()}>Guardar borrador</button><button disabled={busy||!reason.trim()||dirty||record.draftState!=='DRAFT'} onClick={()=>void transition('submit')}>Enviar a revisión</button><button disabled={busy||!reason.trim()||record.draftState!=='PENDING_REVIEW'} onClick={()=>void transition('publish')}>Publicar versión</button></div>
      </div>
      <aside className="tourism-preview-wrap"><div className="section-head"><div><h3>Vista previa móvil</h3><p>{previewMode==='published'?'Contenido público vigente':'Vista de borrador'}{dirty?' · Cambios sin guardar':''}</p></div><select aria-label="Contenido de vista previa" value={previewMode} onChange={e=>setPreviewMode(e.target.value as 'draft'|'published')}><option value="draft">Borrador</option><option value="published" disabled={!record.publishedVersion}>Publicado</option></select></div>
        <article className="phone-preview"><div className="phone-screen">
          {orderedMedia.length>0 && <div className="preview-gallery">{orderedMedia.map(asset=>previews[asset.id] && <figure key={asset.id}><img src={previews[asset.id]} alt={asset.altText||'Fotografía del lugar'} /><figcaption>{asset.altText||'Sin texto alternativo'}{asset.attribution?` · ${asset.attribution}`:''}</figcaption></figure>)}</div>}
          <span className="pill">{poi.categoryName}</span><h2>{previewContent?.summary || poi.name}</h2>
          {previewContent?.description && <p>{previewContent.description}</p>}{previewContent?.history && <section><h4>Historia</h4><p>{previewContent.history}</p></section>}{previewContent?.significance && <section><h4>Importancia</h4><p>{previewContent.significance}</p></section>}{previewContent?.visitorExperience && <section><h4>Qué puedes conocer</h4><p>{previewContent.visitorExperience}</p></section>}
          {!!previewContent?.interestingFacts?.length && <section><h4>Datos interesantes</h4><ul>{previewContent.interestingFacts.map((fact,i)=><li key={i}>{fact}</li>)}</ul></section>}{!!previewContent?.recommendations?.length && <section><h4>Recomendaciones</h4><ul>{previewContent.recommendations.map((v,i)=><li key={i}>{v}</li>)}</ul></section>}{previewContent?.practicalInfo&&<section><h4>Información práctica</h4><p>{previewContent.practicalInfo}</p></section>}
          <h4>Horarios y actividades</h4>
          {operational ? <>
            <p>Zona horaria: {operational.timeZone}</p>
            {operational.weeklyHours.map(day=><p key={day.day}>{day.day}: {day.periods.length ? day.periods.map(period=>`${period.opensAt.slice(0,5)}–${period.closesAt.slice(0,5)}`).join(', ') : 'Cerrado'}</p>)}
            {operational.items.filter(item=>item.active).map(item=><section key={item.id}><strong>{item.type==='PROMOTION'?'Promoción':'Función / actividad'}: {item.title}</strong>{item.description&&<p>{item.description}</p>}{item.scheduleText&&<p>{item.scheduleText}</p>}{item.validFrom&&<p>Vigente desde {item.validFrom}{item.validUntil?` hasta ${item.validUntil}`:''}</p>}</section>)}
          </> : <p>No hay información operativa pública disponible.</p>}
          {previewContent?.officialUrl && <p>Enlace oficial: {previewContent.officialUrl}</p>}
          {record.publishedVersion && <small>Versión publicada v{record.publishedVersion} · {record.publishedAt}</small>}
        </div></article>
        <div className="action-row"><button className="secondary" onClick={onOpenMedia}>Administrar fotografías</button></div>
        <section className="revision-list"><h3>Historial y reversión</h3>{record.revisions.map(revision=><div key={revision.id}><span>v{revision.version} · {revision.state} · {revision.createdBy} · {revision.createdAt}</span><button className="secondary" disabled={busy||!reason.trim()} onClick={()=>void revert(revision.id)}>Crear borrador desde esta versión</button></div>)}</section>
      </aside>
    </div>}
  </section>;
}
