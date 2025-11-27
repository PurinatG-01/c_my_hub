# OpenAI Realtime API Integration (Native Flutter)

This implementation provides a **native Flutter WebSocket client** for connecting to OpenAI's Realtime API using ephemeral sessions minted by your Supabase Edge Function.

## Architecture Overview

```
Flutter App (Native WebSocket)
    ↓
    1. Request client_secret
    ↓
Supabase Edge Function (health-agent)
    ↓
    2. Create ChatKit Session
    ↓
OpenAI Sessions API
    ↓
    3. Return client_secret + session info
    ↓
Flutter App receives client_secret
    ↓
    4. Open WebSocket to wss://api.openai.com/v1/realtime
    ↓
OpenAI Realtime API (streaming)
```

## Components

### 1. Backend: Supabase Edge Function

**File:** `supabase/functions/health-agent/index.ts`

**Purpose:** Mints ephemeral `client_secret` tokens for your published workflow.

**Environment Variables Required:**

```bash
OPENAI_API_KEY=sk-...
OPENAI_WORKFLOW_ID=wf_...
```

**Set these in Supabase:**

```bash
supabase secrets set OPENAI_API_KEY=sk-...
supabase secrets set OPENAI_WORKFLOW_ID=wf_...
```

**API Contract:**

**Request:**

```json
POST /functions/v1/health-agent
{
  "device_id": "unique-device-identifier"
}
```

**Response:**

```json
{
  "client_secret": "ek_...",
  "session": {
    "id": "cksess_...",
    "expires_at": "2025-11-24T15:00:00Z",
    "ttl_seconds": 3600
  },
  "workflow_id": "wf_...",
  "user": "unique-device-identifier"
}
```

### 2. Frontend: Flutter Components

#### a) RealtimeClient (`realtime_client.dart`)

**Purpose:** Core WebSocket client that handles:

- Fetching `client_secret` from your Edge Function
- Opening WebSocket to OpenAI Realtime API
- Automatic token refresh (at 80% of TTL)
- Exponential backoff reconnection
- Streaming event parsing

**Key Features:**

- ✅ Native `web_socket_channel` (no WebView!)
- ✅ Automatic session refresh before expiry
- ✅ Reconnection with backoff
- ✅ Typed event stream

**Usage:**

```dart
final client = RealtimeClient(
  supabaseFunctionUrl: 'https://your-project.functions.supabase.co/health-agent',
  deviceId: 'user-device-123',
);

// Listen to events
client.events.listen((event) {
  switch (event.type) {
    case RealtimeEventType.connected:
      print('Connected!');
      break;
    case RealtimeEventType.responseDelta:
      print('Streaming: ${event.data}');
      break;
    case RealtimeEventType.responseComplete:
      print('Complete: ${event.data}');
      break;
  }
});

// Start connection
await client.start();

// Send input
client.sendInputText('What are my health metrics?');

// Stop
await client.stop();
```

#### b) RealtimeHealthAgentService (`realtime_health_agent_service.dart`)

**Purpose:** High-level service layer that:

- Manages `RealtimeClient` lifecycle
- Provides clean message/status streams
- Handles partial message assembly
- Abstracts event complexity

**Usage:**

```dart
final service = RealtimeHealthAgentService();

// Listen to messages
service.messages.listen((message) {
  print('${message.role}: ${message.content}');
});

// Listen to connection status
service.status.listen((status) {
  print('Status: $status');
});

// Start
await service.start('device-123');

// Send
service.sendMessage('Hello!');

// Stop
await service.stop();
```

#### c) RealtimeAIAssistantScreen (`realtime_ai_assistant_screen.dart`)

**Purpose:** Complete UI example with:

- Chat bubbles for user/assistant messages
- Connection status indicator
- Partial message streaming display
- Error handling

**Add to your router:**

```dart
GoRoute(
  path: '/ai-assistant-realtime',
  builder: (context, state) => const RealtimeAIAssistantScreen(),
),
```

## Setup Instructions

### 1. Install Dependencies

```bash
cd frontend
flutter pub add web_socket_channel
flutter pub get
```

