import { createContext, useCallback, useContext, useEffect, useRef, useState } from 'react';
import type { ReactNode } from 'react';
import { AdminApiError } from './api';

type FieldIssue = { field: string; code: string; message: string };
type ErrorNotice = { title: string; message: string; fields: FieldIssue[]; status?: number; requestId?: string; retry?: () => void; signIn?: () => void | Promise<void> };
type FeedbackContextValue = { showError: (error: unknown, options?: { retry?: () => void; signIn?: () => void }) => void; showSuccess: (message: string) => void };
const FeedbackContext = createContext<FeedbackContextValue>({ showError: () => undefined, showSuccess: () => undefined });
const fieldLabels: Record<string, string> = { file: 'Archivo de fotografía', author: 'Autor o titular de derechos', sourceUrl: 'Referencia de fuente', altText: 'Texto alternativo', license: 'Licencia', attribution: 'Atribución', evidenceReference: 'Evidencia de autorización de uso', poiId: 'POI seleccionado', reason: 'Razón de auditoría' };

function describeError(error: unknown, options?: { retry?: () => void; signIn?: () => void | Promise<void> }): ErrorNotice {
  const api = error instanceof AdminApiError ? error : null;
  const status = api?.status;
  if (!status) return {
    title: error instanceof TypeError ? 'No se pudo conectar con el servidor' : 'No se pudo completar la operación',
    message: error instanceof TypeError
      ? 'Comprueba tu conexión e inténtalo de nuevo cuando el servicio esté disponible.'
      : 'Ocurrió un problema inesperado. Vuelve a intentarlo o informa al equipo de soporte.',
    fields: [], retry: options?.retry,
  };
  if (status === 401 && api?.code === 'SESSION_RENEWED_WRITE_NOT_RETRIED') return {
    title: 'La sesión se renovó; comprueba el cambio',
    message: 'Por seguridad, la escritura no se repitió automáticamente. Actualiza la información y verifica si el cambio quedó guardado antes de intentarlo otra vez.',
    fields: [], status, requestId: api?.requestId,
  };
  const defaults: Record<number, [string, string]> = {
    400: ['Revisa la información ingresada', 'Hay datos que no cumplen el formato o los requisitos. Corrige los campos indicados y vuelve a intentarlo.'],
    401: ['Tu sesión ha expirado', 'Vuelve a iniciar sesión. Los cambios que ingresaste se conservaron en este formulario.'],
    403: ['No tienes permiso para esta operación', 'Solicita el rol o permiso correspondiente al administrador del portal.'],
    404: ['El recurso ya no está disponible', 'Actualiza la información y vuelve a seleccionar el elemento.'],
    409: ['La información cambió', 'Recarga el recurso para obtener su versión actual. Revisa los cambios antes de volver a guardar.'],
    413: ['El archivo supera el tamaño permitido', 'Selecciona un JPEG o PNG que no supere el límite indicado en el formulario.'],
  };
  const [title, message] = defaults[status] ?? (status >= 500
    ? ['El servicio está temporalmente indisponible', 'Inténtalo de nuevo más tarde. No se muestran detalles internos del servidor.']
    : ['No se pudo completar la operación', 'Revisa la información e inténtalo de nuevo.']);
  return { title, message, fields: api?.fieldErrors ?? [], status, requestId: api?.requestId, retry: options?.retry, signIn: status === 401 ? options?.signIn : undefined };
}

export function AdminFeedbackProvider({ children, onSignIn }: { children: ReactNode; onSignIn?: () => void | Promise<void> }) {
  const [notice, setNotice] = useState<ErrorNotice | null>(null);
  const [success, setSuccess] = useState('');
  const dialogRef = useRef<HTMLDivElement>(null);
  const returnFocus = useRef<HTMLElement | null>(null);
  const showError = useCallback((error: unknown, options?: { retry?: () => void; signIn?: () => void | Promise<void> }) => {
    returnFocus.current = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    setNotice(describeError(error, { ...options, signIn: options?.signIn ?? onSignIn }));
    setSuccess('');
  }, [onSignIn]);
  const showSuccess = useCallback((message: string) => { setNotice(null); setSuccess(message); window.setTimeout(() => setSuccess(''), 3500); }, []);
  const close = useCallback(() => { setNotice(null); window.setTimeout(() => { if (returnFocus.current?.isConnected) returnFocus.current.focus(); }, 0); }, []);

  useEffect(() => {
    if (!notice) return;
    const dialog = dialogRef.current;
    dialog?.querySelector<HTMLElement>('button')?.focus();
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && !notice.retry) { event.preventDefault(); close(); }
      if (event.key !== 'Tab' || !dialog) return;
      const focusable = Array.from(dialog.querySelectorAll<HTMLElement>('button:not([disabled]),a[href],[tabindex="0"]'));
      if (!focusable.length) return;
      const first = focusable[0], last = focusable[focusable.length - 1];
      if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
      else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
    };
    document.addEventListener('keydown', onKeyDown);
    return () => document.removeEventListener('keydown', onKeyDown);
  }, [notice, close]);

  return <FeedbackContext.Provider value={{ showError, showSuccess }}>
    {children}
    {success && <div className="admin-toast" role="status" aria-live="polite">{success}</div>}
    {notice && <div className="admin-modal-backdrop"><section className="admin-error-modal" role="alertdialog" aria-modal="true" aria-labelledby="admin-error-title" aria-describedby="admin-error-description" ref={dialogRef} tabIndex={-1}>
      <h2 id="admin-error-title">{notice.title}</h2><p id="admin-error-description">{notice.message}</p>
      {notice.fields.length > 0 && <section aria-label="Campos que debes revisar"><h3>Campos por corregir</h3><ul>{notice.fields.map((field, index) => <li key={`${field.field}-${index}`}><strong>{fieldLabels[field.field] ?? 'Información del formulario'}</strong>: {field.message}</li>)}</ul></section>}
      {notice.requestId && <small>Referencia de soporte: {notice.requestId}</small>}
      {notice.status && <details><summary>Detalles técnicos</summary><small>HTTP {notice.status}{notice.fields.length ? ` · ${notice.fields.map(field => field.code).join(', ')}` : ''}</small></details>}
      <div className="action-row"><button type="button" onClick={close}>Entendido</button>{notice.signIn && <button type="button" onClick={() => void notice.signIn?.()}>Iniciar sesión</button>}{notice.retry && <button type="button" className="secondary" onClick={() => { const retry = notice.retry; close(); retry?.(); }}>Reintentar</button>}</div>
    </section></div>}
  </FeedbackContext.Provider>;
}

export function useAdminFeedback(): FeedbackContextValue {
  return useContext(FeedbackContext);
}
