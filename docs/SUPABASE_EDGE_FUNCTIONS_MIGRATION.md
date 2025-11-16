# Supabase Edge Functions Migration Plan

## Overview

This guide outlines the plan to migrate the Express.js backend service to Supabase Edge Functions. Edge Functions run on Deno and provide serverless, scalable API endpoints directly within your Supabase project.

## Current Architecture

- **Framework**: Express.js (Node.js)
- **Endpoints**:
  - `GET /health` - Health check
  - `GET /api/health-data` - Fetch health data
  - `POST /api/health-data` - Create health data entry
- **Database**: Supabase (already configured)

## Target Architecture

- **Runtime**: Deno (Supabase Edge Functions)
- **Structure**: Individual edge functions for each endpoint
- **Deployment**: Direct to Supabase project
- **Benefits**:
  - No server management
  - Automatic scaling
  - Built-in authentication context
  - Lower latency (runs closer to database)
  - Cost-effective (pay per invocation)

## Migration Steps

### Phase 1: Setup & Prerequisites

#### 1.1 Install Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Or using npm
npm install -g supabase

# Verify installation
supabase --version
```

#### 1.2 Initialize Supabase Project

```bash
# From project root
cd backend
supabase init

# This creates:
# - supabase/
#   - config.toml
#   - functions/
```

#### 1.3 Link to Existing Supabase Project

```bash
# Login to Supabase
supabase login

# Link to your project (you'll need your project reference ID)
supabase link --project-ref <your-project-ref>
```

### Phase 2: Create Edge Functions Structure

#### 2.1 Function Organization Strategy

We'll create individual edge functions for each endpoint:

```
backend/
├── supabase/
│   ├── functions/
│   │   ├── health/
│   │   │   └── index.ts          # GET /health
│   │   ├── health-data/
│   │   │   └── index.ts          # GET/POST /api/health-data
│   │   └── _shared/
│   │       ├── cors.ts           # CORS utilities
│   │       ├── supabase.ts       # Supabase client helper
│   │       └── types.ts          # Shared types
│   └── config.toml
```

#### 2.2 Create Shared Utilities

**`supabase/functions/_shared/supabase.ts`**

- Supabase client initialization
- Handles authentication from request headers

**`supabase/functions/_shared/cors.ts`**

- CORS headers helper
- Preflight request handling

**`supabase/functions/_shared/types.ts`**

- HealthData interface
- Request/Response types

### Phase 3: Migrate Endpoints

#### 3.1 Health Check Endpoint

**Function**: `supabase/functions/health/index.ts`

- Simple GET endpoint
- Returns status and timestamp
- No authentication required

#### 3.2 Health Data Endpoints

**Function**: `supabase/functions/health-data/index.ts`

- Handle both GET and POST methods
- GET: Fetch health data with optional query params
- POST: Create new health data entry
- Use Supabase client from request context
- Validate request body with Zod

### Phase 4: Environment Configuration

#### 4.1 Edge Function Secrets

Edge Functions use Supabase secrets (not .env files):

```bash
# Set secrets for edge functions
supabase secrets set SUPABASE_URL=<your-url>
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<your-key>
```

#### 4.2 Local Development

For local testing, create `.env.local` in the function directory:

- Supabase CLI reads from `.env.local` during `supabase functions serve`

### Phase 5: Testing & Deployment

#### 5.1 Local Testing

```bash
# Start local Supabase (includes edge functions)
supabase start

# Serve edge functions locally
supabase functions serve

# Test individual function
curl http://localhost:54321/functions/v1/health
```

#### 5.2 Deploy Functions

```bash
# Deploy all functions
supabase functions deploy

# Deploy specific function
supabase functions deploy health
supabase functions deploy health-data
```

#### 5.3 Function URLs

After deployment, functions are available at:

- `https://<project-ref>.supabase.co/functions/v1/health`
- `https://<project-ref>.supabase.co/functions/v1/health-data`

### Phase 6: Update Frontend

#### 6.1 Update API Base URL

Update Flutter app to use edge function URLs instead of localhost/Express server.

#### 6.2 Authentication

Edge Functions automatically receive auth context:

- Access user from `req.headers.get('Authorization')`
- Use Supabase client with user's JWT token

## Key Differences: Express vs Edge Functions

| Aspect         | Express.js         | Edge Functions                      |
| -------------- | ------------------ | ----------------------------------- |
| Runtime        | Node.js            | Deno                                |
| Imports        | npm packages       | Deno-compatible (esm.sh, deno.land) |
| Environment    | .env file          | Supabase secrets                    |
| Request Object | Express Request    | Deno Request (Web API)              |
| Response       | Express Response   | Response (Web API)                  |
| Auth Context   | Manual JWT parsing | Automatic via headers               |
| Deployment     | Server hosting     | Supabase platform                   |

## Code Conversion Examples

### Express Route → Edge Function

**Before (Express):**

```typescript
app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() })
})
```

**After (Edge Function):**

```typescript
Deno.serve(async (req) => {
  return new Response(
    JSON.stringify({
      status: "ok",
      timestamp: new Date().toISOString(),
    }),
    { headers: { "Content-Type": "application/json" } }
  )
})
```

### Supabase Client Initialization

**Before (Express):**

```typescript
const supabase = createClient(supabaseUrl, supabaseKey)
```

**After (Edge Function):**

```typescript
const supabaseClient = createClient(
  Deno.env.get("SUPABASE_URL") ?? "",
  Deno.env.get("SUPABASE_ANON_KEY") ?? "",
  {
    global: {
      headers: { Authorization: req.headers.get("Authorization")! },
    },
  }
)
```

## Migration Checklist

- [ ] Install Supabase CLI
- [ ] Initialize Supabase project in backend directory
- [ ] Link to existing Supabase project
- [ ] Create shared utilities (\_shared folder)
- [ ] Migrate health endpoint
- [ ] Migrate health-data GET endpoint
- [ ] Migrate health-data POST endpoint
- [ ] Set up environment secrets
- [ ] Test functions locally
- [ ] Deploy functions to Supabase
- [ ] Update frontend API URLs
- [ ] Test deployed functions
- [ ] Update documentation
- [ ] (Optional) Remove Express.js backend code

## Post-Migration

### Keep Express Backend?

You can:

1. **Remove it entirely** - If all functionality is migrated
2. **Keep for local dev** - Use Express for faster local iteration
3. **Hybrid approach** - Use Edge Functions for production, Express for development

### Monitoring

- Monitor function invocations in Supabase Dashboard
- Set up alerts for errors
- Review function logs

## Resources

- [Supabase Edge Functions Docs](https://supabase.com/docs/guides/functions)
- [Deno Runtime](https://deno.land/manual)
- [Supabase JS Client](https://supabase.com/docs/reference/javascript/creating-a-client)

## Next Steps

1. Review this plan
2. Install Supabase CLI
3. Begin Phase 1 setup
4. Create first edge function (health endpoint) as proof of concept
5. Gradually migrate remaining endpoints

