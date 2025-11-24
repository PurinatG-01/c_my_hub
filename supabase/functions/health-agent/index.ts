// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")

console.log("Health Agent Service initialized")

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

    const { message, session_id } = await req.json()

    if (!message) {
      return new Response(
        JSON.stringify({ error: "Message is required" }),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      )
    }

    console.log("Processing health assistant request")

    // Use OpenAI Chat Completions API with a health assistant system prompt
    const payload = {
      model: "gpt-4-turbo-preview",
      messages: [
        {
          role: "system",
          content: `You are a knowledgeable health and wellness assistant. Your role is to:
- Provide evidence-based health information and wellness tips
- Encourage healthy lifestyle choices
- Help users understand health metrics and data
- Offer motivation and support for health goals
- Suggest when to consult healthcare professionals

Important: You are not a doctor. Always remind users to consult healthcare professionals for medical advice, diagnosis, or treatment.`
        },
        {
          role: "user",
          content: message
        }
      ],
      temperature: 0.7,
      max_tokens: 500
    }

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error("OpenAI API error:", errorText)
      return new Response(errorText, {
        status: response.status,
        headers: {
          "Access-Control-Allow-Origin": "*"
        }
      })
    }

    const data = await response.json()
    const output = data.choices?.[0]?.message?.content ?? "I'm sorry, I couldn't generate a response."

    console.log("Response received successfully")

    return new Response(
      JSON.stringify({
        session_id: session_id ?? null,
        output,
        raw: data
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
})/* ChatKit Session Service
 * 
 * This edge function creates ChatKit sessions for the Flutter app.
 * 
 * Usage:
 * 
 * POST /functions/v1/health-agent
 * Body: { "deviceId": "user-device-id" }
 * 
 * Response: { 
 *   "client_secret": "ek_...",
 *   "session_id": "cksess_...",
 *   "user": "user-device-id",
 *   "workflow_id": "wf_..."
 * }
 * 
 * The Flutter app should:
 * 1. Call this endpoint to get a client_secret
 * 2. Use the client_secret with ChatKit SDK to connect to the chat
 * 3. The ChatKit SDK will handle WebSocket connections and streaming
 * 
 * To test locally:
 * 
 * curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/health-agent' \
 *   --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
 *   --header 'Content-Type: application/json' \
 *   --data '{"deviceId": "test-device-123"}'
 */
