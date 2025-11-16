// Health data endpoints (GET and POST)
import { createSupabaseClient } from '../_shared/supabase.ts';
import { corsResponse, handleCors } from '../_shared/cors.ts';
import type { HealthData, ApiResponse } from '../_shared/types.ts';

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return handleCors();
  }

  const supabase = createSupabaseClient(req);

  try {
    // GET - Fetch health data
    if (req.method === 'GET') {
      const url = new URL(req.url);
      const limit = parseInt(url.searchParams.get('limit') || '10');
      const userId = url.searchParams.get('user_id');

      let query = supabase
        .from('health_data')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(limit);

      if (userId) {
        query = query.eq('user_id', userId);
      }

      const { data, error } = await query;

      if (error) throw error;

      return corsResponse(200, { data, error: null } as ApiResponse<HealthData[]>);
    }

    // POST - Create health data
    if (req.method === 'POST') {
      const body: HealthData = await req.json();

      // Basic validation
      if (!body.user_id) {
        return corsResponse(400, { 
          data: null, 
          error: 'user_id is required' 
        } as ApiResponse<null>);
      }

      const { data, error } = await supabase
        .from('health_data')
        .insert([body])
        .select()
        .single();

      if (error) throw error;

      return corsResponse(201, { data, error: null } as ApiResponse<HealthData>);
    }

    return corsResponse(405, { error: 'Method not allowed' });
  } catch (error) {
    console.error('Error:', error);
    const errorMessage = error instanceof Error ? error.message : String(error);
    return corsResponse(500, {
      data: null,
      error: errorMessage || 'Internal server error',
    } as ApiResponse<null>);
  }
});

