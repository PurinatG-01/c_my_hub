# OpenAI Responses API Implementation

## Overview

This implementation uses the OpenAI Responses API to invoke a ChatKit workflow directly from Flutter through Supabase Edge Functions. This is a simple, clean approach that avoids WebSocket complexity.

## Architecture

```
Flutter App → Supabase Edge Function → OpenAI Responses API
    ↓                    ↓                        ↓
User sends message   Calls /v1/responses    Returns workflow output
    ↓                    ↓                        ↓
Displays response    Returns JSON           Executes workflow
```

## API Endpoint

**OpenAI Responses API**: `https://api.openai.com/v1/responses`

This is the correct endpoint for invoking ChatKit workflows, as documented in the OpenAI API.

## Configuration

### Supabase Environment Variables

Set these in your Supabase project:

```bash
# Required
OPENAI_API_KEY=sk-proj-...

# Required
WORKFLOW_ID=wf_your_workflow_id_here
```

To set environment variables:

```bash
# Using Supabase CLI
supabase secrets set OPENAI_API_KEY=sk-proj-...
supabase secrets set WORKFLOW_ID=wf_your_workflow_id_here

# Or via Supabase Dashboard
# Project Settings → Edge Functions → Secrets
```

### Flutter Environment Variables

In `frontend/.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Implementation Details

### Edge Function (`supabase/functions/health-agent/index.ts`)

**Request Format:**

```json
{
  "message": "How can I improve my sleep?",
  "session_id": "optional-session-id-for-continuity"
}
```

**Response Format:**

```json
{
  "output": "Based on your health data...",
  "session_id": "session-id-or-null",
  "raw": {
    /* full OpenAI response */
  }
}
```

**Key Features:**

- Uses `gpt-4.1` model (required even with workflow)
- Maintains conversation context via optional `session_id`
- Returns complete response (no streaming)
- Simple error handling with CORS support

### Flutter Service (`lib/features/ai_assistant/data/health_agent_service.dart`)

**Usage:**

```dart
final service = HealthAgentService();

// Send message (maintains session automatically)
final response = await service.sendMessage(message: "Hello!");

// Clear session to start fresh conversation
service.clearSession();

// Get current session ID
final sessionId = service.sessionId;
```

**Key Features:**

- Automatic session management
- Simple Future-based API (no streams)
- Automatic Supabase authentication
- Clean error handling

### UI (`lib/features/ai_assistant/presentation/ai_assistant_screen.dart`)

**Changes from streaming version:**

- Removed `_currentStreamingMessage` state
- Simplified to single `await` call
- Removed `HealthAgentEvent` handling
- Shows loading indicator during request
- Displays complete response at once

## Testing

### 1. Deploy Edge Function

```bash
cd /path/to/project
supabase functions deploy health-agent
```

### 2. Test Edge Function Directly

```bash
curl -X POST https://your-project.supabase.co/functions/v1/health-agent \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-anon-key" \
  -d '{"message": "What are healthy sleep habits?"}'
```

Expected response:

```json
{
  "output": "Here are some healthy sleep habits...",
  "session_id": null,
  "raw": { ... }
}
```

### 3. Test from Flutter

1. Run the app: `flutter run`
2. Navigate to AI Assistant screen
3. Send a message
4. Verify response appears

## Troubleshooting

### Error: "OpenAI API key not configured"

**Solution:** Set the OPENAI_API_KEY secret in Supabase:

```bash
supabase secrets set OPENAI_API_KEY=sk-proj-...
```

### Error: "Failed to send message: 401"

**Solution:** Check that your OPENAI_API_KEY is valid and has access to the workflow.

### Error: "Failed to send message: 404"

**Solution:** Verify the workflow ID exists and is accessible with your API key.

### Session not maintained

**Issue:** Each request seems to start a new conversation.

**Solution:** Ensure you're passing `maintainSession: true` (default) and the backend is returning `session_id`.

## Differences from Previous Approaches

### ❌ Previous (ChatKit WebSocket + Server Proxy)

- Complex WebSocket handling
- Server-side WebSocket proxy
- SSE streaming to Flutter
- Authentication issues with `client_secret`

### ✅ Current (Responses API)

- Simple HTTP POST request/response
- No WebSocket complexity
- Direct workflow invocation
- Server-side API key authentication

## Future Enhancements

### Add Streaming Support

The Responses API supports streaming via SSE. To add it:

1. **Edge Function**: Return SSE stream instead of JSON

```typescript
return new Response(stream, {
  headers: {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    "Access-Control-Allow-Origin": "*",
  },
})
```

2. **Flutter Service**: Use http.Request with streamed response

```dart
final request = http.Request('POST', url);
final response = await _client.send(request);
await for (final chunk in response.stream.transform(utf8.decoder)) {
  // Parse SSE events
}
```

### Add Context from Health Data

Pass user's health metrics to provide personalized advice:

```typescript
const payload = {
  model: "gpt-4.1",
  workflow: { id: WORKFLOW_ID },
  input: {
    text: message,
    context: {
      sleep_hours: 7.5,
      steps_today: 8500,
      heart_rate_avg: 72,
    },
  },
}
```

## References

- [OpenAI Responses API Documentation](https://platform.openai.com/docs/api-reference/responses)
- [ChatKit Workflows Guide](https://platform.openai.com/docs/guides/chatkit)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
