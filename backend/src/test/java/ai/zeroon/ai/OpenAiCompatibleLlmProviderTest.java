package ai.zeroon.ai;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

class OpenAiCompatibleLlmProviderTest {

    private HttpServer server;

    @AfterEach
    void stopServer() {
        if (server != null) {
            server.stop(0);
        }
    }

    @Test
    void rejectsMissingProviderConfiguration() {
        var provider = new OpenAiCompatibleLlmProvider(
                new LlmProperties("openai-compatible", "", "", "test-model", 10),
                new ObjectMapper());

        assertThatThrownBy(() -> provider.generate(new LlmRequest("system", "user", Duration.ofSeconds(1))))
                .isInstanceOf(LlmProviderUnavailableException.class)
                .hasMessageContaining("not configured");
    }

    @Test
    void postsOpenAiCompatibleChatCompletionRequest() throws Exception {
        server = HttpServer.create(new InetSocketAddress("localhost", 0), 0);
        server.createContext("/v1/chat/completions", this::handleChatCompletion);
        server.start();

        String baseUrl = "http://localhost:" + server.getAddress().getPort() + "/v1";
        var provider = new OpenAiCompatibleLlmProvider(
                new LlmProperties("openai-compatible", baseUrl, "test-key", "test-model", 10),
                new ObjectMapper());

        LlmResponse response = provider.generate(new LlmRequest(
                "You are ZEROON.",
                "Reflect on this record.",
                Duration.ofSeconds(2)));

        assertThat(response.content()).isEqualTo("A calm reflection.");
        assertThat(response.provider()).isEqualTo("openai-compatible");
        assertThat(response.model()).isEqualTo("test-model");
        assertThat(response.finishReason()).isEqualTo("stop");
        assertThat(response.inputTokens()).isEqualTo(37);
        assertThat(response.outputTokens()).isEqualTo(9);
    }

    private void handleChatCompletion(HttpExchange exchange) throws IOException {
        assertThat(exchange.getRequestMethod()).isEqualTo("POST");
        assertThat(exchange.getRequestHeaders().getFirst("Authorization")).isEqualTo("Bearer test-key");
        String requestBody = new String(exchange.getRequestBody().readAllBytes(), StandardCharsets.UTF_8);
        assertThat(requestBody).contains("test-model");
        assertThat(requestBody).contains("You are ZEROON.");
        assertThat(requestBody).contains("Reflect on this record.");

        byte[] body = """
                {
                  "choices": [
                    {
                      "message": {"content": "A calm reflection."},
                      "finish_reason": "stop"
                    }
                  ],
                  "usage": {
                    "prompt_tokens": 37,
                    "completion_tokens": 9,
                    "total_tokens": 46
                  }
                }
                """.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().add("Content-Type", "application/json");
        exchange.sendResponseHeaders(200, body.length);
        exchange.getResponseBody().write(body);
        exchange.close();
    }
}