Already in `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.0
  web_socket_channel: ^2.2.0
  flutter_dotenv: ^6.0.0
  uuid: ^4.2.0
  flutter_riverpod: ^2.6.1
```

### 2. Configure Environment Variables

Create/update `frontend/.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
```

### 3. Deploy Edge Function

```bash
cd supabase
supabase functions deploy health-agent
supabase secrets set OPENAI_API_KEY=sk-...
supabase secrets set OPENAI_WORKFLOW_ID=wf_...
```

### 4. Test Locally

**Start Supabase locally:**

```bash
supabase start
```

**Set local secrets:**

```bash
echo "OPENAI_API_KEY=sk-..." >> supabase/.env.local
echo "OPENAI_WORKFLOW_ID=wf_..." >> supabase/.env.local
```

**Test edge function:**

```bash
curl -i --request POST 'http://127.0.0.1:54321/functions/v1/health-agent' \
  --header 'Content-Type: application/json' \
  --data '{"device_id": "test-123"}'
```

**Run Flutter app:**

```bash
cd frontend
flutter run
```

## Event Flow & Message Types

### OpenAI Realtime Events (examples)

The exact event structure depends on your workflow and OpenAI API version. Here are common patterns:

**Input Event (sent by client):**

```json
{
  "type": "input.create",
  "payload": {
    "input": {
      "type": "text",
      "text": "What should I eat today?"
    },
    "session": "cksess_..."
  }
}
```

**Response Delta (streaming partial):**

```json
{
  "type": "response.delta",
  "delta": {
    "text": "Based on your health goals, I recommend..."
  }
}
```

**Response Complete (final):**

```json
{
  "type": "response.complete",
  "response": {
    "output": "Based on your health goals, I recommend a balanced meal with lean protein, whole grains, and vegetables.",
    "metadata": { ... }
  }
}
```

**Tool Invocation (if workflow uses tools):**

```json
{
  "type": "tool.invoke",
  "tool": {
    "name": "get_health_metrics",
    "arguments": { "metric": "steps" }
  }
}
```

### Adapting to Your Workflow

1. **Inspect raw events**: The `RealtimeClient` logs all events. Check your console:

   ```
   WS message: {"type":"...", "payload":...}
   ```

2. **Update parsing logic**: In `RealtimeHealthAgentService._handleResponseDelta()` and `_handleResponseComplete()`, adjust the JSON path based on actual structure:

   ```dart
   final text = data['response']['output']?.toString() ??
                data['delta']['text']?.toString();
   ```

3. **Handle tool events**: If your workflow uses tools, add cases in `_handleRealtimeEvent()`:
   ```dart
   case RealtimeEventType.toolInvoke:
     _handleToolInvoke(event.data);
     break;
   ```

## Token Refresh & Session Management

### How it works:

1. **Session created**: Edge function returns `expires_at` or `ttl_seconds`
2. **Client schedules refresh**: At 80% of TTL (e.g., 48 min for 1-hour TTL)
3. **Auto-refresh**: Client fetches new `client_secret` and reconnects
4. **Transparent to UI**: Existing messages persist, no user interruption

### Why 80%?

- Network delays/clock drift buffer
- Ensures refresh completes before expiry
- Industry standard (OAuth, JWT best practices)

### Manual refresh:

If needed, you can force refresh:

```dart
await client.stop();
await client.start(); // fetches new secret
```

## Error Handling

### Common Issues

| Error                           | Cause                           | Solution                                                                |
| ------------------------------- | ------------------------------- | ----------------------------------------------------------------------- |
| `401 Unauthorized`              | Expired/invalid `client_secret` | Check refresh logic, verify Edge function returns valid token           |
| `Failed to fetch client_secret` | Edge function error             | Check Supabase logs, verify `OPENAI_API_KEY` and `WORKFLOW_ID` are set  |
| `WebSocket connection failed`   | Network/firewall                | Check connectivity, verify `wss://api.openai.com` is accessible         |
| `No client_secret in response`  | Edge function payload mismatch  | Verify Edge function returns `{ client_secret: "...", session: {...} }` |

