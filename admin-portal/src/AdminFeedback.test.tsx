import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { AdminFeedbackProvider, useAdminFeedback } from './AdminFeedback';
import { AdminApiError } from './api';

afterEach(cleanup);

function Trigger({ error }: { error: unknown }) {
  const { showError } = useAdminFeedback();
  return <button onClick={(event) => { showError(error); event.currentTarget.dataset.triggered = 'true'; }}>Ejecutar</button>;
}

describe('central administration feedback', () => {
  it('shows a centered accessible dialog with corrective field guidance and restores focus', async () => {
    const error = new AdminApiError(400, 'SOURCE_FORMAT_INVALID', 'Datos inválidos.', [
      { field: 'sourceUrl', code: 'INVALID_FORMAT', message: 'Usa una URL HTTPS con dominio.' },
    ]);
    render(<AdminFeedbackProvider><Trigger error={error} /></AdminFeedbackProvider>);
    const trigger = screen.getByRole('button', { name: 'Ejecutar' });
    trigger.focus(); fireEvent.click(trigger);
    const dialog = screen.getByRole('alertdialog', { name: 'Revisa la información ingresada' });
    expect(dialog.textContent).toContain('Referencia de fuente');
    expect(dialog.textContent).toContain('Usa una URL HTTPS con dominio.');
    fireEvent.keyDown(document, { key: 'Escape' });
    expect(screen.queryByRole('alertdialog')).toBeNull();
    await vi.waitFor(() => expect(document.activeElement).toBe(trigger));
  });

  it('only exposes retry when the operation caller marks it safe', () => {
    const retry = vi.fn();
    function SafeRetry() { const { showError } = useAdminFeedback(); return <button onClick={() => showError(new AdminApiError(503, 'HTTP_503', ''), { retry })}>Retry test</button>; }
    render(<AdminFeedbackProvider><SafeRetry /></AdminFeedbackProvider>);
    fireEvent.click(screen.getByRole('button', { name: 'Retry test' }));
    fireEvent.click(screen.getByRole('button', { name: 'Reintentar' }));
    expect(retry).toHaveBeenCalledTimes(1);
  });

  it('offers sign-in after renewal fails, including for nested screens using the provider default', () => {
    const signIn = vi.fn();
    function ExpiredSession() { const { showError } = useAdminFeedback(); return <button onClick={() => showError(new AdminApiError(401, 'SESSION_RENEWAL_FAILED', ''))}>Run</button>; }
    render(<AdminFeedbackProvider onSignIn={signIn}><ExpiredSession /></AdminFeedbackProvider>);
    fireEvent.click(screen.getByRole('button', { name: 'Run' }));
    expect(screen.getByRole('alertdialog', { name: 'Tu sesión ha expirado' })).toBeTruthy();
    fireEvent.click(screen.getByRole('button', { name: 'Iniciar sesión' }));
    expect(signIn).toHaveBeenCalledTimes(1);
  });

  it('keeps keyboard focus inside the modal', () => {
    const signIn = vi.fn();
    function ExpiredSession() { const { showError } = useAdminFeedback(); return <button onClick={() => showError(new AdminApiError(401, 'SESSION_RENEWAL_FAILED', ''))}>Run</button>; }
    render(<AdminFeedbackProvider onSignIn={signIn}><ExpiredSession /></AdminFeedbackProvider>);
    fireEvent.click(screen.getByRole('button', { name: 'Run' }));
    const close = screen.getByRole('button', { name: 'Entendido' });
    const login = screen.getByRole('button', { name: 'Iniciar sesión' });
    login.focus(); fireEvent.keyDown(document, { key: 'Tab' });
    expect(document.activeElement).toBe(close);
    close.focus(); fireEvent.keyDown(document, { key: 'Tab', shiftKey: true });
    expect(document.activeElement).toBe(login);
  });
});
