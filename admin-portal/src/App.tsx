import { useEffect, useMemo, useState } from 'react';
import type { ChangeEvent } from 'react';
import type { EditorialRecord, ImportBatch, ImportRecord, DuplicateCandidate, MediaAsset, PageResult } from './api';
import { AdminApi } from './api';
import { DestinationReviewPanel } from './DestinationReviewPanel';
import { adminUserManager, oidcConfigured } from './auth';

const apiBase = import.meta.env.VITE_ADMIN_API_BASE_URL ?? '';
const api = new AdminApi({ baseUrl: apiBase, getToken: async () => (await adminUserManager?.getUser())?.access_token ?? null });
const categories = ['WATERFALL','LAGOON','MOUNTAIN','FOREST','BEACH','MUSEUM','ARCHAEOLOGICAL_SITE','MONUMENT','HISTORIC_CHURCH','VIEWPOINT','FUEL','HEALTH','FOOD','LODGING','OTHER'];

export default function App() {
  const [user, setUser] = useState<Awaited<ReturnType<NonNullable<typeof adminUserManager>['getUser']>>>(null);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const [batches, setBatches] = useState<ImportBatch[]>([]);
  const [batchId, setBatchId] = useState('');
  const [imports, setImports] = useState<ImportRecord[]>([]);
  const [importPage, setImportPage] = useState({ page: 0, totalPages: 0 });
  const [records, setRecords] = useState<EditorialRecord[]>([]);
  const [recordPage, setRecordPage] = useState({ page: 0, totalPages: 0 });
  const [selected, setSelected] = useState<EditorialRecord | null>(null);
  const [duplicates, setDuplicates] = useState<DuplicateCandidate[]>([]);
  const [media, setMedia] = useState<MediaAsset[]>([]);
  const [category, setCategory] = useState(categories[0]);
  const [recordQuery, setRecordQuery] = useState('');
  const [mediaPoiId, setMediaPoiId] = useState('');
  const [mediaFile, setMediaFile] = useState<File | null>(null);
  const [author, setAuthor] = useState('');
  const [sourceUrl, setSourceUrl] = useState('');
  const [license, setLicense] = useState('');
  const [attribution, setAttribution] = useState('');
  const [rightsRef, setRightsRef] = useState('');
  const [editName,setEditName]=useState('');
  const [editDescription,setEditDescription]=useState('');
  const [editLatitude,setEditLatitude]=useState('');
  const [editLongitude,setEditLongitude]=useState('');
  const [editEvidence,setEditEvidence]=useState('');
  const [editLicense,setEditLicense]=useState('');
  const [editAttribution,setEditAttribution]=useState('');
  const [identityEvidence,setIdentityEvidence]=useState('');
  const [decisionEvidence,setDecisionEvidence]=useState('');
  const [reason, setReason] = useState('');
  const [mediaReason, setMediaReason] = useState('');
  const configured = oidcConfigured({ authority: import.meta.env.VITE_OIDC_AUTHORITY, clientId: import.meta.env.VITE_OIDC_CLIENT_ID });

  const run = async (task: () => Promise<void>) => {
    setBusy(true); setError('');
    try { await task(); } catch (e) { setError(e instanceof Error ? e.message : 'Error inesperado.'); }
    finally { setBusy(false); }
  };

  const loadRecords = async (page = 0, query = '') => {
    const result = await api.get<PageResult<EditorialRecord>>(`/api/v1/admin/records?page=${page}&size=50${query?`&q=${encodeURIComponent(query)}`:''}`);
    setRecords(result.content); setRecordPage({ page: result.page, totalPages: result.totalPages ?? Math.ceil(result.totalElements / result.size) });
  };
  const loadBatches = async () => setBatches(await api.get<ImportBatch[]>('/api/v1/admin/imports'));
  const loadImports = async (id: string, page = 0) => {
    setBatchId(id);
    const result = await api.get<PageResult<ImportRecord>>(`/api/v1/admin/imports/${id}/records?page=${page}&size=100`);
    setImports(result.content); setImportPage({ page: result.page, totalPages: result.totalPages ?? Math.ceil(result.totalElements / result.size) });
  };
  const selectRecord = async (record: EditorialRecord) => {
    setSelected(record);
    setEditName(record.name);setEditDescription(record.description??'');
    setEditLatitude(record.latitude?.toString()??'');setEditLongitude(record.longitude?.toString()??'');
    setEditEvidence(record.coordinateEvidence??'');setEditLicense(record.sourceLicense??'');
    setEditAttribution(record.sourceAttribution??'');setCategory(record.categoryCode);
    setIdentityEvidence(record.identityReviewEvidence??'');
    setDecisionEvidence('');
    setDuplicates(await api.get<DuplicateCandidate[]>(`/api/v1/admin/records/${record.id}/duplicates`));
  };

  useEffect(() => {
    let mounted = true;
    const init = async () => {
      if (!adminUserManager) return;
      if (window.location.pathname === '/auth/callback') {
        try { await adminUserManager.signinRedirectCallback(); window.history.replaceState({}, '', '/'); }
        catch (e) { if (mounted) setError(e instanceof Error ? e.message : 'Falló el retorno OIDC.'); }
      }
      const current = await adminUserManager.getUser();
      if (mounted) setUser(current);
      if (current && mounted) await run(async () => { await loadBatches(); await loadRecords(); });
    };
    void init();
    return () => { mounted = false; };
  }, []);

  useEffect(() => { if (user && batchId) void run(() => loadImports(batchId)); }, [user]);
  const selectedImportBatch = useMemo(() => batches.find((b) => b.id === batchId), [batches, batchId]);

  const createFromImport = (record: ImportRecord) => run(async () => {
    const created = await api.post<EditorialRecord>('/api/v1/admin/records', { importRecordId: record.id, categoryCode: category });
    await loadRecords(0); await selectRecord(created);
  });
  const createDestinationFromImport = (record: ImportRecord) => run(async () => {
    await api.post('/api/v1/admin/destination-records/from-import', {
      importRecordId: record.id, destinationType: record.sourceCategory || 'TOURIST_RESOURCE',
    });
    await loadImports(batchId, importPage.page);
  });

  const act = (path: string, body: object = { expectedVersion: selected?.version, reason, evidence: decisionEvidence }) => run(async () => {
    if (!selected) return;
    const updated = await api.post<EditorialRecord>(`/api/v1/admin/records/${selected.id}/${path}`, body);
    await loadRecords(recordPage.page); await selectRecord(updated);
  });

  const saveEditorial = () => run(async()=>{
    if(!selected) return;
    const updated=await api.put<EditorialRecord>(`/api/v1/admin/records/${selected.id}`,{
      expectedVersion:selected.version,reason,name:editName,description:editDescription,categoryCode:category,
      latitude:editLatitude===''?null:Number(editLatitude),longitude:editLongitude===''?null:Number(editLongitude),
      normalizationRule:selected.normalizationRule,coordinateEvidence:editEvidence,
      sourceLicense:editLicense,sourceAttribution:editAttribution,
    });
    await loadRecords(recordPage.page,recordQuery);await selectRecord(updated);
  });

  const uploadImage = () => run(async () => {
    if (!mediaFile || !mediaPoiId) throw new Error('Seleccione un POI y una imagen sintética/local autorizada.');
    const form = new FormData(); form.set('file', mediaFile); form.set('author', author); form.set('sourceUrl', sourceUrl);
    await api.upload<MediaAsset>(`/api/v1/admin/pois/${mediaPoiId}/media`, form);
    setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`));
  });

  if (!configured) return <main className="auth-screen"><div className="auth-card"><span className="eyebrow">GeoGuide AI · Catálogo</span><h1>Administración de recursos turísticos</h1><p>La integración OIDC no está configurada. La API administrativa permanece denegada por defecto.</p><p className="notice">Configure <code>VITE_OIDC_AUTHORITY</code>, <code>VITE_OIDC_CLIENT_ID</code> y el issuer backend provisionado. Esta pantalla no crea usuarios ni credenciales.</p></div></main>;
  if (!user) return <main className="auth-screen"><div className="auth-card"><span className="eyebrow">GeoGuide AI · Catálogo</span><h1>Administración de recursos turísticos</h1><p>Acceso mediante proveedor OIDC configurado. Los roles se validan en el backend.</p>{error&&<p className="error">{error}</p>}<button onClick={() => void adminUserManager?.signinRedirect()}>Iniciar sesión</button></div></main>;

  return <main className="shell">
    <header className="topbar"><div><span className="eyebrow">GeoGuide AI · Administración</span><h1>Catálogo turístico</h1></div><div className="user-box"><span>{user.profile.name ?? user.profile.sub}</span><button className="secondary" onClick={() => void adminUserManager?.signoutRedirect()}>Cerrar sesión</button></div></header>
    <div className="banner"><strong>Importación no equivale a publicación.</strong> Cada coordenada e identidad requiere revisión explícita. No se aprueba en lote por coincidencia numérica.</div>
    {error&&<div className="error alert" role="alert">{error}</div>}
    <section className="panel"><div className="section-head"><div><h2>Lotes MINCETUR</h2><p>Snapshots inmutables y registros en cuarentena.</p></div><button disabled={busy} onClick={() => void run(async()=>{await loadBatches();await loadRecords();})}>Actualizar</button></div>
      {batches.length===0?<p className="muted">No hay lotes importados en este entorno.</p>:<div className="batch-grid">{batches.map(b=><button className={`batch ${batchId===b.id?'selected':''}`} key={b.id} onClick={()=>void run(()=>loadImports(b.id))}><strong>{b.fileName}</strong><span>{b.total} filas · {b.candidates} candidatas · {b.quarantined} cuarentena</span><small>Sin asignar {b.unassignedCandidates} · borradores POI {b.poiDrafts} · destinos {b.destinationDrafts}</small><small>SHA-256 {b.sha256}</small></button>)}</div>}
      {selectedImportBatch&&<><h3>Registros del snapshot · corte {selectedImportBatch.cutoff??'sin confirmar'}</h3><div className="table-wrap"><table><thead><tr><th>Fila / código</th><th>Recurso / contexto</th><th>Coordenadas raw → candidatas</th><th>Estado de cola</th><th>Acciones independientes</th></tr></thead><tbody>{imports.map(r=><tr key={r.id}><td>{r.rowNumber} · {r.sourceRecordId}</td><td>{r.name}<small>{r.district}, {r.province}, {r.region}</small></td><td><small>{r.rawLatitude} / {r.rawLongitude}</small><small>{r.normalizedLatitude??'—'}, {r.normalizedLongitude??'—'}</small><small>{r.normalizationRule}</small></td><td><span className="pill">{r.reviewClassification}</span><small>{r.status}</small>{r.quarantineReason&&<small>{r.quarantineReason}</small>}</td><td>{r.status==='NORMALIZED_PENDING_REVIEW'?<div className="action-row">{!r.hasEditorialRecord?<><select aria-label="Categoría P3" value={category} onChange={(e)=>setCategory(e.target.value)}>{categories.map(c=><option key={c}>{c}</option>)}</select><button disabled={busy} onClick={()=>void createFromImport(r)}>Crear borrador POI</button></>:<span className="muted">Borrador POI existente</span>}{!r.hasDestinationEditorialRecord?<button disabled={busy} onClick={()=>void createDestinationFromImport(r)}>Crear borrador destino</button>:<span className="muted">Borrador destino existente</span>}</div>:<span className="muted">En cuarentena · no elegible para borrador</span>}</td></tr>)}</tbody></table></div><div className="action-row"><button className="secondary" disabled={importPage.page<=0||busy} onClick={()=>void run(()=>loadImports(batchId,importPage.page-1))}>Anterior</button><span>Página {importPage.page+1} de {Math.max(importPage.totalPages,1)} · {selectedImportBatch.total} filas</span><button className="secondary" disabled={importPage.page+1>=importPage.totalPages||busy} onClick={()=>void run(()=>loadImports(batchId,importPage.page+1))}>Siguiente</button></div></>}
    </section>
    <DestinationReviewPanel api={api} />
    <section className="panel"><div className="section-head"><div><h2>Revisión editorial</h2><p>Edición, identidad, geografía y aprobación por registro.</p></div><div className="inline"><input aria-label="Buscar" placeholder="Nombre o código" value={recordQuery} onChange={(e)=>setRecordQuery(e.target.value)} /><button onClick={()=>void run(()=>loadRecords(0,recordQuery))}>Buscar</button></div></div>
      <div className="editor-layout"><div className="record-list">{records.map(r=><button key={r.id} className={`record ${selected?.id===r.id?'selected':''}`} onClick={()=>void run(()=>selectRecord(r))}><strong>{r.name}</strong><span>{r.state} · geo {r.geographicReviewStatus} · identidad {r.identityReviewStatus}</span><small>{r.sourceRecordId??r.id}</small></button>)}<div className="action-row"><button className="secondary" disabled={recordPage.page<=0||busy} onClick={()=>void run(()=>loadRecords(recordPage.page-1,recordQuery))}>Anterior</button><span>{recordPage.page+1} / {Math.max(recordPage.totalPages,1)}</span><button className="secondary" disabled={recordPage.page+1>=recordPage.totalPages||busy} onClick={()=>void run(()=>loadRecords(recordPage.page+1,recordQuery))}>Siguiente</button></div></div>
        {selected?<article className="record-detail"><span className="pill">{selected.state} · v{selected.version}</span><h3>{selected.name}</h3><p>{selected.administrativeContext||'Sin contexto administrativo'}</p><p>Raw MINCETUR: {selected.rawLatitude??'—'} / {selected.rawLongitude??'—'}</p><p>Regla aplicada: {selected.normalizationRule??'Sin transformación registrada'}</p><p>Evidencia de validación: {selected.coordinateEvidence??'Pendiente'}</p><p>Fuente: {selected.sourceRecordId??'curado manual'} · {selected.sourceUrl??'URL no disponible'}</p><div className="media-form"><label>Nombre<input value={editName} onChange={(e)=>setEditName(e.target.value)} /></label><label>Categoría P3<select value={category} onChange={(e)=>setCategory(e.target.value)}>{categories.map(c=><option key={c}>{c}</option>)}</select></label><label>Latitud<input type="number" step="any" value={editLatitude} onChange={(e)=>setEditLatitude(e.target.value)} /></label><label>Longitud<input type="number" step="any" value={editLongitude} onChange={(e)=>setEditLongitude(e.target.value)} /></label><label>Descripción<input value={editDescription} onChange={(e)=>setEditDescription(e.target.value)} /></label><label>Evidencia geográfica<input value={editEvidence} onChange={(e)=>setEditEvidence(e.target.value)} /></label><label>Licencia de origen<input value={editLicense} onChange={(e)=>setEditLicense(e.target.value)} /></label><label>Atribución de origen<input value={editAttribution} onChange={(e)=>setEditAttribution(e.target.value)} /></label><button disabled={busy||!reason.trim()} onClick={()=>void saveEditorial()}>Guardar cambios y reiniciar revisiones</button></div><div className="dup-list"><strong>Coincidencias para revisión (no se fusionan automáticamente)</strong>{duplicates.length?duplicates.map(d=><p key={`${d.entityType}-${d.entityId}`}>{d.entityType} · {d.name} · {d.distanceMeters==null?'distancia no disponible':`${Math.round(d.distanceMeters)} m`} · {d.entityId}</p>):<p>No se detectan coincidencias por nombre exacto ni en radio de 1 km. El revisor debe comprobar antes de confirmar.</p>}</div><label>Razón de auditoría<input value={reason} onChange={(e)=>setReason(e.target.value)} required /></label><label>Evidencia de identidad<input value={identityEvidence} onChange={(e)=>setIdentityEvidence(e.target.value)} /></label><label>Evidencia de decisión editorial<input value={decisionEvidence} onChange={(e)=>setDecisionEvidence(e.target.value)} /></label><div className="action-row"><button disabled={busy||!reason.trim()} onClick={()=>void act('geographic-review',{expectedVersion:selected.version,approve:true,reason})}>Aprobar ubicación</button><button disabled={busy||!reason.trim()||!identityEvidence.trim()} onClick={()=>void act('identity-review',{expectedVersion:selected.version,noDuplicate:true,reason,evidence:identityEvidence})}>Confirmar sin duplicado</button><button className="secondary" disabled={busy||!reason.trim()||!identityEvidence.trim()} onClick={()=>void act('identity-review',{expectedVersion:selected.version,noDuplicate:false,reason,evidence:identityEvidence})}>Marcar posible duplicado</button><button disabled={busy||!reason.trim()||!decisionEvidence.trim()||selected.geographicReviewStatus!=='APPROVED'||selected.identityReviewStatus!=='NO_DUPLICATE'||!selected.identityReviewEvidence||!selected.sourceLicense||!selected.sourceAttribution} onClick={()=>void act('submit',{expectedVersion:selected.version,reason,evidence:decisionEvidence})}>Enviar a revisión</button><button disabled={busy||!reason.trim()||!decisionEvidence.trim()||selected.state!=='PENDING_REVIEW'||selected.geographicReviewStatus!=='APPROVED'||selected.identityReviewStatus!=='NO_DUPLICATE'||!selected.identityReviewEvidence||!selected.sourceLicense||!selected.sourceAttribution} onClick={()=>void act('approve',{expectedVersion:selected.version,reason,evidence:decisionEvidence})}>Aprobar publicación</button><button className="danger" disabled={busy||!reason.trim()||!decisionEvidence.trim()} onClick={()=>void act('reject',{expectedVersion:selected.version,reason,evidence:decisionEvidence})}>Rechazar</button><button className="danger" disabled={busy||!reason.trim()||!decisionEvidence.trim()} onClick={()=>void act('archive',{expectedVersion:selected.version,reason,evidence:decisionEvidence})}>Archivar</button></div></article>:<div className="empty">Seleccione un borrador o importe uno desde un lote.</div>}</div>
    </section>
    <section className="panel"><h2>Media privada del POI</h2><p>La carga se mantiene privada hasta documentar derechos y pasar revisión. Use archivos sintéticos para pruebas.</p><div className="media-form"><label>UUID de POI<input value={mediaPoiId} onChange={(e)=>setMediaPoiId(e.target.value)} placeholder="UUID existente y activo" /></label><label>Autor<input value={author} onChange={(e)=>setAuthor(e.target.value)} /></label><label>Referencia de fuente<input value={sourceUrl} onChange={(e)=>setSourceUrl(e.target.value)} placeholder="URL o referencia de fixture" /></label><label>Archivo JPEG/PNG<input type="file" accept="image/jpeg,image/png" onChange={(e:ChangeEvent<HTMLInputElement>)=>setMediaFile(e.target.files?.[0]??null)} /></label><button disabled={busy} onClick={()=>void uploadImage()}>Subir borrador privado</button><button className="secondary" disabled={busy||!mediaPoiId} onClick={()=>void run(async()=>setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`)))}>Consultar media</button></div><div className="media-form rights"><label>Razón de auditoría de media<input value={mediaReason} onChange={(e)=>setMediaReason(e.target.value)} required /></label><label>Licencia<input value={license} onChange={(e)=>setLicense(e.target.value)} /></label><label>Atribución<input value={attribution} onChange={(e)=>setAttribution(e.target.value)} /></label><label>Evidencia de derechos<input value={rightsRef} onChange={(e)=>setRightsRef(e.target.value)} /></label></div><div className="media-grid">{media.map(m=><article className="media-item" key={m.id}><strong>{m.contentType} · {m.width}×{m.height}</strong><p>{m.state} · derechos {m.rightsStatus}{m.primary?' · principal':''}</p><small>{m.id} · {m.sha256}</small><div className="action-row"><button disabled={busy||!mediaReason.trim()} onClick={()=>void run(async()=>{await api.patch(`/api/v1/admin/media/${m.id}/rights`,{expectedVersion:m.version,license,attribution,evidenceReference:rightsRef,reason:mediaReason});setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`));})}>Guardar derechos</button><button disabled={busy||!mediaReason.trim()} onClick={()=>void run(async()=>{await api.post(`/api/v1/admin/media/${m.id}/submit`,{expectedVersion:m.version,reason:mediaReason});setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`));})}>Enviar</button><button disabled={busy||!mediaReason.trim()} onClick={()=>void run(async()=>{await api.post(`/api/v1/admin/media/${m.id}/publish`,{expectedVersion:m.version,reason:mediaReason,makePrimary:true});setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`));})}>Publicar principal</button><button disabled={busy||!mediaReason.trim()} onClick={()=>void run(async()=>{await api.post(`/api/v1/admin/media/${m.id}/withdraw`,{expectedVersion:m.version,reason:mediaReason});setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`));})}>Retirar</button></div></article>)}</div></section>
    <footer>API administrativa protegida por OIDC/JWT y RBAC. No se cargan mapas ni fotografías externas en este portal.</footer>
  </main>;
}
