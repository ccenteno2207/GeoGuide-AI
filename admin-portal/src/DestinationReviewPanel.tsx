import { useEffect, useState } from 'react';
import type { PageResult } from './api';
import { AdminApi } from './api';

type DestinationRecord = {
  id: string; importRecordId: string | null; sourceRecordId: string | null;
  canonicalName: string; destinationType: string; administrativeContext: string | null;
  latitude: number | null; longitude: number | null; rawLatitude: string | null; rawLongitude: string | null;
  normalizationRule: string | null; coordinateEvidence: string | null; sourceUrl: string | null;
  sourceLicense: string | null; sourceAttribution: string | null; geographicReviewStatus: string;
  identityReviewStatus: string; identityReviewEvidence: string | null; accessReviewStatus: string;
  accessReviewEvidence: string | null;
  state: string; publishedDestinationId: string | null; version: number;
};
type Duplicate = { entityType: string; entityId: string; name: string; distanceMeters: number | null };
type Relationship = { id: string; destinationId: string; destinationName: string; poiId: string;
  poiName: string; relationshipType: string; status: string; version: number };

export function DestinationReviewPanel({ api }: { api: AdminApi }) {
  const [rows, setRows] = useState<DestinationRecord[]>([]);
  const [selected, setSelected] = useState<DestinationRecord | null>(null);
  const [duplicates, setDuplicates] = useState<Duplicate[]>([]);
  const [relationships, setRelationships] = useState<Relationship[]>([]);
  const [destinationId, setDestinationId] = useState('');
  const [poiId, setPoiId] = useState('');
  const [relationshipType, setRelationshipType] = useState('SAME_RESOURCE');
  const [relationshipReason, setRelationshipReason] = useState('');
  const [relationshipEvidence, setRelationshipEvidence] = useState('');
  const [name, setName] = useState('');
  const [type, setType] = useState('TOURIST_RESOURCE');
  const [context, setContext] = useState('');
  const [latitude, setLatitude] = useState('');
  const [longitude, setLongitude] = useState('');
  const [coordinateEvidence, setCoordinateEvidence] = useState('');
  const [identityEvidence, setIdentityEvidence] = useState('');
  const [accessEvidence, setAccessEvidence] = useState('');
  const [decisionEvidence, setDecisionEvidence] = useState('');
  const [sourceUrl, setSourceUrl] = useState('');
  const [license, setLicense] = useState('');
  const [attribution, setAttribution] = useState('');
  const [reason, setReason] = useState('');
  const [query, setQuery] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  const load = async () => {
    const page = await api.get<PageResult<DestinationRecord>>(`/api/v1/admin/destination-records?size=100${query ? `&q=${encodeURIComponent(query)}` : ''}`);
    setRows(page.content);
    setRelationships((await api.get<PageResult<Relationship>>('/api/v1/admin/destination-poi-relationships?size=100')).content);
  };
  useEffect(() => { void load().catch((e: unknown) => setError(e instanceof Error ? e.message : 'Error al cargar destinos.')); }, []);

  const run = async (action: () => Promise<void>) => {
    setBusy(true); setError('');
    try { await action(); await load(); }
    catch (e) { setError(e instanceof Error ? e.message : 'Error administrativo.'); }
    finally { setBusy(false); }
  };
  const select = async (row: DestinationRecord) => {
    setSelected(row); setName(row.canonicalName); setType(row.destinationType);
    setContext(row.administrativeContext ?? ''); setLatitude(row.latitude?.toString() ?? '');
    setLongitude(row.longitude?.toString() ?? ''); setCoordinateEvidence(row.coordinateEvidence ?? '');
    setIdentityEvidence(row.identityReviewEvidence ?? '');
    setDecisionEvidence('');
    setAccessEvidence(row.accessReviewEvidence ?? ''); setSourceUrl(row.sourceUrl ?? '');
    setLicense(row.sourceLicense ?? ''); setAttribution(row.sourceAttribution ?? '');
    setDuplicates(await api.get<Duplicate[]>(`/api/v1/admin/destination-records/${row.id}/duplicates`));
  };
  const act = (path: string, body: object) => run(async () => {
    if (!selected) return;
    const next = await api.post<DestinationRecord>(`/api/v1/admin/destination-records/${selected.id}/${path}`, body);
    setSelected(next);
  });
  const save = () => run(async () => {
    if (!selected) return;
    const next = await api.put<DestinationRecord>(`/api/v1/admin/destination-records/${selected.id}`, {
      expectedVersion: selected.version, reason, canonicalName: name, destinationType: type,
      administrativeContext: context, latitude: latitude === '' ? null : Number(latitude),
      longitude: longitude === '' ? null : Number(longitude), normalizationRule: selected.normalizationRule,
      coordinateEvidence, sourceUrl, sourceLicense: license, sourceAttribution: attribution,
    });
    setSelected(next);
  });

  return <section className="panel">
    <div className="section-head"><div><h2>Revisión de destinos y acceso vial</h2>
      <p>La elegibilidad de destino es independiente de POI. La ubicación del atractivo no demuestra un acceso navegable.</p></div>
      <div className="inline"><input aria-label="Buscar destinos" value={query} onChange={e => setQuery(e.target.value)} placeholder="Nombre o código" />
        <button disabled={busy} onClick={() => void run(load)}>Buscar</button></div></div>
    {error && <div className="error alert" role="alert">{error}</div>}
    <div className="editor-layout"><div className="record-list">
      {rows.map(row => <button key={row.id} className={`record ${selected?.id === row.id ? 'selected' : ''}`} onClick={() => void select(row)}>
        <strong>{row.canonicalName}</strong><span>{row.state} · geo {row.geographicReviewStatus} · identidad {row.identityReviewStatus} · acceso {row.accessReviewStatus}</span>
        <small>{row.sourceRecordId ?? row.id}</small></button>)}
      {rows.length === 0 && <p className="muted">No hay borradores de destino en este entorno.</p>}
    </div>
    {selected ? <article className="record-detail"><span className="pill">{selected.state} · v{selected.version}</span>
      <h3>{selected.canonicalName}</h3><p>{selected.administrativeContext ?? 'Contexto pendiente'}</p>
      <p>Raw: {selected.rawLatitude ?? '—'} / {selected.rawLongitude ?? '—'} · candidato: {selected.latitude ?? '—'}, {selected.longitude ?? '—'}</p>
      <p>Regla: {selected.normalizationRule ?? 'sin transformación'} · {selected.coordinateEvidence ?? 'sin evidencia'}</p>
      <div className="media-form">
        <label>Nombre<input value={name} onChange={e => setName(e.target.value)} /></label>
        <label>Tipo de destino<input value={type} onChange={e => setType(e.target.value)} /></label>
        <label>Región / provincia / distrito<input value={context} onChange={e => setContext(e.target.value)} /></label>
        <label>Latitud<input type="number" step="any" value={latitude} onChange={e => setLatitude(e.target.value)} /></label>
        <label>Longitud<input type="number" step="any" value={longitude} onChange={e => setLongitude(e.target.value)} /></label>
        <label>Evidencia de ubicación<input value={coordinateEvidence} onChange={e => setCoordinateEvidence(e.target.value)} /></label>
        <label>Evidencia de acceso/llegada<input value={accessEvidence} onChange={e => setAccessEvidence(e.target.value)} /></label>
        <label>URL de fuente<input value={sourceUrl} onChange={e => setSourceUrl(e.target.value)} /></label>
        <label>Licencia<input value={license} onChange={e => setLicense(e.target.value)} /></label>
        <label>Atribución<input value={attribution} onChange={e => setAttribution(e.target.value)} /></label>
        <button disabled={busy || !reason.trim()} onClick={() => void save()}>Guardar; reiniciar revisiones</button>
      </div>
      <div className="dup-list"><strong>Posibles coincidencias (solo indicios)</strong>{duplicates.length ? duplicates.map(d =>
        <p key={`${d.entityType}-${d.entityId}`}>{d.entityType}: {d.name} · {d.distanceMeters == null ? '—' : `${Math.round(d.distanceMeters)} m`}</p>)
        : <p>No aparecen coincidencias; requiere revisión, no es prueba de entidad nueva.</p>}</div>
      <label>Razón de auditoría<input value={reason} onChange={e => setReason(e.target.value)} required /></label>
      <div className="action-row">
        <button disabled={busy || !reason.trim()} onClick={() => void act('geographic-review', { expectedVersion: selected.version, approve: true, reason })}>Aprobar geografía</button>
        <label>Evidencia de identidad<input value={identityEvidence} onChange={e => setIdentityEvidence(e.target.value)} /></label>
        <button disabled={busy || !reason.trim() || !identityEvidence.trim()} onClick={() => void act('identity-review', { expectedVersion: selected.version, noDuplicate: true, reason, evidence: identityEvidence })}>Confirmar sin duplicado</button>
        <button className="secondary" disabled={busy || !reason.trim() || !identityEvidence.trim()} onClick={() => void act('identity-review', { expectedVersion: selected.version, noDuplicate: false, reason, evidence: identityEvidence })}>Marcar identidad coincidente</button>
        <button disabled={busy || !reason.trim() || !accessEvidence.trim()} onClick={() => void act('access-review', { expectedVersion: selected.version, approve: true, reason, evidence: accessEvidence })}>Aprobar acceso</button>
        <label>Evidencia de decisión editorial<input value={decisionEvidence} onChange={e => setDecisionEvidence(e.target.value)} /></label>
        <button disabled={busy || !reason.trim() || !decisionEvidence.trim() || selected.geographicReviewStatus !== 'APPROVED' || selected.identityReviewStatus !== 'NO_DUPLICATE' || selected.accessReviewStatus !== 'APPROVED' || !selected.sourceLicense || !selected.sourceAttribution} onClick={() => void act('submit', { expectedVersion: selected.version, reason, evidence: decisionEvidence })}>Enviar a revisión</button>
        <button disabled={busy || !reason.trim() || !decisionEvidence.trim() || selected.state !== 'PENDING_REVIEW' || selected.geographicReviewStatus !== 'APPROVED' || selected.identityReviewStatus !== 'NO_DUPLICATE' || selected.accessReviewStatus !== 'APPROVED' || !selected.sourceLicense || !selected.sourceAttribution} onClick={() => void act('approve', { expectedVersion: selected.version, reason, evidence: decisionEvidence })}>Publicar destino</button>
        <button className="danger" disabled={busy || !reason.trim() || !decisionEvidence.trim()} onClick={() => void act('reject', { expectedVersion: selected.version, reason, evidence: decisionEvidence })}>Rechazar</button>
        <button className="danger" disabled={busy || !reason.trim() || !decisionEvidence.trim()} onClick={() => void act('archive', { expectedVersion: selected.version, reason, evidence: decisionEvidence })}>Archivar</button>
      </div>
    </article> : <div className="empty">Seleccione un borrador para revisar.</div>}</div>
    <hr /><h3>Relaciones auditables destino ↔ POI</h3><p>Crear una relación pendiente no publica ni sincroniza ubicaciones o estados.</p>
    <div className="media-form"><label>UUID de destino<input value={destinationId} onChange={e => setDestinationId(e.target.value)} /></label>
      <label>UUID de POI<input value={poiId} onChange={e => setPoiId(e.target.value)} /></label>
      <label>Tipo<select value={relationshipType} onChange={e => setRelationshipType(e.target.value)}><option>SAME_RESOURCE</option><option>RELATED_RESOURCE</option></select></label>
      <label>Razón<input value={relationshipReason} onChange={e => setRelationshipReason(e.target.value)} /></label>
      <label>Evidencia<input value={relationshipEvidence} onChange={e => setRelationshipEvidence(e.target.value)} /></label>
      <button disabled={busy || !destinationId || !poiId || !relationshipReason.trim() || !relationshipEvidence.trim()}
        onClick={() => void run(async () => { await api.post('/api/v1/admin/destination-poi-relationships', { destinationId, poiId,
          relationshipType, reason: relationshipReason, evidence: relationshipEvidence }); })}>Crear relación pendiente</button>
    </div>
    <div className="media-grid">{relationships.map(r => <article className="media-item" key={r.id}>
      <strong>{r.relationshipType} · {r.status}</strong><p>{r.destinationName} ↔ {r.poiName}</p><small>{r.id} · v{r.version}</small>
      {r.status === 'PENDING' && <div className="action-row">
        <button disabled={busy || !relationshipReason.trim() || !relationshipEvidence.trim()} onClick={() => void run(async () => {
          await api.post(`/api/v1/admin/destination-poi-relationships/${r.id}/approve`, { expectedVersion: r.version, reason: relationshipReason, evidence: relationshipEvidence }); })}>Aprobar relación</button>
        <button className="danger" disabled={busy || !relationshipReason.trim() || !relationshipEvidence.trim()} onClick={() => void run(async () => {
          await api.post(`/api/v1/admin/destination-poi-relationships/${r.id}/reject`, { expectedVersion: r.version, reason: relationshipReason, evidence: relationshipEvidence }); })}>Rechazar relación</button>
      </div>}</article>)}</div>
  </section>;
}
