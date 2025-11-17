# Quick Setup Guide

## Prerequisites

1. **Install Supabase CLI**
   ```bash
   # macOS
   brew install supabase/tap/supabase
   
   # Or using npm
   npm install -g supabase
   
   # Verify
   supabase --version
   ```

2. **Login to Supabase**
   ```bash
   supabase login
   ```

## Initial Setup

1. **Link to your Supabase project**
   ```bash
   cd backend
   supabase link --project-ref <your-project-ref>
   ```
   
   You can find your project reference ID in your Supabase dashboard URL:
   `https://app.supabase.com/project/<project-ref>`

2. **Set environment secrets**
   ```bash
   supabase secrets set SUPABASE_URL=https://<project-ref>.supabase.co
   supabase secrets set SUPABASE_ANON_KEY=your-anon-key
   ```
   
   You can find these values in your Supabase dashboard under Settings > API.

## Local Development

1. **Start local Supabase** (optional, for full local development)
   ```bash
   supabase start
   ```
   This starts a local PostgreSQL database and Supabase services.

2. **Serve edge functions locally**
   ```bash
   supabase functions serve
   ```
   
   Functions will be available at:
   - `http://localhost:54321/functions/v1/health`
   - `http://localhost:54321/functions/v1/health-data`

3. **Test the functions**
   ```bash
   # Health check
   curl http://localhost:54321/functions/v1/health
   
   # Get health data (requires auth token)
   curl http://localhost:54321/functions/v1/health-data \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -H "apikey: YOUR_ANON_KEY"
   ```

## Deployment

1. **Deploy all functions**
   ```bash
   supabase functions deploy
   ```

2. **Deploy specific function**
   ```bash
   supabase functions deploy health
   supabase functions deploy health-data
   ```

3. **Verify deployment**
   ```bash
   supabase functions list
   ```

## Production URLs

After deployment, your functions will be available at:
- `https://<project-ref>.supabase.co/functions/v1/health`
- `https://<project-ref>.supabase.co/functions/v1/health-data`

## Troubleshooting

### "Command not found: supabase"
- Make sure Supabase CLI is installed and in your PATH
- Try: `which supabase` to verify installation

### "Project not linked"
- Run: `supabase link --project-ref <your-project-ref>`
- Or initialize: `supabase init` (if starting fresh)

### "Missing environment variables"
- Set secrets: `supabase secrets set KEY=value`
- For local dev, create `.env.local` in function directory

### Function deployment fails
- Check you're logged in: `supabase projects list`
- Verify project is linked: Check `supabase/config.toml`
- Review function code for syntax errors

## Next Steps

- See [functions/README.md](./functions/README.md) for detailed function documentation
- See [../../docs/SUPABASE_EDGE_FUNCTIONS_MIGRATION.md](../../docs/SUPABASE_EDGE_FUNCTIONS_MIGRATION.md) for migration details
- See [../../docs/EDGE_FUNCTIONS_IMPLEMENTATION.md](../../docs/EDGE_FUNCTIONS_IMPLEMENTATION.md) for implementation examples



