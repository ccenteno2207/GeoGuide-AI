import { useEffect, useState } from 'react';

/** Local-only preview; creates no network request and revokes the object URL on change/unmount. */
export function SelectedMediaPreview({ file, altText }: { file: File | null; altText: string }) {
  const [url, setUrl] = useState<string | null>(null);

  useEffect(() => {
    if (!file) {
      setUrl(null);
      return;
    }
    let objectUrl: string;
    try { objectUrl = URL.createObjectURL(file); }
    catch { setUrl(null); return; }
    setUrl(objectUrl);
    return () => URL.revokeObjectURL(objectUrl);
  }, [file]);

  if (!file) return null;
  return <figure className="selected-media-preview" aria-label="Previsualización local de la fotografía">
    {url ? <img src={url} alt={altText.trim() || `Vista previa de ${file.name}`} /> : <div role="img" aria-label={`Archivo seleccionado: ${file.name}`}>{file.name}</div>}
    <figcaption>Vista previa local · aún no se ha cargado</figcaption>
  </figure>;
}
