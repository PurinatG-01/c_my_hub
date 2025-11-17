# Edge Functions Implementation Guide

This is a practical implementation guide with code examples for migrating to Supabase Edge Functions.

## Quick Start

### 1. Initialize Supabase in Backend

```bash
cd backend
supabase init
```

This creates the `supabase/` directory structure.

### 2. Project Structure

```
backend/
├── supabase/
│   ├── functions/
│   │   ├── health/
│   │   │   ├── index.ts
│   │   │   └── deno.json
│   │   ├── health-data/
│   │   │   ├── index.ts
│   │   │   └── deno.json
│   │   └── _shared/
│   │       ├── cors.ts
│   │       ├── supabase.ts
│   │       └── types.ts
│   └── config.toml
```

## Implementation Files

### Shared Types (`supabase/functions/_shared/types.ts`)

```typescript
export interface HealthData {
  id?: string
  user_id: string
  steps?: number
  heart_rate?: number
  calories?: number
  sleep_hours?: number
  created_at?: string
  updated_at?: string
}

export interface ApiResponse<T> {
  data: T | null
  error: string | null
}
```

### CORS Helper (`supabase/functions/_shared/cors.ts`)

```typescript
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
}

export function corsResponse(status: number, body: any) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  })
}

export function handleCors() {
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  })
}
```

### Supabase Client Helper (`supabase/functions/_shared/supabase.ts`)

```typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

export function createSupabaseClient(req: Request) {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!

  return createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: { Authorization: req.headers.get("Authorization")! },
    },
  })
}
```

### Health Endpoint (`supabase/functions/health/index.ts`)

```typescript
// @ts-nocheck
import { corsResponse } from "../_shared/cors.ts"

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey",
      },
    })
  }

  if (req.method !== "GET") {
    return corsResponse(405, { error: "Method not allowed" })
  }

  return corsResponse(200, {
    status: "ok",
    timestamp: new Date().toISOString(),
  })
})
```

### Health Data Endpoint (`supabase/functions/health-data/index.ts`)

```typescript
// @ts-nocheck
import { createSupabaseClient } from "../_shared/supabase.ts"
import { corsResponse, handleCors } from "../_shared/cors.ts"
import type { HealthData, ApiResponse } from "../_shared/types.ts"

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return handleCors()
  }

  const supabase = createSupabaseClient(req)

  try {
    // GET - Fetch health data
    if (req.method === "GET") {
      const url = new URL(req.url)
      const limit = parseInt(url.searchParams.get("limit") || "10")
      const userId = url.searchParams.get("user_id")

      let query = supabase
        .from("health_data")
        .select("*")
        .order("created_at", { ascending: false })
        .limit(limit)

      if (userId) {
        query = query.eq("user_id", userId)
      }

      const { data, error } = await query

      if (error) throw error

      return corsResponse(200, { data, error: null } as ApiResponse<
        HealthData[]
      >)
    }

    // POST - Create health data
    if (req.method === "POST") {
      const body: HealthData = await req.json()

      // Basic validation
      if (!body.user_id) {
        return corsResponse(400, {
          data: null,
          error: "user_id is required",
        } as ApiResponse<null>)
      }

      const { data, error } = await supabase
        .from("health_data")
        .insert([body])
        .select()
        .single()

      if (error) throw error

      return corsResponse(201, { data, error: null } as ApiResponse<HealthData>)
    }

    return corsResponse(405, { error: "Method not allowed" })
  } catch (error) {
    console.error("Error:", error)
    return corsResponse(500, {
      data: null,
      error: error.message || "Internal server error",
    } as ApiResponse<null>)
  }
})
```

## Configuration

### Deno Configuration (`deno.json`)

Each Edge Function should have a `deno.json` file in its directory to configure TypeScript compilation and imports:

```json
{
  "compilerOptions": {
    "allowJs": true,
    "lib": ["deno.ns", "dom"],
    "strict": true
  },
  "imports": {
    "@supabase/functions-js": "jsr:@supabase/functions-js@2"
  }
}
```

**Key settings:**
- `lib: ["deno.ns", "dom"]` - Enables Deno namespace and DOM types
- `imports` - Maps import aliases to JSR packages
- `strict: true` - Enables strict TypeScript checking

### Supabase Config (`supabase/config.toml`)

```toml
[functions.hello-world]
enabled = true
verify_jwt = true
import_map = "./functions/hello-world/deno.json"
entrypoint = "./functions/hello-world/index.ts"
```

**Configuration options:**
- `enabled` - Enable/disable the function
- `verify_jwt` - Verify JWT tokens automatically
- `import_map` - Path to the function's `deno.json` file
- `entrypoint` - Path to the function's entry point file

### Environment Variables

For local development, create `.env.local` in each function directory:

```bash
# supabase/functions/health/.env.local
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

For production, use Supabase secrets:

```bash
supabase secrets set SUPABASE_URL=https://your-project.supabase.co
supabase secrets set SUPABASE_ANON_KEY=your-anon-key
```

## Development Workflow

### 1. Start Local Supabase

```bash
supabase start
```

This starts:

- PostgreSQL database
- Supabase Studio (dashboard)
- Edge Functions runtime

### 2. Serve Functions Locally

```bash
# Serve all functions
supabase functions serve

