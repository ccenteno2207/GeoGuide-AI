import { useEffect, useMemo, useState } from 'react';
import type { ChangeEvent } from 'react';
import type { EditorialRecord, ImportBatch, ImportRecord, DuplicateCandidate, MediaAsset, PageResult, AdminPoi } from './api';
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
  const [pois, setPois] = useState<AdminPoi[]>([]);
  const [poiQuery, setPoiQuery] = useState('');
  const [poiCategory, setPoiCategory] = useState('');
  const [poiActive, setPoiActive] = useState('');
  const [activationHistory, setActivationHistory] = useState<Array<{ actor: string; action: string; reason: string; evidence: string; previousActive: boolean; nextActive: boolean; occurredAt: string }>>([]);
  const [activationHistoryPoi, setActivationHistoryPoi] = useState('');
  const [recordPage, setRecordPage] = useState({ page: 0, totalPages: 0 });
  const [selected, setSelected] = useState<EditorialRecord | null>(null);
  const [duplicates, setDuplicates] = useState<DuplicateCandidate[]>([]);
  const [media, setMedia] = useState<MediaAsset[]>([]);
  const [category, setCategory] = useState('');
  const [importCategorySelections, setImportCategorySelections] = useState<Record<string, string>>({});
  const [recordQuery, setRecordQuery] = useState('');
  const [recordLocality, setRecordLocality] = useState('');
  const [recordCategory, setRecordCategory] = useState('');
  const [recordState, setRecordState] = useState('');
  const [importQuery, setImportQuery] = useState('');
  const [importLocality, setImportLocality] = useState('');
  const [importCategory, setImportCategory] = useState('');
  const [importStatus, setImportStatus] = useState('');
  const [manualName, setManualName] = useState('');
  const [manualLocality, setManualLocality] = useState('');
  const [manualDescription, setManualDescription] = useState('');
  const [mediaPoiId, setMediaPoiId] = useState('');
  const [mediaFile, setMediaFile] = useState<File | null>(null);
  const [author, setAuthor] = useState('');
  const [sourceUrl, setSourceUrl] = useState('');
  const [license, setLicense] = useState('');
  const [attribution, setAttribution] = useState('');
  const [rightsRef, setRightsRef] = useState('');
  const [editName,setEditName]=useState('');
  const [editLocality,setEditLocality]=useState('');
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

  const loadRecords = async (page = 0, query = recordQuery) => {
    const params = new URLSearchParams({ page: String(page), size: '50' });
    if (query.trim()) params.set('q', query.trim());
    if (recordLocality.trim()) params.set('locality', recordLocality.trim());
    if (recordCategory) params.set('category', recordCategory);
    if (recordState) params.set('state', recordState);
    const result = await api.get<PageResult<EditorialRecord>>(`/api/v1/admin/records?${params}`);
    setRecords(result.content); setRecordPage({ page: result.page, totalPages: result.totalPages ?? Math.ceil(result.totalElements / result.size) });
  };
  const loadBatches = async () => setBatches(await api.get<ImportBatch[]>('/api/v1/admin/imports'));
  const loadPois = async () => {
    const params = new URLSearchParams({ page: '0', size: '50' });
    if (poiQuery.trim()) params.set('q', poiQuery.trim());
    if (poiCategory) params.set('category', poiCategory);
    if (poiActive) params.set('active', poiActive);
    const result = await api.get<PageResult<AdminPoi>>(`/api/v1/admin/pois?${params}`);
    setPois(result.content);
  };
  const loadImports = async (id: string, page = 0) => {
    setBatchId(id);
    const params = new URLSearchParams({ page: String(page), size: '100' });
    if (importStatus) params.set('status', importStatus);
    if (importQuery.trim()) params.set('q', importQuery.trim());
    if (importLocality.trim()) params.set('locality', importLocality.trim());
    if (importCategory.trim()) params.set('category', importCategory.trim());
    const result = await api.get<PageResult<ImportRecord>>(`/api/v1/admin/imports/${id}/records?${params}`);
    setImports(result.content); setImportPage({ page: result.page, totalPages: result.totalPages ?? Math.ceil(result.totalElements / result.size) });
  };
  const selectRecord = async (record: EditorialRecord) => {
    setSelected(record);
    setEditName(record.name);setEditDescription(record.description??'');
    setEditLocality(record.administrativeContext??'');
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
      const callbackPath = `${import.meta.env.BASE_URL.replace(/\/$/, '')}/auth/callback`;
      if (window.location.pathname === callbackPath) {
        try { await adminUserManager.signinRedirectCallback(); window.history.replaceState({}, '', import.meta.env.BASE_URL); }
        catch (e) { if (mounted) setError(e instanceof Error ? e.message : 'Falló el retorno OIDC.'); }
      }
      const current = await adminUserManager.getUser();
      if (mounted) setUser(current);
      if (current && mounted) await run(async () => { await loadBatches(); await loadRecords(); await loadPois(); });
    };
    void init();
    return () => { mounted = false; };
  }, []);

  useEffect(() => { if (user && batchId) void run(() => loadImports(batchId)); }, [user]);
  const selectedImportBatch = useMemo(() => batches.find((b) => b.id === batchId), [batches, batchId]);

  const createFromImport = (record: ImportRecord) => run(async () => {
    const categoryCode = importCategorySelections[record.id] ?? record.suggestedPoiCategoryCode;
    if (!categoryCode) throw new Error('Seleccione una categoría P3 para este candidato antes de crear el borrador.');
    const created = await api.post<EditorialRecord>('/api/v1/admin/records', { importRecordId: record.id, categoryCode });
    setImportCategorySelections((current) => {
      const next = { ...current };
      delete next[record.id];
      return next;
    });
    await loadRecords(0); await selectRecord(created);
  });
  const createManualDraft = () => run(async () => {
    const created = await api.post<EditorialRecord>('/api/v1/admin/records', {
      name: manualName.trim(), administrativeContext: manualLocality.trim() || null,
      description: manualDescription.trim() || null, categoryCode: category,
      latitude: null, longitude: null,
    });
    setManualName(''); setManualLocality(''); setManualDescription('');
    await loadRecords(0); await selectRecord(created);
  });
  const createDestinationFromImport = (record: ImportRecord) => run(async () => {
    await api.post('/api/v1/admin/destination-records/from-import', {
      importRecordId: record.id, destinationType: record.sourceCategory || 'TOURIST_RESOURCE',
    });
    await loadImports(batchId, importPage.page);
  });

  const refreshAfterEditorialConflict = async (recordId: string, serverMessage: string): Promise<never> => {
    const current = await api.get<EditorialRecord>(`/api/v1/admin/records/${recordId}`);
    setSelected(current);
    const serverDetail = serverMessage.replace(/^API 409:\s*/, '');
    if (current.state === 'ARCHIVED') {
      throw new Error(`HTTP 409: el expediente está ARCHIVED (v${current.version}); el flujo vigente no permite editarlo, revisarlo ni aprobarlo. Detalle del servidor: ${serverDetail} Los valores no guardados del formulario se conservaron. No cree otro expediente para este código MINCETUR.`);
    }
    throw new Error(`HTTP 409: ${serverDetail} El expediente se recargó en v${current.version}; revise su estado antes de continuar. Los valores no guardados del formulario se conservaron.`);
  };

  const act = (path: string, body: object = { expectedVersion: selected?.version, reason, evidence: decisionEvidence }) => run(async () => {
    if (!selected) return;
    try {
      const updated = await api.post<EditorialRecord>(`/api/v1/admin/records/${selected.id}/${path}`, body);
      await loadRecords(recordPage.page); await selectRecord(updated);
    } catch (error) {
      if (error instanceof Error && error.message.startsWith('API 409:')) {
        try { await refreshAfterEditorialConflict(selected.id, error.message); } catch (refreshedError) {
          if (refreshedError instanceof Error && refreshedError.message.startsWith('HTTP 409:')) throw refreshedError;
        }
      }
      throw error;
    }
  });

  const changeRequest = (poi: AdminPoi) => run(async () => {
    const draft = await api.post<EditorialRecord>(`/api/v1/admin/records/change-requests/${poi.id}`, {});
    await loadRecords(0); await selectRecord(draft);
  });
  const activatePoi = (poi: AdminPoi) => run(async () => {
    const updated = await api.post<AdminPoi>(`/api/v1/admin/pois/${poi.id}/activation`, {
      expectedUpdatedAt: poi.updatedAt, active: !poi.active, reason, evidence: decisionEvidence,
    });
    setPois((current) => current.map((item) => item.id === updated.id ? updated : item));
  });
  const loadActivationHistory = (poi: AdminPoi) => run(async () => {
    setActivationHistory(await api.get(`/api/v1/admin/pois/${poi.id}/activation-history`));
    setActivationHistoryPoi(poi.id);
  });

  const saveEditorial = () => run(async()=>{
    if(!selected) return;
    try {
      const updated=await api.put<EditorialRecord>(`/api/v1/admin/records/${selected.id}`,{
        expectedVersion:selected.version,reason,name:editName,description:editDescription,categoryCode:category,
        administrativeContext:editLocality.trim()||null,
        latitude:editLatitude===''?null:Number(editLatitude),longitude:editLongitude===''?null:Number(editLongitude),
        normalizationRule:selected.normalizationRule,coordinateEvidence:editEvidence,
        sourceLicense:editLicense,sourceAttribution:editAttribution,
      });
      await loadRecords(recordPage.page,recordQuery);await selectRecord(updated);
    } catch (error) {
      if (error instanceof Error && error.message.startsWith('API 409:')) {
        try { await refreshAfterEditorialConflict(selected.id, error.message); } catch (refreshedError) {
          if (refreshedError instanceof Error && refreshedError.message.startsWith('HTTP 409:')) throw refreshedError;
        }
      }
      throw error;
    }
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
    <section className="panel"><div className="section-head"><div><h2>POIs existentes</h2><p>Inventario curado con provenance. La activación se audita y requiere administrador.</p></div><button disabled={busy} onClick={() => void run(loadPois)}>Actualizar</button></div><div className="inline filters"><label>Nombre<input aria-label="Buscar POIs existentes" value={poiQuery} onChange={e=>setPoiQuery(e.target.value)} /></label><label>Categoría<select aria-label="Categoría de POI" value={poiCategory} onChange={e=>setPoiCategory(e.target.value)}><option value="">Todas</option>{categories.map(value=><option key={value}>{value}</option>)}</select></label><label>Estado<select aria-label="Estado de POI" value={poiActive} onChange={e=>setPoiActive(e.target.value)}><option value="">Todos</option><option value="true">Activo</option><option value="false">Desactivado</option></select></label><button disabled={busy} onClick={()=>void run(loadPois)}>Filtrar POIs</button></div><label>Razón para activación o cambio<input aria-label="Razón de cambio de POI" value={reason} onChange={e=>setReason(e.target.value)} /></label><label>Evidencia de activación o cambio<input aria-label="Evidencia de cambio de POI" value={decisionEvidence} onChange={e=>setDecisionEvidence(e.target.value)} /></label>{pois.length===0?<p className="muted">No hay POIs para los filtros seleccionados.</p>:<div className="table-wrap"><table><thead><tr><th>POI</th><th>Categoría / estado</th><th>Provenance</th><th>Acciones</th></tr></thead><tbody>{pois.map(poi=><tr key={poi.id}><td>{poi.name}<small>{poi.id}</small></td><td>{poi.categoryName} ({poi.categoryCode}) · {poi.active?'ACTIVO':'DESACTIVADO'}</td><td>{poi.sourceSystem??'Sin provenance'} · {poi.sourceRecordId??'—'}<small>{poi.license??'Licencia no registrada'} · {poi.attribution??'Atribución no registrada'}</small></td><td><div className="action-row"><button disabled={busy||!reason.trim()||!decisionEvidence.trim()} onClick={()=>void activatePoi(poi)}>{poi.active?'Desactivar':'Activar'}</button><button disabled={busy} onClick={()=>void changeRequest(poi)}>Solicitar cambio editorial</button><button className="secondary" disabled={busy} onClick={()=>void loadActivationHistory(poi)}>Historial</button></div></td></tr>)}</tbody></table></div>}{activationHistoryPoi&&<div className="dup-list"><strong>Historial de activación · {activationHistoryPoi}</strong>{activationHistory.length?activationHistory.map((entry,index)=><p key={`${entry.occurredAt}-${index}`}>{entry.occurredAt} · {entry.actor} · {entry.action} · {entry.previousActive?'activo':'inactivo'} → {entry.nextActive?'activo':'inactivo'} · {entry.reason} · {entry.evidence}</p>):<p>Sin eventos de activación.</p>}</div>}</section>    <section className="panel"><div className="section-head"><div><h2>Lotes MINCETUR</h2><p>Snapshots inmutables y registros en cuarentena.</p></div><button disabled={busy} onClick={() => void run(async()=>{await loadBatches();await loadRecords();})}>Actualizar</button></div>
      {batches.length===0?<p className="muted">No hay lotes importados en este entorno.</p>:<div className="batch-grid">{batches.map(b=><button className={`batch ${batchId===b.id?'selected':''}`} key={b.id} onClick={()=>void run(()=>loadImports(b.id))}><strong>{b.fileName}</strong><span>{b.total} filas · {b.candidates} candidatas · {b.quarantined} cuarentena</span><small>Sin asignar {b.unassignedCandidates} · borradores POI {b.poiDrafts} · destinos {b.destinationDrafts}</small><small>SHA-256 {b.sha256}</small></button>)}</div>}
      {selectedImportBatch&&<><h3>Registros del snapshot · corte {selectedImportBatch.cutoff??'sin confirmar'}</h3><div className="inline filters"><label>Nombre o código<input aria-label="Buscar candidatos" value={importQuery} onChange={e=>setImportQuery(e.target.value)} /></label><label>Localidad<input aria-label="Localidad de candidato" value={importLocality} onChange={e=>setImportLocality(e.target.value)} /></label><label>Categoría MINCETUR<input aria-label="Categoría de candidato" value={importCategory} onChange={e=>setImportCategory(e.target.value)} /></label><label>Estado<select aria-label="Estado de candidato" value={importStatus} onChange={e=>setImportStatus(e.target.value)}><option value="">Todos</option>{['NORMALIZED_PENDING_REVIEW','COORDINATE_FORMAT_AMBIGUOUS','COORDINATE_MAPPING_UNVERIFIED','DUPLICATE_SOURCE_ID','MALFORMED_ROW'].map(s=><option key={s}>{s}</option>)}</select></label><button disabled={busy} onClick={()=>void run(()=>loadImports(batchId,0))}>Filtrar candidatos</button></div><div className="table-wrap"><table><thead><tr><th>Fila / código</th><th>Recurso / contexto</th><th>Coordenadas raw → candidatas</th><th>Estado de cola</th><th>Acciones independientes</th></tr></thead><tbody>{imports.map(r=><tr key={r.id}><td>{r.rowNumber} · {r.sourceRecordId}</td><td>{r.name}<small>{r.district}, {r.province}, {r.region}</small></td><td><small>{r.rawLatitude} / {r.rawLongitude}</small><small>{r.normalizedLatitude??'—'}, {r.normalizedLongitude??'—'}</small><small>{r.normalizationRule}</small></td><td><span className="pill">{r.reviewClassification}</span><small>{r.status}</small>{r.quarantineReason&&<small>{r.quarantineReason}</small>}</td><td>{r.status==='NORMALIZED_PENDING_REVIEW'?<div className="action-row">{!r.hasEditorialRecord?<><select aria-label={`Categoría P3 ${r.sourceRecordId}`} value={importCategorySelections[r.id]??r.suggestedPoiCategoryCode??''} onChange={(e)=>setImportCategorySelections((current)=>({...current,[r.id]:e.target.value}))}><option value="">Seleccione categoría P3</option>{categories.map(c=><option key={c}>{c}</option>)}</select>{r.suggestedPoiCategoryCode&&<small>Mapeo exacto por tipo MINCETUR: {r.sourceType} → {r.suggestedPoiCategoryCode}</small>}<button disabled={busy||!(importCategorySelections[r.id]??r.suggestedPoiCategoryCode)} onClick={()=>void createFromImport(r)}>Crear borrador POI</button></>:<span className="muted">Borrador POI existente</span>}{!r.hasDestinationEditorialRecord?<button disabled={busy} onClick={()=>void createDestinationFromImport(r)}>Crear borrador destino</button>:<span className="muted">Borrador destino existente</span>}</div>:<span className="muted">En cuarentena · no elegible para borrador</span>}</td></tr>)}</tbody></table></div><div className="action-row"><button className="secondary" disabled={importPage.page<=0||busy} onClick={()=>void run(()=>loadImports(batchId,importPage.page-1))}>Anterior</button><span>Página {importPage.page+1} de {Math.max(importPage.totalPages,1)} · {selectedImportBatch.total} filas</span><button className="secondary" disabled={importPage.page+1>=importPage.totalPages||busy} onClick={()=>void run(()=>loadImports(batchId,importPage.page+1))}>Siguiente</button></div></>}
    </section>
    <DestinationReviewPanel api={api} />
    <section className="panel"><div className="section-head"><div><h2>Revisión editorial</h2><p>Aprobación y activación son decisiones independientes; un POI aprobado permanece oculto hasta su activación administrativa.</p></div></div><div className="inline filters"><label>Nombre o código<input aria-label="Buscar" placeholder="Nombre o código" value={recordQuery} onChange={e=>setRecordQuery(e.target.value)} /></label><label>Localidad<input aria-label="Localidad editorial" value={recordLocality} onChange={e=>setRecordLocality(e.target.value)} /></label><label>Categoría<select aria-label="Categoría editorial" value={recordCategory} onChange={e=>setRecordCategory(e.target.value)}><option value="">Todas</option>{categories.map(c=><option key={c}>{c}</option>)}</select></label><label>Estado<select aria-label="Estado editorial" value={recordState} onChange={e=>setRecordState(e.target.value)}><option value="">Todos</option>{['DRAFT','PENDING_REVIEW','OBSERVED','APPROVED','SUSPENDED','PUBLISHED','REJECTED','ARCHIVED'].map(s=><option key={s}>{s}</option>)}</select></label><button onClick={()=>void run(()=>loadRecords(0))}>Filtrar catálogo</button></div><div className="media-form"><h3>Crear POI manual</h3><p>Se crea como borrador privado, sin coordenadas ni publicación.</p><label>Nombre<input aria-label="Nombre del POI manual" value={manualName} onChange={e=>setManualName(e.target.value)} required /></label><label>Localidad o contexto administrativo<input aria-label="Localidad del POI manual" value={manualLocality} onChange={e=>setManualLocality(e.target.value)} /></label><label>Descripción<input aria-label="Descripción del POI manual" value={manualDescription} onChange={e=>setManualDescription(e.target.value)} /></label><label>Categoría<select aria-label="Categoría del POI manual" value={category} onChange={e=>setCategory(e.target.value)}><option value="">Seleccione categoría P3</option>{categories.map(c=><option key={c}>{c}</option>)}</select></label><button disabled={busy||!manualName.trim()||!category} onClick={()=>void createManualDraft()}>Crear borrador deshabilitado para Rutea</button></div>
      <div className="editor-layout"><div className="record-list">{records.map(r=><button key={r.id} className={`record ${selected?.id===r.id?'selected':''}`} onClick={()=>void run(()=>selectRecord(r))}><strong>{r.name}</strong><span>{r.state} · geo {r.geographicReviewStatus} · identidad {r.identityReviewStatus}</span><small>{r.sourceRecordId??r.id}</small></button>)}<div className="action-row"><button className="secondary" disabled={recordPage.page<=0||busy} onClick={()=>void run(()=>loadRecords(recordPage.page-1,recordQuery))}>Anterior</button><span>{recordPage.page+1} / {Math.max(recordPage.totalPages,1)}</span><button className="secondary" disabled={recordPage.page+1>=recordPage.totalPages||busy} onClick={()=>void run(()=>loadRecords(recordPage.page+1,recordQuery))}>Siguiente</button></div></div>
        {selected?<article className="record-detail"><span className="pill">{selected.state} · {selected.active ? 'ACTIVO' : 'DESACTIVADO'} · v{selected.version}</span><h3>{selected.name}</h3><p>{selected.administrativeContext||'Sin contexto administrativo'}</p><p>Raw MINCETUR: {selected.rawLatitude??'—'} / {selected.rawLongitude??'—'}</p><p>Regla aplicada: {selected.normalizationRule??'Sin transformación registrada'}</p><p>Evidencia de validación: {selected.coordinateEvidence??'Pendiente'}</p><p>Fuente: {selected.sourceRecordId??'curado manual'} · {selected.sourceUrl??'URL no disponible'}</p><>{selected.state === 'ARCHIVED' && <p role="status" className="error alert">Este expediente está ARCHIVED. El flujo editorial vigente no incluye reapertura; no se permiten edición, revisión, aprobación ni otro archivado. Su vínculo con MINCETUR {selected.sourceRecordId ?? '—'} se conserva: no cree otro expediente para este código.</p>}<fieldset className="editorial-controls" disabled={selected.state === 'ARCHIVED'}><div className="media-form"><label>Nombre<input aria-label="Nombre editorial" value={editName} onChange={(e)=>setEditName(e.target.value)} /></label><label>Localidad / contexto<input aria-label="Localidad del registro" value={editLocality} onChange={e=>setEditLocality(e.target.value)} /></label><label>Categoría P3<select value={category} onChange={(e)=>setCategory(e.target.value)}>{categories.map(c=><option key={c}>{c}</option>)}</select></label><label>Latitud<input type="number" step="any" value={editLatitude} onChange={(e)=>setEditLatitude(e.target.value)} /></label><label>Longitud<input type="number" step="any" value={editLongitude} onChange={(e)=>setEditLongitude(e.target.value)} /></label><label>Descripción<input value={editDescription} onChange={(e)=>setEditDescription(e.target.value)} /></label><label>Evidencia geográfica<input value={editEvidence} onChange={(e)=>setEditEvidence(e.target.value)} /></label><label>Licencia de origen<input value={editLicense} onChange={(e)=>setEditLicense(e.target.value)} /></label><label>Atribución de origen<input value={editAttribution} onChange={(e)=>setEditAttribution(e.target.value)} /></label><button disabled={busy||!reason.trim()} onClick={()=>void saveEditorial()}>Guardar cambios y reiniciar revisiones</button></div><div className="dup-list"><strong>Coincidencias para revisión (no se fusionan automáticamente)</strong>{duplicates.length?duplicates.map(d=><p key={`${d.entityType}-${d.entityId}`}>{d.entityType} · {d.name} · {d.distanceMeters==null?'distancia no disponible':`${Math.round(d.distanceMeters)} m`} · {d.entityId}</p>):<p>No se detectan coincidencias por nombre exacto ni en radio de 1 km. El revisor debe comprobar antes de confirmar.</p>}</div><label>Razón de auditoría<input value={reason} onChange={(e)=>setReason(e.target.value)} required /></label><label>Evidencia de identidad<input value={identityEvidence} onChange={(e)=>setIdentityEvidence(e.target.value)} /></label><label>Evidencia de decisión editorial<input value={decisionEvidence} onChange={(e)=>setDecisionEvidence(e.target.value)} /></label><div className="action-row"><button disabled={busy||!reason.trim()} onClick={()=>void act('geographic-review',{expectedVersion:selected.version,approve:true,reason})}>Aprobar ubicación</button><button disabled={busy||!reason.trim()||!identityEvidence.trim()} onClick={()=>void act('identity-review',{expectedVersion:selected.version,noDuplicate:true,reason,evidence:identityEvidence})}>Confirmar sin duplicado</button><button className="secondary" disabled={busy||!reason.trim()||!identityEvidence.trim()} onClick={()=>void act('identity-review',{expectedVersion:selected.version,noDuplicate:false,reason,evidence:identityEvidence})}>Marcar posible duplicado</button><button disabled={busy||!reason.trim()||!decisionEvidence.trim()||selected.geographicReviewStatus!=='APPROVED'||selected.identityReviewStatus!=='NO_DUPLICATE'||!selected.identityReviewEvidence||!selected.sourceLicense||!selected.sourceAttribution} onClick={()=>void act('submit',{expectedVersion:selected.version,reason,evidence:decisionEvidence})}>Enviar a revisión</button><button disabled={busy||!reason.trim()||!decisionEvidence.trim()||selected.state!=='PENDING_REVIEW'||selected.geographicReviewStatus!=='APPROVED'||selected.identityReviewStatus!=='NO_DUPLICATE'||!selected.identityReviewEvidence||!selected.sourceLicense||!selected.sourceAttribution} onClick={()=>void act('approve',{expectedVersion:selected.version,reason,evidence:decisionEvidence})}>Aprobar (queda deshabilitado)</button><button disabled={busy||!reason.trim()||!decisionEvidence.trim()||selected.state!=='PENDING_REVIEW'} onClick={()=>void act('observe',{expectedVersion:selected.version,reason,evidence:decisionEvidence})}>Observar</button><button disabled={busy||!reason.trim()||!decisionEvidence.trim()||selected.state!=='APPROVED'||selected.active} onClick={()=>void act('activation',{expectedVersion:selected.version,active:true,reason,evidence:decisionEvidence})}>Activar para Rutea</button><button className="danger" disabled={busy||!reason.trim()||!decisionEvidence.trim()||!selected.active} onClick={()=>void act('activation',{expectedVersion:selected.version,active:false,reason,evidence:decisionEvidence})}>Desactivar para Rutea</button><button className="danger" disabled={busy||!reason.trim()||!decisionEvidence.trim()} onClick={()=>void act('reject',{expectedVersion:selected.version,reason,evidence:decisionEvidence})}>Rechazar</button><button className="danger" disabled={busy||!reason.trim()||!decisionEvidence.trim()} onClick={()=>void act('archive',{expectedVersion:selected.version,reason,evidence:decisionEvidence})}>Archivar</button></div></fieldset></></article>:<div className="empty">Seleccione un borrador o importe uno desde un lote.</div>}</div>
    </section>
    <section className="panel"><h2>Media privada del POI</h2><p>La carga se mantiene privada hasta documentar derechos y pasar revisión. Use archivos sintéticos para pruebas.</p><div className="media-form"><label>UUID de POI<input value={mediaPoiId} onChange={(e)=>setMediaPoiId(e.target.value)} placeholder="UUID existente y activo" /></label><label>Autor<input value={author} onChange={(e)=>setAuthor(e.target.value)} /></label><label>Referencia de fuente<input value={sourceUrl} onChange={(e)=>setSourceUrl(e.target.value)} placeholder="URL o referencia de fixture" /></label><label>Archivo JPEG/PNG<input type="file" accept="image/jpeg,image/png" onChange={(e:ChangeEvent<HTMLInputElement>)=>setMediaFile(e.target.files?.[0]??null)} /></label><button disabled={busy} onClick={()=>void uploadImage()}>Subir borrador privado</button><button className="secondary" disabled={busy||!mediaPoiId} onClick={()=>void run(async()=>setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`)))}>Consultar media</button></div><div className="media-form rights"><label>Razón de auditoría de media<input value={mediaReason} onChange={(e)=>setMediaReason(e.target.value)} required /></label><label>Licencia<input value={license} onChange={(e)=>setLicense(e.target.value)} /></label><label>Atribución<input value={attribution} onChange={(e)=>setAttribution(e.target.value)} /></label><label>Evidencia de derechos<input value={rightsRef} onChange={(e)=>setRightsRef(e.target.value)} /></label></div><div className="media-grid">{media.map(m=><article className="media-item" key={m.id}><strong>{m.contentType} · {m.width}×{m.height}</strong><p>{m.state} · derechos {m.rightsStatus}{m.primary?' · principal':''}</p><small>{m.id} · {m.sha256}</small><div className="action-row"><button disabled={busy||!mediaReason.trim()} onClick={()=>void run(async()=>{await api.patch(`/api/v1/admin/media/${m.id}/rights`,{expectedVersion:m.version,license,attribution,evidenceReference:rightsRef,reason:mediaReason});setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`));})}>Guardar derechos</button><button disabled={busy||!mediaReason.trim()} onClick={()=>void run(async()=>{await api.post(`/api/v1/admin/media/${m.id}/submit`,{expectedVersion:m.version,reason:mediaReason});setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`));})}>Enviar</button><button disabled={busy||!mediaReason.trim()} onClick={()=>void run(async()=>{await api.post(`/api/v1/admin/media/${m.id}/publish`,{expectedVersion:m.version,reason:mediaReason,makePrimary:true});setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`));})}>Publicar principal</button><button disabled={busy||!mediaReason.trim()} onClick={()=>void run(async()=>{await api.post(`/api/v1/admin/media/${m.id}/withdraw`,{expectedVersion:m.version,reason:mediaReason});setMedia(await api.get<MediaAsset[]>(`/api/v1/admin/pois/${mediaPoiId}/media`));})}>Retirar</button></div></article>)}</div></section>
    <footer>API administrativa protegida por OIDC/JWT y RBAC. No se cargan mapas ni fotografías externas en este portal.</footer>
  </main>;
}
