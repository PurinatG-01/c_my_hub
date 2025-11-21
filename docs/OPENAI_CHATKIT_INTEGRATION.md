# OpenAI ChatKit Workflow Integration

## Overview

This document describes the integration of OpenAI's ChatKit workflow system with the Supabase Edge Function for the C My Hub application.

## What We've Done

### 1. Created Supabase Edge Function

- **Location**: `/supabase/functions/health-agent/index.ts`
- **Purpose**: Acts as a proxy between Flutter app and OpenAI's ChatKit API
- **Endpoint**: `POST /functions/v1/health-agent`

### 2. OpenAI Workflow Configuration

- **Workflow ID**: `wf_690b57c50db08190b1b4a7d44e8f884a0d58893a1aea4892`
- **Version**: `2`
- **Source**: Created in OpenAI's Agent Builder
- **API**: Uses ChatKit API for workflow invocation

### 3. Authentication Setup

- **Environment Variable**: `OPENAI_API_KEY`
- **Location**: Set in Supabase project settings under Edge Functions secrets
- **How to Set**:

  ```bash
  # Via CLI
  supabase secrets set OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx

  # Or via Dashboard
  Settings → Edge Functions → Secrets → Add secret
  ```

### 4. Current Implementation: Full WebSocket Proxy with SSE - **Option B** ✅

The edge function now implements a complete proxy between Flutter and ChatKit's WebSocket, streaming responses via Server-Sent Events.

#### Features Implemented:

- ✅ Creates ChatKit session automatically
- ✅ Connects to ChatKit WebSocket using client_secret
- ✅ Proxies messages between Flutter and ChatKit
- ✅ Streams responses in real-time via SSE
- ✅ Handles all WebSocket events and errors
- ✅ No ChatKit SDK needed on Flutter side

**Request Format**:

```json
{
  "message": "Your health question here",
  "user": "user-device-id",
  "deviceId": "optional-device-id",
  "stream": true
}
```

**SSE Event Types** (when `stream: true`):

| Event           | Description            | Data                              |
| --------------- | ---------------------- | --------------------------------- |
| `session`       | Session created        | `{sessionId, userId, workflowId}` |
| `chunk`         | Streaming text chunk   | `{text, sessionId}`               |
| `text_done`     | Complete text received | `{text, sessionId}`               |
| `response_done` | Response completed     | `{sessionId, response}`           |
| `done`          | Stream finished        | `{sessionId}`                     |
| `error`         | Error occurred         | `{message, code}`                 |

**Example SSE Stream**:

```
event: session
data: {"sessionId":"cksess_...","userId":"user-123","workflowId":"wf_..."}

event: chunk
data: {"text":"Hello","sessionId":"cksess_..."}

event: chunk
data: {"text":" there!","sessionId":"cksess_..."}

event: text_done
data: {"text":"Hello there! How can I help?","sessionId":"cksess_..."}

event: response_done
data: {"sessionId":"cksess_...","response":{...}}

event: done
data: {"sessionId":"cksess_..."}
```

**Non-Streaming Response** (when `stream: false`):

```json
{
  "success": true,
  "session": {
    "id": "cksess_...",
    "client_secret": "ek_...",
    "user": "test-user-123",
    "workflow": {
      "id": "wf_690b57c50db08190b1b4a7d44e8f884a0d58893a1aea4892"
    }
  },
  "message": "Session created successfully"
}
```

- `error` - Error information

Example SSE events:

```
event: session
data: {"sessionId":"cksess_...","userId":"test-user","workflowId":"wf_..."}

event: message
data: {"type":"info","content":"ChatKit session created...","sessionId":"cksess_..."}

event: done
data: {"sessionId":"cksess_..."}
```

### 5. API Endpoint Details

**OpenAI ChatKit Sessions API**:

- **URL**: `https://api.openai.com/v1/chatkit/sessions`
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer ${OPENAI_API_KEY}`
  - `Content-Type: application/json`
  - `OpenAI-Beta: chatkit_beta=v1`
- **Body**:
  ```json
  {
    "workflow": { "id": "workflow_id" },
    "user": "user_identifier"
  }
  ```

## Implementation Status: Option A - SSE Streaming ✅

### Completed

1. ✅ **SSE Streaming Support** - Edge function can stream responses
2. ✅ **Session Management** - Automatic ChatKit session creation
3. ✅ **Dual Mode Support** - Both streaming and non-streaming responses
4. ✅ **Error Handling** - Comprehensive error catching and reporting

### Architecture Flow

```
Flutter App
    ↓ POST /functions/v1/health-agent
    ↓ { message, user, stream: true }
    ↓
