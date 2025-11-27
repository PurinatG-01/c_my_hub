// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")
const WORKFLOW_ID = Deno.env.get("OPENAI_WORKFLOW_ID") // Set this in your Supabase secrets

console.log("Health Agent ChatKit Service initialized")

Deno.serve(async (req) => {
  try {
    // CORS headers for preflight requests
    if (req.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, Authorization",
        },
      })
    }

    if (req.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 })
    }

    if (!OPENAI_API_KEY) {
      return new Response(
        JSON.stringify({ error: "OpenAI API key not configured" }),
        {
          status: 500,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      )
    }

    if (!WORKFLOW_ID) {
      return new Response(
        JSON.stringify({ error: "Workflow ID not configured" }),
        {
          status: 500,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      )
    }

    const { device_id } = await req.json()

    if (!device_id) {
      return new Response(
        JSON.stringify({ error: "device_id is required" }),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      )
    }

    console.log(`Creating Realtime session for device: ${device_id}`)

    // Create an ephemeral token for OpenAI Realtime API
    // https://platform.openai.com/docs/api-reference/realtime-sessions
    const sessionPayload = {
      model: "gpt-4o-realtime-preview-2024-12-17",
      voice: "alloy",
    }

    const sessionResponse = await fetch("https://api.openai.com/v1/realtime/sessions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(sessionPayload),
    })

    if (!sessionResponse.ok) {
      const errorText = await sessionResponse.text()
      console.error("OpenAI Realtime session creation error:", errorText)
      return new Response(
        JSON.stringify({
          error: "Failed to create Realtime session",
          details: errorText
        }),
        {
          status: sessionResponse.status,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      )
    }

    const sessionData = await sessionResponse.json()

    console.log("Realtime session created successfully:", sessionData.id)

    // Return the client_secret and session details to the Flutter app
    return new Response(
      JSON.stringify({
        client_secret: sessionData.client_secret,
        session: {
          id: sessionData.id,
          expires_at: sessionData.expires_at,
        },
        user: device_id,
      }),
      {
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
        status: 200
      }
    )

  } catch (err) {
    console.error("Error:", err)
    return new Response(
      JSON.stringify({ error: String(err) }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        }
      }
    )
  }
})

/* ChatKit Session Service
 * 
 * This edge function creates ephemeral ChatKit sessions for the Flutter app.
 * 
 * Setup:
 * Set these environment variables in Supabase:
 * - OPENAI_API_KEY: Your OpenAI API key
 * - OPENAI_WORKFLOW_ID: Your published workflow ID (e.g., wf_abc123)
 * 
 * Usage:
 * 
 * POST /functions/v1/health-agent
 * Body: { "device_id": "unique-device-identifier" }
 * 
 * Response: { 
 *   "client_secret": "ek_...",
 *   "session": {
 *     "id": "cksess_...",
 *     "expires_at": "2025-11-24T15:00:00Z",
 *     "ttl_seconds": 3600
 *   },
 *   "workflow_id": "wf_...",
 *   "user": "unique-device-identifier"
 * }
 * 
 * The Flutter app should:
 * 1. Call this endpoint to get a client_secret
 * 2. Use the client_secret to open a WebSocket to wss://api.openai.com/v1/realtime
 * 3. Send input events and listen for streaming responses
 * 4. Refresh the secret before expiry (recommended at 80% of TTL)
 * 
 * To test locally:
 * 
 * curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/health-agent' \
 *   --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
 *   --header 'Content-Type: application/json' \
 *   --data '{"device_id": "test-device-123"}'
 */
