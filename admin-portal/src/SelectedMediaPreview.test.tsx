import { cleanup, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { SelectedMediaPreview } from './SelectedMediaPreview';

afterEach(() => { cleanup(); vi.restoreAllMocks(); });

describe('selected local media preview', () => {
  it('previews the chosen file locally and releases its object URL', () => {
    const create = vi.spyOn(URL, 'createObjectURL').mockReturnValue('blob:local-preview');
    const revoke = vi.spyOn(URL, 'revokeObjectURL').mockImplementation(() => undefined);
    const file = new File(['synthetic-image'], 'sample.png', { type: 'image/png' });
    const view = render(<SelectedMediaPreview file={file} altText="Fachada" />);

    expect(create).toHaveBeenCalledWith(file);
    expect(screen.getByRole('img', { name: 'Fachada' }).getAttribute('src')).toBe('blob:local-preview');
    expect(screen.getByText('Vista previa local · aún no se ha cargado')).toBeTruthy();
    view.unmount();
    expect(revoke).toHaveBeenCalledWith('blob:local-preview');
  });

  it('shows nothing when no file is selected', () => {
    const { container } = render(<SelectedMediaPreview file={null} altText="" />);
    expect(container.querySelector('figure')).toBeNull();
  });
});
