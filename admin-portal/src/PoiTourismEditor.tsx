import { useEffect, useMemo, useState } from 'react';
import type { AdminApi, AdminPoi, MediaAsset, PoiOperationalInfo } from './api';
import { PoiMediaGallery } from './PoiMediaGallery';
import { useAdminFeedback } from './AdminFeedback';

type Content = {
  summary: string | null; description: string | null; history: string | null;
  significance: string | null; visitorExperience: string | null;
  interestingFacts: string[]; recommendations: string[];
  practicalInfo: string | null; officialUrl: string | null;
};
type Revision = { id: string; version: number; state: string; createdBy: string; createdAt: string };
type CuratedPoi = { name: string; categoryCode: string; categoryName: string; description: string | null; sourceSystem: string | null; sourceRecordId: string | null; sourceUrl: string | null; license: string | null; attribution: string | null };
type AdminContent = { poiId: string; curatedPoi: CuratedPoi; draftVersion: number; draftState: string; draftContent: Content; publishedVersion: number | null; publishedContent: Content; publishedAt: string | null; revisions: Revision[] };
type ScalarContentKey = 'summary' | 'description' | 'history' | 'significance' | 'visitorExperience' | 'practicalInfo' | 'officialUrl';
const empty: Content = { summary: '', description: '', history: '', significance: '', visitorExperience: '', interestingFacts: [], recommendations: [], practicalInfo: '', officialUrl: '' };
const text = (value: string | null | undefined) => value ?? '';
const lines = (value: string) => value.split('\n').map(x => x.trim()).filter(Boolean);
const provisionalPattern = /\b(que\s+va\s+aqui|lorem\s+ipsum|placeholder|texto\s+provisional|por\s+definir|tbd)\b/i;
const hasProvisionalText = (content: Content) => [content.summary, content.description, content.history, content.significance, content.visitorExperience, content.practicalInfo, ...content.interestingFacts, ...content.recommendations].some(value => typeof value === 'string' && (provisionalPattern.test(value.normalize('NFD').replace(/[\u0300-\u036f]/g, '')) || value.trim().toLowerCase() === 'todo'));