Edge Function
    ↓ 1. Create ChatKit Session
    ↓ 2. Open SSE Stream
    ↓ 3. Send session event
    ↓ 4. TODO: Connect to ChatKit WebSocket
    ↓ 5. Forward messages as SSE events
    ↓ 6. Send done event
    ↓
Flutter App (SSE Listener)
    ↓ Receive and display messages in real-time
```

### Next Steps

1. **ChatKit WebSocket Integration** (Pending)

   - Connect to ChatKit using client_secret
   - Forward messages between ChatKit and SSE stream
   - Handle bidirectional communication

2. **Flutter SSE Client** (To Do)

   - Implement SSE listener in Flutter
   - Create chat UI to display streaming messages
   - Handle reconnection and error states

3. **Session Persistence** (Future)
   - Store sessions for continued conversations
   - Implement session refresh
   - Add session cleanup

### Benefits of Option A (SSE)

- ✅ Real-time streaming responses (like ChatGPT)
- ✅ Simple Flutter implementation (standard HTTP/SSE)
- ✅ No WebSocket complexity on client side
- ✅ Works with standard HTTP libraries
- ✅ Server handles ChatKit complexity
- Secure API key storage
- Better error handling

## Testing

### Local Testing

````bash
## Testing

### Local Testing - Non-Streaming Mode
```bash
# Start Supabase locally
supabase start

# Set environment variable
export OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx

# Serve function
supabase functions serve health-agent

# Test without streaming
curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/health-agent' \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
  --header 'Content-Type: application/json' \
  --data '{"message": "Hello, I need health advice", "user": "test-user-123", "stream": false}'
````

### Local Testing - Streaming Mode (SSE)

```bash
# Test with streaming enabled
curl -N --location --request POST 'http://127.0.0.1:54321/functions/v1/health-agent' \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
  --header 'Content-Type: application/json' \
  --data '{"message": "Hello, I need health advice", "user": "test-user-123", "stream": true}'

# Note: -N flag keeps connection open for streaming
```

````

### Deployment

```bash
# Deploy to Supabase
supabase functions deploy health-agent
````

## Troubleshooting

### Common Issues

1. **"OpenAI API key not configured"**

   - Set the `OPENAI_API_KEY` secret in Supabase
   - Verify it's accessible via `Deno.env.get("OPENAI_API_KEY")`

2. **"Invalid URL" errors**

   - Verified correct endpoint: `/v1/chatkit/sessions`
   - Required header: `OpenAI-Beta: chatkit_beta=v1`

3. **"Unknown parameter" errors**

   - ChatKit sessions API only accepts: `workflow.id` and `user`
   - Don't send: `version`, `input`, or extra parameters

4. **JSON parse errors**
   - Ensure request body is valid JSON
   - Empty body defaults to `{}`

## References

- [OpenAI Platform](https://platform.openai.com)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [OpenAI Agent Builder](https://platform.openai.com/agent-builder)
- ChatKit React Example (for reference): `@openai/chatkit-react`

## Git History

**Date**: November 17, 2025
**Branch**: `feat/integrate_system`
**Files Modified**:

- `/supabase/functions/health-agent/index.ts`
  - Added OpenAI ChatKit session creation
  - Implemented SSE streaming support
  - Added dual-mode support (streaming and non-streaming)
  - Implemented error handling and logging
  - Set up proper authentication with OPENAI_API_KEY

## Future Enhancements

### Phase 1: Complete ChatKit Integration (Current Priority)

1. **WebSocket Connection to ChatKit**

   - Use client_secret to connect to ChatKit WebSocket
   - Implement message forwarding between ChatKit and SSE
   - Handle real-time workflow responses

2. **Flutter SSE Client Implementation**
   - Create Dart service to handle SSE connections
   - Build chat UI for real-time message display
   - Implement retry and reconnection logic

### Phase 2: Enhanced Features

1. **Session Management**

   - Store and reuse sessions in Supabase
   - Handle session expiration and refresh
   - Implement session cleanup on user logout

2. **Conversation History**
   - Save conversation threads
   - Retrieve previous conversations
   - Export conversation history

### Phase 3: Production Optimization

1. **Performance & Monitoring**
   - Connection pooling for ChatKit sessions
   - Caching and rate limiting
   - Usage analytics and cost monitoring

## Flutter Integration Example

```dart
// SSE Client Service
class HealthAgentService {
  final String baseUrl = 'YOUR_SUPABASE_URL';

  Stream<Map<String, dynamic>> sendMessage({
    required String message,
    required String userId,
  }) async* {
    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/functions/v1/health-agent'),
    );

    request.body = jsonEncode({
      'message': message,
      'user': userId,
      'stream': true,
    });

    final response = await request.send();
    await for (var chunk in response.stream.transform(utf8.decoder)) {
      // Parse SSE events
      yield parseSseEvent(chunk);
    }
  }
}
```
