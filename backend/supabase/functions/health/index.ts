// Health check endpoint
import { corsResponse } from '../_shared/cors.ts';

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey',
      },
    });
  }

  if (req.method !== 'GET') {
    return corsResponse(405, { error: 'Method not allowed' });
  }

  return corsResponse(200, {
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
});