export function PoiTourismEditor({ poi, api, onClose, onManageMedia }: { poi: AdminPoi; api: AdminApi; onClose: () => void; onManageMedia: () => void }) {
  const { showError, showSuccess } = useAdminFeedback();
  const [record, setRecord] = useState<AdminContent | null>(null);
  const [draft, setDraft] = useState<Content>(empty);
  const [media, setMedia] = useState<MediaAsset[]>([]);
  const [operational, setOperational] = useState<PoiOperationalInfo | null>(null);
  const [previews, setPreviews] = useState<Record<string, string>>({});
  const [reason, setReason] = useState('');
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState('');
  const [previewMode, setPreviewMode] = useState<'draft' | 'published'>('draft');
  const dirty = useMemo(() => record != null && JSON.stringify(draft) !== JSON.stringify(record.draftContent), [draft, record]);

  const load = async () => {
    setLoading(true);
    try {
      const [content, assets, operations] = await Promise.all([
        api.get<AdminContent>(`/api/v1/admin/pois/${poi.id}/content`),
        api.get<MediaAsset[]>(`/api/v1/admin/pois/${poi.id}/media`).catch(() => [] as MediaAsset[]),
        api.get<PoiOperationalInfo>(`/api/v1/admin/pois/${poi.id}/operational-info`).catch(() => null),
      ]);
      setRecord(content);
      setDraft(content.draftState === 'NONE' ? content.publishedContent ?? empty : content.draftContent ?? empty);
      setPreviewMode(content.publishedVersion || content.draftState !== 'NONE' ? 'draft' : 'published');
      setMedia(assets); setOperational(operations);
    } catch (e) { showError(e); }
    finally { setLoading(false); }
  };
  useEffect(() => { void load(); return () => Object.values(previews).forEach(URL.revokeObjectURL); }, [poi.id]);
  useEffect(() => {
    let cancelled = false;
    for (const item of media) {
      if (previews[item.id] || item.state === 'WITHDRAWN') continue;
      void api.getBlob(`/api/v1/admin/media/${item.id}/content`).then(blob => {
        if (!cancelled) setPreviews(current => ({ ...current, [item.id]: URL.createObjectURL(blob) }));
      }).catch(() => undefined);
    }
    return () => { cancelled = true; };
  }, [media, api]);

  const run = async (action: () => Promise<void>) => {
    setBusy(true); setNotice('');
    try { await action(); } catch (e) { showError(e); }
    finally { setBusy(false); }
  };
  const mutate = (key: ScalarContentKey, value: string) => setDraft(current => ({ ...current, [key]: value }));
  const save = () => run(async () => {
    if (!record || !reason.trim()) throw new Error('Indique una razón de auditoría.');
    const content: Content = { ...draft, interestingFacts: typeof draft.interestingFacts === 'string' ? lines(draft.interestingFacts as unknown as string) : draft.interestingFacts, recommendations: typeof draft.recommendations === 'string' ? lines(draft.recommendations as unknown as string) : draft.recommendations };
    const next = await api.put<AdminContent>(`/api/v1/admin/pois/${poi.id}/content/draft`, { expectedVersion: record.draftVersion, content, reason });
    setRecord(next); setDraft(next.draftContent); setPreviewMode('draft'); showSuccess('Borrador guardado correctamente. El contenido público no cambió.');
  });
  const transition = (action: 'submit' | 'publish') => run(async () => {
    if (!record || !reason.trim()) throw new Error('Indique una razón de auditoría.');
    const next = await api.post<AdminContent>(`/api/v1/admin/pois/${poi.id}/content/${action}`, { expectedVersion: record.draftVersion, reason });
    setRecord(next); setDraft(next.draftContent); setPreviewMode(action === 'publish' ? 'published' : 'draft');
    showSuccess(action === 'publish' ? 'Cambios publicados correctamente.' : 'Contenido enviado a revisión.');
  });
  const revert = (revisionId: string) => run(async () => {
    if (!record || !reason.trim()) throw new Error('Indique una razón de auditoría.');
    const next = await api.post<AdminContent>(`/api/v1/admin/pois/${poi.id}/content/revert`, { revisionId, expectedVersion: record.draftVersion, reason });
    setRecord(next); setDraft(next.draftContent); setPreviewMode('draft'); setNotice('La revisión se copió a un borrador nuevo; no se publicó.');
  });
  const initializeFromCurated = () => {
    if (!record) return;
    setDraft(current => ({ ...current, description: record.curatedPoi.description || '' }));
    setNotice('La descripción curada se copió al formulario local. No se guardará ni publicará hasta que usted lo solicite.');
  };
  const previewContent = previewMode === 'published'
    ? (record?.publishedVersion ? record.publishedContent : { ...empty, description: record?.curatedPoi.description || '' })
    : draft;
  const previewLabel = previewMode === 'published'
    ? (record?.publishedVersion ? 'Contenido público vigente' : 'Contenido público vigente · fallback curado')
    : 'Vista de borrador';
  const orderedMedia = [...media].filter(x => x.state !== 'WITHDRAWN' && (previewMode === 'draft' || x.state === 'PUBLISHED')).sort((a,b) => Number(b.primary)-Number(a.primary) || a.displayOrder-b.displayOrder);
  if (loading) return <section className="panel"><p role="status">Cargando ficha turística…</p></section>;

  return <section className="panel tourism-editor" aria-label={`Editor turístico de ${poi.name}`}>
    <div className="section-head"><div><h2>Ficha turística · {poi.name}</h2><p>Contenido turístico separado de identidad, ubicación y activación. Los cambios guardados no modifican el estado activo.</p></div><button className="secondary" onClick={onClose}>Cerrar editor</button></div>
    {notice && <p role="status" className="notice">{notice}</p>}
    {record && <div className="tourism-editor-grid">
      <div className="tourism-fields">
        <span className="pill">POI {poi.active ? 'ACTIVO' : 'DESACTIVADO'} · versión de trabajo v{record.draftVersion} · {record.draftState}{record.publishedVersion ? ` · publicado v${record.publishedVersion}` : ''}</span>
        {record.draftState === 'NONE' && !record.publishedVersion && <aside className="curated-source"><strong>Datos curados actuales · solo lectura</strong><p>{record.curatedPoi.description || 'No hay descripción curada disponible.'}</p><small>{record.curatedPoi.categoryName} · {record.curatedPoi.sourceSystem || 'Fuente no registrada'} · ficha {record.curatedPoi.sourceRecordId || '—'}</small><button type="button" className="secondary" disabled={busy || !record.curatedPoi.description} onClick={initializeFromCurated}>Iniciar borrador desde descripción curada</button></aside>}
        {record.publishedVersion && <p className="notice">La versión pública v{record.publishedVersion} sigue vigente. El borrador no se mostrará a visitantes hasta completar su revisión.</p>}
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
        {hasProvisionalText(draft) && <p role="alert" className="alert error">Se detectó texto provisional (por ejemplo, “Que va aquí”). Corríjalo antes de enviar a revisión.</p>}
        {!text(draft.description).trim() && <p role="status" className="alert">La descripción turística es obligatoria para enviar esta versión a revisión.</p>}
        <div className="action-row"><button disabled={busy||!reason.trim()} onClick={()=>void save()}>Guardar borrador</button><button disabled={busy||!reason.trim()||dirty||record.draftState!=='DRAFT'||!text(draft.description).trim()||hasProvisionalText(draft)} onClick={()=>void transition('submit')}>Enviar a revisión</button><button disabled={busy||!reason.trim()||record.draftState!=='PENDING_REVIEW'||!text(draft.description).trim()||hasProvisionalText(draft)} onClick={()=>void transition('publish')}>Publicar versión</button></div>
      </div>
      <aside className="tourism-preview-wrap">
        <div className="section-head"><div><h3>Vista previa móvil</h3><p>{previewLabel}{dirty?' · Cambios sin guardar':''}</p></div><select aria-label="Contenido de vista previa" value={previewMode} onChange={e=>setPreviewMode(e.target.value as 'draft'|'published')}><option value="draft">Borrador</option><option value="published">Contenido vigente</option></select></div>
        <article className="phone-preview"><div className="phone-screen">
          {orderedMedia.length>0 ? <div className="preview-gallery">{orderedMedia.map(asset=>previews[asset.id] && <figure key={asset.id}><img src={previews[asset.id]} alt={asset.altText||'Fotografía del lugar'} /><figcaption>{asset.altText||'Sin texto alternativo'}{asset.attribution?` · ${asset.attribution}`:''}</figcaption></figure>)}</div> : <div className="preview-image-placeholder" role="img" aria-label="Fotografía no disponible">Fotografía no disponible</div>}
          <h2>{poi.name}</h2><span className="pill">{poi.categoryName}</span>
          {previewContent?.summary && <p className="poi-summary">{previewContent.summary}</p>}
          {previewContent?.description && <p>{previewContent.description}</p>}
          {previewContent?.history && <section><h4>Historia</h4><p>{previewContent.history}</p></section>}
          {previewContent?.significance && <section><h4>Importancia cultural, histórica o natural</h4><p>{previewContent.significance}</p></section>}
          {previewContent?.visitorExperience && <section><h4>Qué puede conocer el visitante</h4><p>{previewContent.visitorExperience}</p></section>}
          {!!previewContent?.interestingFacts?.length && <section><h4>Datos interesantes</h4><ul>{previewContent.interestingFacts.map((fact,i)=><li key={i}>{fact}</li>)}</ul></section>}
          {!!previewContent?.recommendations?.length && <section><h4>Recomendaciones</h4><ul>{previewContent.recommendations.map((v,i)=><li key={i}>{v}</li>)}</ul></section>}
          {previewContent?.practicalInfo && <section><h4>Información práctica</h4><p>{previewContent.practicalInfo}</p></section>}
          {operational && <section><h4>Horarios, actividades y promociones</h4><p>Zona horaria: {operational.timeZone}</p>{operational.weeklyHours.some(day=>day.periods.length>0) ? operational.weeklyHours.map(day=><p key={day.day}>{day.day}: {day.periods.length ? day.periods.map(period=>`${period.opensAt.slice(0,5)}–${period.closesAt.slice(0,5)}`).join(', ') : 'Horario no informado'}</p>) : <p>Horario no informado.</p>}{operational.items.filter(item=>item.active).map(item=><section key={item.id}><strong>{item.type==='PROMOTION'?'Promoción':'Función / actividad'}: {item.title}</strong>{item.description&&<p>{item.description}</p>}{item.scheduleText&&<p>{item.scheduleText}</p>}{item.validFrom&&<p>Vigente desde {item.validFrom}{item.validUntil?` hasta ${item.validUntil}`:''}</p>}</section>)}</section>}
          {previewContent?.officialUrl && <p>Enlace oficial: {previewContent.officialUrl}</p>}
          <details className="preview-provenance"><summary>Fuentes y referencias</summary><p>{record.curatedPoi.attribution || record.curatedPoi.sourceSystem || 'Fuente no registrada'}</p>{record.curatedPoi.sourceUrl && <a href={record.curatedPoi.sourceUrl} target="_blank" rel="noreferrer">Consultar fuente</a>}<p>Licencia: {record.curatedPoi.license || 'No registrada'}</p></details>
          {record.publishedVersion && <small>Versión publicada v{record.publishedVersion} · {record.publishedAt}</small>}
        </div></article>
        <PoiMediaGallery poiId={poi.id} api={api} assets={media} previews={previews} onManage={onManageMedia} />
        <section className="revision-list"><h3>Historial y reversión</h3>{record.revisions.map(revision=><div key={revision.id}><span>v{revision.version} · {revision.state} · {revision.createdBy} · {revision.createdAt}</span><button className="secondary" disabled={busy||!reason.trim()} onClick={()=>void revert(revision.id)}>Crear borrador desde esta versión</button></div>)}</section>
      </aside>
    </div>}
  </section>;
}
