# Deployment Guide - Health Agent with OpenAI Responses API

## Prerequisites

- Supabase CLI installed: `brew install supabase/tap/supabase` (macOS)
- OpenAI API key with access to ChatKit workflows
- Supabase project created

## Step 1: Set Up Supabase Secrets

```bash
# Navigate to project root
cd /Users/purinatsanbundit/Development/flutter/c_my_hub

# Login to Supabase (if not already logged in)
supabase login

# Link to your project (if not already linked)
supabase link --project-ref your-project-ref

# Set OpenAI API key
supabase secrets set OPENAI_API_KEY=sk-proj-your-api-key-here

# Set workflow ID (optional - has default)
supabase secrets set WORKFLOW_ID=wf_690b57c50db08190b1b4a7d44e8f884a0d58893a1aea4892

# Verify secrets are set
supabase secrets list
```

## Step 2: Deploy Edge Function

```bash
# Deploy the health-agent function
supabase functions deploy health-agent

# You should see:
# ✓ Deployed Function health-agent
```

## Step 3: Test Edge Function

```bash
# Get your Supabase URL and anon key from dashboard or .env
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"

# Test the function
curl -X POST "$SUPABASE_URL/functions/v1/health-agent" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -d '{"message": "What are some healthy sleep habits?"}'
```

Expected response:

```json
{
  "output": "Here are some evidence-based healthy sleep habits...",
  "session_id": null,
  "raw": { ... }
}
```

## Step 4: Configure Flutter App

Ensure `frontend/.env` has correct values:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

## Step 5: Run Flutter App

```bash
cd frontend

# Get dependencies
flutter pub get

# Run on your device/simulator
flutter run

# Or for web
flutter run -d chrome
```

## Step 6: Test in App

1. Navigate to "AI Assistant" from the dashboard
2. Send a message: "What are healthy sleep habits?"
3. Wait for response
4. Verify the workflow responds appropriately

## Troubleshooting

### Function deployment fails

```bash
# Check Supabase CLI version
supabase --version

# Update if needed
brew upgrade supabase

# Check you're linked to the right project
supabase projects list
```

### "OpenAI API key not configured" error

```bash
# Verify secrets are set
supabase secrets list

# Re-set if needed
supabase secrets set OPENAI_API_KEY=sk-proj-...

# Redeploy function
supabase functions deploy health-agent
```

### CORS errors in Flutter

The edge function includes CORS headers. If you still see errors:

1. Check your Supabase URL is correct in `.env`
2. Verify anon key is correct
3. Clear Flutter build cache: `flutter clean && flutter pub get`

### "Failed to send message: 404"

- Verify workflow ID is correct
- Check your OpenAI API key has access to the workflow
- Try the default workflow ID in the code

## Monitoring

### View Function Logs

```bash
# Stream logs in real-time
supabase functions logs health-agent

# Or view in Supabase Dashboard:
# Functions → health-agent → Logs
```

### Check Invocations

In Supabase Dashboard:

- Go to Functions → health-agent → Invocations
- See request/response history
- Monitor errors and performance

## Updating the Function

After making changes to `supabase/functions/health-agent/index.ts`:

```bash
# Deploy the updated function
supabase functions deploy health-agent

# Test the changes
curl -X POST "$SUPABASE_URL/functions/v1/health-agent" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -d '{"message": "Test message"}'
```

## Production Checklist

- [ ] OpenAI API key set in Supabase secrets
- [ ] Workflow ID configured (or using default)
- [ ] Edge function deployed successfully
- [ ] Function tested via curl
- [ ] Flutter .env file configured
- [ ] App tested on device
- [ ] Error handling verified
- [ ] Session management tested (send multiple messages)
- [ ] Function logs monitored for errors

## Cost Considerations

- **OpenAI Responses API**: Charged per token used by the workflow
- **Supabase Edge Functions**: Free tier includes 500K invocations/month
- Monitor usage in:
  - OpenAI Dashboard: https://platform.openai.com/usage
  - Supabase Dashboard: Project Settings → Usage

## Next Steps

1. **Add streaming**: Implement SSE for real-time response streaming
2. **Add context**: Pass user health data to workflow for personalized advice
3. **Add analytics**: Track conversation patterns and user satisfaction
4. **Add feedback**: Allow users to rate responses
5. **Add history**: Store conversations in Supabase database
