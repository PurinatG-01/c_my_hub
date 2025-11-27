# Quick Start: Native Flutter Realtime Assistant

## Prerequisites

1. **OpenAI Account with:**

   - API key (sk-...)
   - Published workflow ID (wf-...)

2. **Supabase Project**

## Setup (5 minutes)

### 1. Set Supabase Secrets

```bash
cd /Users/purinatsanbundit/Development/flutter/c_my_hub

# Deploy function
supabase functions deploy health-agent

# Set secrets
supabase secrets set OPENAI_API_KEY=sk-your-key-here
supabase secrets set OPENAI_WORKFLOW_ID=wf-your-workflow-id
```

### 2. Update Flutter Environment

In `frontend/.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 3. Install Dependencies

```bash
cd frontend
flutter pub get
```

### 4. Add Route (Optional)

In your `go_router` configuration:

```dart
GoRoute(
  path: '/ai-assistant-realtime',
  builder: (context, state) => const RealtimeAIAssistantScreen(),
),
```

Or add a navigation button:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RealtimeAIAssistantScreen(),
      ),
    );
  },
  child: const Text('Chat with AI (Realtime)'),
)
```

### 5. Run & Test

```bash
flutter run
```

Navigate to the Realtime AI Assistant screen and start chatting!

## Test Edge Function (Optional)

```bash
# Test locally
supabase start

# Create .env.local with secrets
echo "OPENAI_API_KEY=sk-..." >> supabase/.env.local
echo "OPENAI_WORKFLOW_ID=wf-..." >> supabase/.env.local

# Test request
curl -X POST 'http://127.0.0.1:54321/functions/v1/health-agent' \
  -H 'Content-Type: application/json' \
  -d '{"device_id": "test-123"}'

# Expected response:
# {
#   "client_secret": "ek_...",
#   "session": {
#     "id": "cksess_...",
#     "expires_at": "2025-11-24T15:00:00Z",
#     "ttl_seconds": 3600
#   },
#   "workflow_id": "wf_...",
#   "user": "test-123"
# }
```

## Troubleshooting

### "Failed to fetch client_secret"

- Check Supabase secrets are set: `supabase secrets list`
- Verify function is deployed: `supabase functions list`
- Check function logs: `supabase functions logs health-agent`

### "WebSocket connection failed"

- Verify `client_secret` is valid (test curl command above)
- Check network connectivity
- Ensure OpenAI Realtime API is accessible

### "No response from assistant"

- Check workflow is **published** (not draft) in OpenAI dashboard
- Verify `OPENAI_WORKFLOW_ID` matches your workflow
- Inspect raw events in Flutter console for actual event structure

## Architecture

```
┌─────────────────────┐
│   Flutter App       │
│  (Native WebSocket) │
└──────────┬──────────┘
           │ 1. POST /health-agent
           │    {device_id: "..."}
           ↓
┌─────────────────────┐
│  Supabase Edge Fn   │
│   (health-agent)    │
└──────────┬──────────┘
           │ 2. POST /chatkit/sessions
           │    {workflow_id, user, ttl}
           ↓
┌─────────────────────┐
│  OpenAI Sessions    │
│      API            │
└──────────┬──────────┘
           │ 3. Returns
           │    {client_secret, session}
           ↓
┌─────────────────────┐
│   Flutter App       │
│  Opens WebSocket to │
│  wss://api.openai   │
│  with client_secret │
└──────────┬──────────┘
           │ 4. Send input.create
           │    Receive response.delta
           ↓
┌─────────────────────┐
│  OpenAI Realtime    │
│    (Streaming)      │
└─────────────────────┘
```

## Key Files Created

- `supabase/functions/health-agent/index.ts` - Session minting endpoint
- `frontend/lib/features/ai_assistant/data/services/realtime_client.dart` - WebSocket client
- `frontend/lib/features/ai_assistant/data/services/realtime_health_agent_service.dart` - Service layer
- `frontend/lib/features/ai_assistant/presentation/realtime_ai_assistant_screen.dart` - UI example

## Next Steps

1. **Test with your workflow** - Verify it works with your specific workflow configuration
2. **Customize events** - Update event parsing based on your workflow's output structure
3. **Style the UI** - Adapt the example screen to match your app's design
4. **Add persistence** - Save chat history to local storage or Supabase
5. **Monitor usage** - Check OpenAI dashboard for token usage and session metrics

## Full Documentation

See `docs/REALTIME_API_NATIVE_FLUTTER.md` for complete details.