### Debug Logging

Enable verbose logs:

```dart
// In realtime_client.dart
developer.log('Detailed message', name: 'RealtimeClient');
```

Check logs:

```bash
flutter run --verbose
```

## Production Checklist

- [ ] Set `OPENAI_WORKFLOW_ID` to your **published** workflow (not draft)
- [ ] Verify workflow is tested and working in OpenAI Playground
- [ ] Deploy Edge function to production Supabase
- [ ] Set production secrets (`OPENAI_API_KEY`, `OPENAI_WORKFLOW_ID`)
- [ ] Test token refresh (wait >48 minutes or reduce TTL for testing)
- [ ] Monitor Supabase function logs for errors
- [ ] Add analytics/error tracking to Flutter app
- [ ] Test on multiple devices (iOS, Android, Web)
- [ ] Verify CORS headers allow your production domain

## Customization

### Change TTL:

In Edge function (`index.ts`):

```typescript
const sessionPayload = {
  workflow_id: WORKFLOW_ID,
  user: device_id,
  ttl_seconds: 7200, // 2 hours
}
```

### Add metadata to session:

```typescript
const sessionPayload = {
  workflow_id: WORKFLOW_ID,
  user: device_id,
  ttl_seconds: 3600,
  metadata: {
    app_version: "1.0.0",
    platform: "flutter",
  },
}
```

### Custom event parsing:

Update `RealtimeHealthAgentService._handleRealtimeEvent()` to match your workflow's event structure.

## Troubleshooting

### "WebSocket not connected"

**Cause:** Trying to send before connection established.

**Fix:** Check `ConnectionStatus.connected` before sending:

```dart
if (service.isConnected) {
  service.sendMessage('...');
}
```

### Messages not streaming

**Cause:** Event type mismatch (workflow sends different event names).

**Fix:**

1. Log raw events: `print(event.data)`
2. Update `RealtimeEvent.fromJson()` to match actual types
3. Adjust `_handleResponseDelta()` JSON paths

### Session expires too quickly

**Cause:** TTL too short or refresh scheduled too late.

**Fix:**

- Increase TTL in Edge function
- Adjust refresh threshold in `RealtimeSession.shouldRefresh` (e.g., 70% instead of 80%)

## Comparison: Native vs. WebView vs. Server-Side

| Approach                     | Pros                                                                        | Cons                                                     | Use Case                            |
| ---------------------------- | --------------------------------------------------------------------------- | -------------------------------------------------------- | ----------------------------------- |
| **Native WebSocket** (this)  | ✅ No WebView overhead<br>✅ Full Flutter control<br>✅ Token refresh logic | ⚠️ Manual event parsing                                  | Production apps, full customization |
| **WebView + ChatKit SDK**    | ✅ Official SDK<br>✅ Less code                                             | ❌ WebView performance<br>❌ Limited Flutter integration | Quick prototypes                    |
| **Server-Side (Agents SDK)** | ✅ No client-side token management<br>✅ Centralized logging                | ❌ No client-side streaming<br>❌ Server latency         | Enterprise, audit trails            |

## Next Steps

1. **Test with your workflow**: Replace `WORKFLOW_ID` with your actual published workflow
2. **Customize UI**: Adapt `RealtimeAIAssistantScreen` to your design
3. **Add features**:
   - Message persistence (save chat history)
   - User authentication (link device_id to user accounts)
   - Tool response handling (if workflow uses tools)
   - Voice input/output
4. **Monitor & iterate**: Use OpenAI dashboard to see session metrics

## References

- [OpenAI Realtime API Guide](https://platform.openai.com/docs/guides/realtime)
- [ChatKit Sessions API](https://platform.openai.com/docs/guides/chatkit)
- [Realtime WebSocket Docs](https://platform.openai.com/docs/guides/realtime-websocket)
- [Flutter WebSocket Channel](https://pub.dev/packages/web_socket_channel)

---

**Questions?** Check the event logs first. Most issues are event structure mismatches. If stuck, share raw event JSON and I'll help parse it.
