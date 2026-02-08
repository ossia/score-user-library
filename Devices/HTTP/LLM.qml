import Ossia 1.0 as Ossia

/**
 * OpenAI / llama.cpp server compatible LLM client for ossia score.
 *
 * Compatible with: llama.cpp server, Ollama, vLLM, LM Studio,
 * and any server exposing an OpenAI-compatible HTTP API.
 *
 * Setup:
 *   1. Start your LLM server (e.g. llama-server -m model.gguf)
 *   2. Set /config/host to your server URL (default: http://127.0.0.1:8080)
 *   3. Set /config/model to your model name if required
 *
 * Chat (with conversation history):
 *   - Optionally set /config/system_prompt
 *   - Write a message to /chat/prompt to get a response in /chat/response
 *   - Conversation history is maintained across messages
 *   - Send an impulse to /chat/clear to reset the conversation
 *
 * Text completion (single-shot, no history):
 *   - Write text to /completion/prompt to get a continuation in /completion/response
 *
 * Health check:
 *   - Send an impulse to /health/check to query server status
 *
 * Note: Custom HTTP headers (Authorization, Content-Type) are not set by this
 * device. This works out-of-the-box with local servers (llama.cpp, Ollama, etc.)
 * which do not enforce strict header checks. For cloud APIs requiring Bearer
 * tokens, configure a reverse proxy that injects the Authorization header.
 */
