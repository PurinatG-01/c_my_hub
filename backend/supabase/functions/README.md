# Supabase Edge Functions

This directory contains Supabase Edge Functions that replace the Express.js backend server.

## Structure

```
supabase/functions/
├── _shared/           # Shared utilities
│   ├── cors.ts       # CORS helper functions
│   ├── supabase.ts   # Supabase client helper
│   └── types.ts      # Shared TypeScript types
├── health/           # Health check endpoint
│   └── index.ts
└── health-data/      # Health data CRUD endpoints
    └── index.ts
```

## Functions

### `health`
- **Endpoint**: `/functions/v1/health`
- **Method**: GET
- **Description**: Simple health check endpoint
- **Auth**: Not required

### `health-data`
- **Endpoint**: `/functions/v1/health-data`
- **Methods**: GET, POST
- **Description**: Manage health data entries
- **Auth**: Required (uses JWT from Authorization header)

## Local Development

### Prerequisites

1. Install Supabase CLI:
   ```bash
   brew install supabase/tap/supabase
   # or
   npm install -g supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link to your project:
   ```bash
   supabase link --project-ref <your-project-ref>
   ```

### Running Locally

1. Start local Supabase (includes database and functions):
   ```bash
   supabase start
   ```

2. Serve edge functions:
   ```bash
   supabase functions serve
   ```

3. Functions will be available at:
   - `http://localhost:54321/functions/v1/health`
   - `http://localhost:54321/functions/v1/health-data`

### Environment Variables

For local development, create `.env.local` files in each function directory, or set them globally:

```bash
# In function directory
echo "SUPABASE_URL=https://your-project.supabase.co" > .env.local
echo "SUPABASE_ANON_KEY=your-anon-key" >> .env.local
```

Or use Supabase CLI to set secrets:
```bash
supabase secrets set SUPABASE_URL=https://your-project.supabase.co
supabase secrets set SUPABASE_ANON_KEY=your-anon-key
```

## Testing

### Health Check
```bash
curl http://localhost:54321/functions/v1/health
```

### Get Health Data
```bash
curl http://localhost:54321/functions/v1/health-data \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "apikey: YOUR_ANON_KEY"
```

### Post Health Data
```bash
curl -X POST http://localhost:54321/functions/v1/health-data \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "123e4567-e89b-12d3-a456-426614174000",
    "steps": 5000,
    "heart_rate": 72,
    "calories": 2000,
    "sleep_hours": 7.5
  }'
```

## Deployment

### Deploy All Functions
```bash
supabase functions deploy
```

### Deploy Specific Function
```bash
supabase functions deploy health
supabase functions deploy health-data
```

### Set Production Secrets
```bash
supabase secrets set SUPABASE_URL=https://your-project.supabase.co
supabase secrets set SUPABASE_ANON_KEY=your-anon-key
```

### Production URLs

After deployment, functions are available at:
- `https://<project-ref>.supabase.co/functions/v1/health`
- `https://<project-ref>.supabase.co/functions/v1/health-data`

## Frontend Integration

Update your Flutter app to use the edge function URLs:

```dart
// Base URL
const baseUrl = 'https://<your-project-ref>.supabase.co/functions/v1';

// Example request
final response = await http.get(
  Uri.parse('$baseUrl/health-data'),
  headers: {
    'Authorization': 'Bearer $accessToken',
    'apikey': supabaseAnonKey,
    'Content-Type': 'application/json',
  },
);
```

## Troubleshooting

### Function Not Found
- Ensure function name matches directory name
- Check that `index.ts` exists in function directory
- Verify deployment: `supabase functions list`

### Authentication Errors
- Include `Authorization` header with valid JWT
- Include `apikey` header with Supabase anon key
- Check RLS policies allow access

### CORS Issues
- CORS is handled automatically by the shared utilities
- Ensure OPTIONS requests are handled (already implemented)

### Environment Variables
- Local: Use `.env.local` in function directory
- Production: Use `supabase secrets set`
- Access via `Deno.env.get('KEY_NAME')`

## Migration from Express

The Express.js backend (`src/index.ts`) can be kept for:
- Local development (faster iteration)
- Fallback during migration
- Or removed entirely if all functionality is migrated

See `docs/SUPABASE_EDGE_FUNCTIONS_MIGRATION.md` for full migration details.



