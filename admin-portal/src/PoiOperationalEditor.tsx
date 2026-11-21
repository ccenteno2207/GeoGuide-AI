import { useEffect, useState } from 'react';
import type { AdminApi, AdminPoi, PoiOperationalInfo } from './api';

const days = [
  ['MONDAY', 'Lunes'], ['TUESDAY', 'Martes'], ['WEDNESDAY', 'Miércoles'],
  ['THURSDAY', 'Jueves'], ['FRIDAY', 'Viernes'], ['SATURDAY', 'Sábado'], ['SUNDAY', 'Domingo'],
] as const;
type OperationalItem = PoiOperationalInfo['items'][number];

function rangesToText(periods: Array<{ opensAt: string; closesAt: string }>): string {
  return periods.map((period) => `${period.opensAt.slice(0, 5)}-${period.closesAt.slice(0, 5)}`).join('; ');
}

function textToRanges(value: string): Array<{ opensAt: string; closesAt: string }> {
  if (!value.trim()) return [];
  return value.split(';').map((part) => {
    const match = part.trim().match(/^([01]\d|2[0-3]):[0-5]\d\s*-\s*([01]\d|2[0-3]):[0-5]\d$/);
    if (!match) throw new Error('Use intervalos HH:mm-HH:mm separados por punto y coma. Deje vacío el día cerrado.');
    const [opensAt, closesAt] = part.trim().split(/\s*-\s*/);
    if (closesAt <= opensAt) throw new Error('La hora de cierre debe ser posterior a la apertura.');
    return { opensAt: `${opensAt}:00`, closesAt: `${closesAt}:00` };
  });
}

export function PoiOperationalEditor({ poi, api, onClose }: { poi: AdminPoi; api: AdminApi; onClose: () => void }) {
  const [profile, setProfile] = useState<PoiOperationalInfo | null>(null);
  const [timeZone, setTimeZone] = useState('America/Lima');
  const [hours, setHours] = useState<Record<string, string>>({});
  const [items, setItems] = useState<OperationalItem[]>([]);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    let mounted = true;
    void api.get<PoiOperationalInfo>(`/api/v1/admin/pois/${poi.id}/operational-info`).then((result) => {
      if (!mounted) return;
      setProfile(result);
      setTimeZone(result.timeZone);
      setHours(Object.fromEntries(result.weeklyHours.map((day) => [day.day, rangesToText(day.periods)])));
      setItems(result.items);
    }).catch((cause: unknown) => {
      if (mounted) setError(cause instanceof Error ? cause.message : 'No se pudieron cargar los datos operativos.');
    });
    return () => { mounted = false; };
  }, [api, poi.id]);

  const updateItem = (id: string, changes: Partial<OperationalItem>) => setItems((current) => current.map((item) => item.id === id ? { ...item, ...changes } : item));
  const addItem = (type: OperationalItem['type']) => setItems((current) => [...current, {
    id: crypto.randomUUID(), type, title: '', description: null, scheduleText: null,
    validFrom: null, validUntil: null, terms: null, active: true,
  }]);

  const save = async () => {
    if (!profile) return;
    setBusy(true); setError(''); setSaved(false);
    try {
      const updated = await api.put<PoiOperationalInfo>(`/api/v1/admin/pois/${poi.id}/operational-info`, {
        expectedVersion: profile.version,
        timeZone: timeZone.trim(),
        weeklyHours: days.map(([day]) => ({ day, periods: textToRanges(hours[day] ?? '') })),
        items,
      });
      setProfile(updated); setSaved(true);
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'No se pudieron guardar los datos operativos.');
    } finally { setBusy(false); }
  };

  return <section className="panel operational-editor" aria-label={`Información operativa de ${poi.name}`}>
    <div className="section-head"><div><h3>Información operativa · {poi.name}</h3><p>Se actualiza directamente y queda registrada en historial. No reinicia las revisiones ni desactiva el POI.</p></div><button className="secondary" onClick={onClose}>Cerrar</button></div>
    {error && <p className="error" role="alert">{error}</p>}
    {!profile ? <p className="muted">Cargando información operativa…</p> : <>
      <label>Zona horaria<input aria-label="Zona horaria operativa" value={timeZone} onChange={(event) => setTimeZone(event.target.value)} /></label>
      <h4>Horario semanal</h4>
      <p className="muted">Escriba uno o más intervalos HH:mm-HH:mm, separados por punto y coma. Deje vacío el día cerrado.</p>
      <div className="operational-hours">{days.map(([day, label]) => <label key={day}>{label}<input aria-label={`Horario ${label}`} placeholder="09:00-13:00; 15:00-18:00" value={hours[day] ?? ''} onChange={(event) => setHours((current) => ({ ...current, [day]: event.target.value }))} /></label>)}</div>
      <h4>Funciones y promociones</h4>
      <div className="action-row"><button className="secondary" disabled={busy} onClick={() => addItem('PERFORMANCE')}>Agregar función</button><button className="secondary" disabled={busy} onClick={() => addItem('PROMOTION')}>Agregar promoción</button></div>
      {items.map((item) => <fieldset className="operational-item" key={item.id} disabled={busy}>
        <div className="inline"><label>Tipo<select aria-label="Tipo de información operativa" value={item.type} onChange={(event) => updateItem(item.id, { type: event.target.value as OperationalItem['type'] })}><option value="PERFORMANCE">Función / actividad</option><option value="PROMOTION">Promoción</option></select></label><label>Título<input aria-label="Título de función o promoción" maxLength={200} value={item.title} onChange={(event) => updateItem(item.id, { title: event.target.value })} /></label><label>Vigente<input type="checkbox" aria-label="Información operativa vigente" checked={item.active} onChange={(event) => updateItem(item.id, { active: event.target.checked })} /></label></div>
        <div className="inline"><label>Descripción<textarea aria-label="Descripción de función o promoción" maxLength={2000} value={item.description ?? ''} onChange={(event) => updateItem(item.id, { description: event.target.value || null })} /></label><label>Fechas / días / horas<input aria-label="Fechas o programación" maxLength={500} value={item.scheduleText ?? ''} onChange={(event) => updateItem(item.id, { scheduleText: event.target.value || null })} /></label></div>
        <div className="inline"><label>Válida desde<input type="date" aria-label="Válida desde" value={item.validFrom ?? ''} onChange={(event) => updateItem(item.id, { validFrom: event.target.value || null })} /></label><label>Válida hasta<input type="date" aria-label="Válida hasta" value={item.validUntil ?? ''} onChange={(event) => updateItem(item.id, { validUntil: event.target.value || null })} /></label><label>Condiciones<input aria-label="Condiciones de promoción" maxLength={1000} value={item.terms ?? ''} onChange={(event) => updateItem(item.id, { terms: event.target.value || null })} /></label><button className="danger" type="button" onClick={() => setItems((current) => current.filter((entry) => entry.id !== item.id))}>Quitar</button></div>
      </fieldset>)}
      <button disabled={busy} onClick={() => void save()}>{busy ? 'Guardando…' : 'Guardar información operativa'}</button>
      {saved && <p role="status">Información actualizada. El POI continúa {poi.active ? 'activo' : 'desactivado'}; la actualización no requiere aprobación editorial.</p>}
    </>}
  </section>;
}