Ossia.Http
{
  property var chatHistory: []

  function toStr(v) { var s = Device.toValue(v); return (s !== undefined && s !== null) ? "" + s : ""; }

  function buildChatMessages(userPrompt)
  {
    var messages = [];
    var sys = Device.read("/config/system_prompt");
    if (sys && sys.length > 0)
      messages.push({ role: "system", content: "" + sys });

    for (var i = 0; i < chatHistory.length; i++)
      messages.push(chatHistory[i]);

    messages.push({ role: "user", content: userPrompt });
    return messages;
  }

  function samplingParams()
  {
    return {
      temperature:       Device.read("/config/temperature"),
      max_tokens:        Device.read("/config/max_tokens"),
      top_p:             Device.read("/config/top_p"),
      frequency_penalty: Device.read("/config/frequency_penalty"),
      presence_penalty:  Device.read("/config/presence_penalty"),
      stream:            false
    };
  }

  function createTree()
  {
    return [
      // ── Configuration ─────────────────────────────────────────
      {
        name: "config",
        children: [
          {
            name: "host",
            type: Ossia.Type.String,
            value: "http://127.0.0.1:8080",
            description: "LLM server base URL"
          },
          {
            name: "model",
            type: Ossia.Type.String,
            value: "default",
            description: "Model name or alias"
          },
          {
            name: "system_prompt",
            type: Ossia.Type.String,
            value: "",
            description: "System prompt prepended to chat messages"
          },
          {
            name: "temperature",
            type: Ossia.Type.Float,
            value: 0.8,
            min: 0,
            max: 2,
            description: "Sampling temperature (0 = deterministic, 2 = most random)"
          },
          {
            name: "max_tokens",
            type: Ossia.Type.Int,
            value: 256,
            min: 1,
            max: 16384,
            description: "Maximum number of tokens to generate"
          },
          {
            name: "top_p",
            type: Ossia.Type.Float,
            value: 0.95,
            min: 0,
            max: 1,
            description: "Nucleus sampling threshold"
          },
          {
            name: "frequency_penalty",
            type: Ossia.Type.Float,
            value: 0,
            min: -2,
            max: 2,
            description: "Penalize repeated tokens by frequency"
          },
          {
            name: "presence_penalty",
            type: Ossia.Type.Float,
            value: 0,
            min: -2,
            max: 2,
            description: "Penalize repeated tokens by presence"
          }
        ]
      },

      // ── Chat completions (/v1/chat/completions) ───────────────
      {
        name: "chat",
        children: [
          {
            name: "prompt",
            type: Ossia.Type.String,
            value: "",
            description: "Write a message here to chat with the LLM",
            method: "post",
            request: function(v) {
              return Device.read("/config/host") + "/v1/chat/completions";
            },
            requestData: function(v) {
              var prompt = toStr(v);
              var body = samplingParams();
              body.model    = Device.read("/config/model") || "default";
              body.messages = buildChatMessages(prompt);
              return JSON.stringify(body);
            },
            answer: function(json, promptValue) {
              try {
                var obj = JSON.parse(json);
                if (obj.error) {
                  var msg = obj.error.message || JSON.stringify(obj.error);
                  return [{ address: "/chat/response", value: "Error: " + msg }];
                }

                var choice = obj.choices[0];
                var content = choice.message.content;
                var usage = obj.usage || {};

                chatHistory.push({ role: "user",      content: toStr(promptValue) });
                chatHistory.push({ role: "assistant",  content: content });

                return [
                  { address: "/chat/response",                value: content },
                  { address: "/chat/finish_reason",           value: choice.finish_reason || "" },
                  { address: "/chat/usage/prompt_tokens",     value: usage.prompt_tokens || 0 },
                  { address: "/chat/usage/completion_tokens", value: usage.completion_tokens || 0 },
                  { address: "/chat/usage/total_tokens",      value: usage.total_tokens || 0 }
                ];
              } catch (e) {
                console.log("LLM chat parse error: " + e);
                return [{ address: "/chat/response", value: "Parse error: " + e }];
              }
            }
          },
          {
            name: "response",
            type: Ossia.Type.String,
            value: "",
            description: "Last assistant reply",
            access: Ossia.Access.Get
          },
          {
            name: "finish_reason",
            type: Ossia.Type.String,
            value: "",
            description: "Why generation stopped (stop, length, ...)",
            access: Ossia.Access.Get
          },
          {
            name: "clear",
            type: Ossia.Type.Impulse,
            description: "Clear conversation history",
            request: function() {
              chatHistory = [];
              return Device.read("/config/host") + "/health";
            },
            answer: function(json) {
              return [
                { address: "/chat/response",                value: "" },
                { address: "/chat/finish_reason",           value: "" },
                { address: "/chat/usage/prompt_tokens",     value: 0 },
                { address: "/chat/usage/completion_tokens", value: 0 },
                { address: "/chat/usage/total_tokens",      value: 0 }
              ];
            }
          },
          {
            name: "usage",
            children: [
              { name: "prompt_tokens",     type: Ossia.Type.Int, value: 0, access: Ossia.Access.Get },
              { name: "completion_tokens", type: Ossia.Type.Int, value: 0, access: Ossia.Access.Get },
              { name: "total_tokens",      type: Ossia.Type.Int, value: 0, access: Ossia.Access.Get }
            ]
          }
        ]
      },

      // ── Text completions (/v1/completions) ────────────────────
      {
        name: "completion",
        children: [
          {
            name: "prompt",
            type: Ossia.Type.String,
            value: "",
            description: "Write text here for completion (no chat history)",
            method: "post",
            request: function(v) {
              return Device.read("/config/host") + "/v1/completions";
            },
            requestData: function(v) {
              var body = samplingParams();
              body.model  = Device.read("/config/model") || "default";
              body.prompt = toStr(v);
              return JSON.stringify(body);
            },
            answer: function(json) {
              try {
                var obj = JSON.parse(json);
                if (obj.error) {
                  var msg = obj.error.message || JSON.stringify(obj.error);
                  return [{ address: "/completion/response", value: "Error: " + msg }];
                }

                var choice = obj.choices[0];
                return [
                  { address: "/completion/response",      value: choice.text || "" },
                  { address: "/completion/finish_reason",  value: choice.finish_reason || "" }
                ];
              } catch (e) {
                console.log("LLM completion parse error: " + e);
                return [{ address: "/completion/response", value: "Parse error: " + e }];
              }
            }
          },
          {
            name: "response",
            type: Ossia.Type.String,
            value: "",
            description: "Completion result",
            access: Ossia.Access.Get
          },
          {
            name: "finish_reason",
            type: Ossia.Type.String,
            value: "",
            access: Ossia.Access.Get
          }
        ]
      },

      // ── Health check ──────────────────────────────────────────
      {
        name: "health",
        children: [
          {
            name: "check",
            type: Ossia.Type.Impulse,
            description: "Send impulse to check server health",
            request: function() {
              return Device.read("/config/host") + "/health";
            },
            answer: function(json) {
              try {
                var obj = JSON.parse(json);
                return [{ address: "/health/status", value: obj.status || "unknown" }];
              } catch (e) {
                return [{ address: "/health/status", value: "error" }];
              }
            }
          },
          {
            name: "status",
            type: Ossia.Type.String,
            value: "unknown",
            description: "Server health status",
            access: Ossia.Access.Get
          }
        ]
      }
    ];
  }
}
