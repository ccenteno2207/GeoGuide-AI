import { afterEach, describe, expect, it, vi } from 'vitest';
import { AdminApi } from './api';

describe('AdminApi problem responses', () => {
  afterEach(() => vi.unstubAllGlobals());

  it('surfaces the actionable detail from an editorial category conflict', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(JSON.stringify({
      status: 409,
      code: 'EDITORIAL_CATEGORY_MISMATCH',
      detail: 'El tipo MINCETUR corresponde a la categoría P3 ARCHAEOLOGICAL_SITE.',
    }), { status: 409, headers: { 'Content-Type': 'application/problem+json' } })));
    const api = new AdminApi({ baseUrl: 'https://admin.example.test', getToken: async () => 'synthetic' });

    await expect(api.post('/api/v1/admin/records/id/approve', {}))
      .rejects.toThrow('API 409: El tipo MINCETUR corresponde a la categoría P3 ARCHAEOLOGICAL_SITE.');
  });
});