# Serve specific function
supabase functions serve health

# Serve with debug logs
supabase functions serve --debug
```

Functions will be available at:

- `http://localhost:54321/functions/v1/health`
- `http://localhost:54321/functions/v1/health-data`

### 3. Test Functions

```bash
# Health check
curl http://localhost:54321/functions/v1/health

# Get health data
curl http://localhost:54321/functions/v1/health-data \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Post health data
curl -X POST http://localhost:54321/functions/v1/health-data \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"user_id":"123","steps":5000,"heart_rate":72}'
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

### Deploy with Environment Variables

```bash
# Set secrets first
supabase secrets set SUPABASE_URL=...
supabase secrets set SUPABASE_ANON_KEY=...

# Then deploy
supabase functions deploy
```

## Frontend Integration

### Update API Base URL

In your Flutter app, update the base URL:

```dart
// Before
const baseUrl = 'http://localhost:3000';

// After
const baseUrl = 'https://<your-project-ref>.supabase.co/functions/v1';
```

### Include Authentication

Edge Functions automatically receive auth context from the Authorization header:

```dart
final response = await http.get(
  Uri.parse('$baseUrl/health-data'),
  headers: {
    'Authorization': 'Bearer $accessToken',
    'apikey': supabaseAnonKey,
  },
);
```

## Troubleshooting

### Function Not Found

- Check function name matches directory name
- Ensure `index.ts` exists in function directory
- Verify deployment: `supabase functions list`

### Authentication Errors

- Ensure Authorization header is included
- Check JWT token is valid
- Verify RLS policies allow access

### CORS Issues

- Add CORS headers in function response
- Handle OPTIONS preflight requests
- Check allowed origins in CORS helper

### Environment Variables Not Working

- For local: Use `.env.local` in function directory
- For production: Use `supabase secrets set`
- Access via `Deno.env.get('KEY_NAME')`

### TypeScript/Deno Type Errors

If you see "Cannot find name 'Deno'" errors in your editor:

1. **Install Deno Extension for VS Code:**
   - Install "Deno" extension by denoland
   - Reload VS Code window

2. **Configure VS Code Settings:**
   
   Create `.vscode/settings.json` in project root:
   ```json
   {
     "deno.enablePaths": [
       "./supabase/functions",
       "./backend/supabase/functions"
     ],
     "deno.enable": false
   }
   ```
   
   Create `supabase/functions/.vscode/settings.json`:
   ```json
   {
     "deno.enable": true,
     "typescript.validate.enable": false,
     "typescript.tsdk": null
   }
   ```

3. **Temporary Workaround:**
   - Add `// @ts-nocheck` at the top of your function file
   - This suppresses TypeScript errors while Deno handles type checking
   - Note: Function will still work correctly at runtime

4. **Verify Configuration:**
   - Ensure `deno.json` exists in each function directory
   - Check that `import_map` in `config.toml` points to the correct `deno.json`
   - Reload VS Code after configuration changes

## Development Environment Setup

### VS Code Configuration

To properly develop Supabase Edge Functions with TypeScript support:

1. **Install Deno Extension:**
   - Open VS Code Extensions (Cmd+Shift+X)
   - Search for "Deno" by denoland
   - Install the extension

2. **Configure Workspace Settings:**
   
   Root `.vscode/settings.json`:
   ```json
   {
     "deno.enablePaths": [
       "./supabase/functions",
       "./backend/supabase/functions"
     ],
     "deno.enable": false
   }
   ```
   
   `supabase/functions/.vscode/settings.json`:
   ```json
   {
     "deno.enable": true,
     "typescript.validate.enable": false,
     "typescript.tsdk": null
   }
   ```

3. **Reload VS Code:**
   - Press `Cmd+Shift+P` (or `Ctrl+Shift+P`)
   - Type "Reload Window" and select it

This configuration:
- Enables Deno language server for Edge Functions
- Disables TypeScript validation (which doesn't understand Deno types)
- Provides proper autocomplete and type checking via Deno

### Function Template

Each new function should follow this structure:

```
function-name/
├── index.ts          # Function entry point
└── deno.json         # Deno configuration
```

**`deno.json` template:**
```json
{
  "compilerOptions": {
    "allowJs": true,
    "lib": ["deno.ns", "dom"],
    "strict": true
  },
  "imports": {
    "@supabase/functions-js": "jsr:@supabase/functions-js@2"
  }
}
```

**`index.ts` template:**
```typescript
// @ts-nocheck
// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

Deno.serve(async (req) => {
  // Your function logic here
  return new Response(
    JSON.stringify({ message: "Hello from Edge Function!" }),
    { headers: { "Content-Type": "application/json" } }
  )
})
```

## Next Steps

1. Create the directory structure
2. Add `deno.json` to each function directory
3. Configure VS Code settings for Deno support
4. Implement shared utilities
5. Create health endpoint (simplest)
6. Test locally with `supabase start`
7. Create health-data endpoint
8. Deploy to Supabase
9. Update frontend
10. Test end-to-end

