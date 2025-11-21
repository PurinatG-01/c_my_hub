// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")
const WORKFLOW_ID = "wf_690b57c50db08190b1b4a7d44e8f884a0d58893a1aea4892"

console.log("Health Agent Function initialized")

// Helper function to create SSE message
function createSSEMessage(event: string, data: any): string {
  return `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`
}

Deno.serve(async (req) => {
  try {
    // Check if method is allowed
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed. Use POST." }),
        { status: 405, headers: { "Content-Type": "application/json" } }
      )
    }

    if (!OPENAI_API_KEY) {
      return new Response(
        JSON.stringify({ error: "OpenAI API key not configured" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      )
    }

    // Parse the incoming request
    let requestBody
    try {
      const text = await req.text()
      requestBody = text ? JSON.parse(text) : {}
    } catch (parseError) {
      console.error("JSON parse error:", parseError)
      return new Response(
        JSON.stringify({ 
          error: "Invalid JSON in request body",
          message: parseError instanceof Error ? parseError.message : "Unknown parse error"
        }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      )
    }

    // Extract message and user info
    const { message, user, deviceId, stream = true } = requestBody

    if (!message) {
      return new Response(
        JSON.stringify({ error: "Message is required" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      )
    }

    const userId = user || deviceId || "anonymous"

    // Step 1: Create ChatKit session
    console.log("Creating ChatKit session for user:", userId)
    
    const sessionResponse = await fetch(
      "https://api.openai.com/v1/chatkit/sessions",
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${OPENAI_API_KEY}`,
          "Content-Type": "application/json",
          "OpenAI-Beta": "chatkit_beta=v1",
        },
        body: JSON.stringify({
          workflow: { id: WORKFLOW_ID },
          user: userId,
        }),
      }
    )

    if (!sessionResponse.ok) {
      const errorText = await sessionResponse.text()
      console.error("Failed to create session:", errorText)
      return new Response(
        JSON.stringify({ 
          error: "Failed to create ChatKit session",
          details: errorText 
        }),
        { status: sessionResponse.status, headers: { "Content-Type": "application/json" } }
      )
    }

    const sessionData = await sessionResponse.json()
    const sessionId = sessionData.id
    const clientSecret = sessionData.client_secret
    console.log("Session created:", sessionId)

    // Step 2: Connect to ChatKit WebSocket and send message
    if (stream) {
      // Create Server-Sent Events stream
      const responseStream = new ReadableStream({
        async start(controller) {
          const encoder = new TextEncoder()
          
          try {
            // Send session info
            controller.enqueue(
              encoder.encode(createSSEMessage("session", {
                sessionId,
                userId,
                workflowId: WORKFLOW_ID
              }))
            )

            // Connect to ChatKit WebSocket
            // The client_secret is used for client-side SDKs
            // For server-side, we should use the API key
            const wsUrl = `wss://api.openai.com/v1/chatkit/sessions/${sessionId}/ws?api_key=${OPENAI_API_KEY}`
            console.log("Connecting to ChatKit WebSocket for session:", sessionId)

            const ws = new WebSocket(wsUrl)
            let authenticated = false

            // Setup message handler first to catch all messages including auth confirmation
            ws.onmessage = (event) => {
              try {
                const data = JSON.parse(event.data)
                console.log("Received from ChatKit:", data.type)

                // Handle session update confirmation (authentication success)
                if (data.type === "session.updated") {
                  console.log("Session authenticated")
                  authenticated = true
                  return
                }

                // Forward relevant events to Flutter via SSE
                if (data.type === "response.text.delta") {
                  // Streaming text chunk
                  controller.enqueue(
                    encoder.encode(createSSEMessage("chunk", {
                      text: data.delta,
                      sessionId
                    }))
                  )
                } else if (data.type === "response.text.done") {
                  // Text completion
                  controller.enqueue(
                    encoder.encode(createSSEMessage("text_done", {
                      text: data.text,
                      sessionId
                    }))
                  )
                } else if (data.type === "response.done") {
                  // Response complete
                  controller.enqueue(
                    encoder.encode(createSSEMessage("response_done", {
                      sessionId,
                      response: data.response
                    }))
                  )
                  
                  // Close connection after response is complete
                  ws.close()
                  controller.enqueue(
                    encoder.encode(createSSEMessage("done", { sessionId }))
                  )
                  controller.close()
                } else if (data.type === "error") {
                  // Error from ChatKit
                  console.error("ChatKit error:", data)
                  controller.enqueue(
                    encoder.encode(createSSEMessage("error", {
                      message: data.error?.message || "Unknown error from ChatKit",
                      code: data.error?.code
                    }))
                  )
                  ws.close()
                  controller.close()
                }
              } catch (parseError) {
                console.error("Error parsing ChatKit message:", parseError)
              }
            }

            ws.onerror = (error) => {
              console.error("WebSocket error:", error)
              controller.enqueue(
                encoder.encode(createSSEMessage("error", {
                  message: "WebSocket connection error"
                }))
              )
              controller.close()
            }

            ws.onclose = () => {
              console.log("WebSocket closed")
              if (!controller.desiredSize) {
                controller.close()
              }
            }

            // Wait for connection to open and send messages
            await new Promise<void>((resolve, reject) => {
              let connected = false
              const connectionTimeout = setTimeout(() => {
                if (!connected) {
                  ws.close()
                  reject(new Error("WebSocket connection timeout"))
                }
              }, 10000)
              
              ws.onopen = () => {
                console.log("WebSocket connected")
                connected = true
                clearTimeout(connectionTimeout)
                
                try {
                  // Send user message to ChatKit (no auth needed - session ID in URL is auth)
                  const userMessage = {
                    type: "conversation.item.create",
                    item: {
                      type: "message",
                      role: "user",
                      content: [
                        {
                          type: "input_text",
                          text: message
                        }
                      ]
                    }
                  }

                  ws.send(JSON.stringify(userMessage))
                  console.log("User message sent to ChatKit")

                  // Request response generation
                  ws.send(JSON.stringify({
                    type: "response.create"
                  }))
                  console.log("Response creation requested")
                  
                  resolve()
                } catch (sendError) {
                  console.error("Error sending messages:", sendError)
                  reject(sendError)
                }
              }
              
              const originalOnError = ws.onerror
              ws.onerror = (error) => {
                if (originalOnError) originalOnError.call(ws, error)
                clearTimeout(connectionTimeout)
                if (!connected) {
                  reject(new Error("Failed to connect to ChatKit WebSocket"))
                }
              }
            })

          } catch (error) {
            console.error("Streaming error:", error)
            controller.enqueue(
              encoder.encode(createSSEMessage("error", {
                message: error instanceof Error ? error.message : "Unknown error"
              }))
            )
            controller.close()
          }
        },
      })

      return new Response(responseStream, {
        headers: {
          "Content-Type": "text/event-stream",
          "Cache-Control": "no-cache",
          "Connection": "keep-alive",
        },
      })
    }

    // Non-streaming response: return session data
    return new Response(
      JSON.stringify({
        success: true,
        session: sessionData,
        message: "Session created successfully. Use client_secret to connect via ChatKit SDK."
      }),
      { headers: { "Content-Type": "application/json" } }
    )
  } catch (error) {
    console.error("Error in health agent:", error)
    const errorMessage = error instanceof Error ? error.message : "Unknown error"
    return new Response(
      JSON.stringify({ 
        error: "Internal server error",
        message: errorMessage 
      }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    )
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/health-agent' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
