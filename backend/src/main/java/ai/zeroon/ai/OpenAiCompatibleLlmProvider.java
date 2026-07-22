package ai.zeroon.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OpenAiCompatibleLlmProvider implements LlmProvider {

    private static final String PROVIDER_NAME = "openai-compatible";

    private final LlmProperties properties;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    @Autowired
    public OpenAiCompatibleLlmProvider(LlmProperties properties, ObjectMapper objectMapper) {
        this(properties, objectMapper, HttpClient.newHttpClient());
    }

    OpenAiCompatibleLlmProvider(
            LlmProperties properties,
            ObjectMapper objectMapper,
            HttpClient httpClient) {
        this.properties = properties;
        this.objectMapper = objectMapper;
        this.httpClient = httpClient;
    }

    @Override
    public LlmResponse generate(LlmRequest request) {
        if (!PROVIDER_NAME.equalsIgnoreCase(properties.provider())) {
            throw new LlmProviderUnavailableException("Unsupported LLM provider: " + properties.provider());
        }
        if (!properties.configured()) {
            throw new LlmProviderUnavailableException("LLM provider is not configured");
        }

        try {
            String body = objectMapper.writeValueAsString(Map.of(
                    "model", properties.model(),
                    "messages", List.of(
                            Map.of("role", "system", "content", request.systemPrompt()),
                            Map.of("role", "user", "content", request.userPrompt()))));

            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(endpoint())
                    .timeout(resolveTimeout(request.timeout()))
                    .header("Authorization", "Bearer " + properties.apiKey())
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new LlmProviderUnavailableException("LLM provider returned HTTP " + response.statusCode());
            }

            JsonNode root = objectMapper.readTree(response.body());
            JsonNode choice = root.path("choices").path(0);
            String content = choice.path("message").path("content").asText();
            String finishReason = choice.path("finish_reason").asText(null);
            if (content == null || content.isBlank()) {
                throw new LlmProviderUnavailableException("LLM provider returned an empty response");
            }
            JsonNode usage = root.path("usage");
            return new LlmResponse(
                    content,
                    PROVIDER_NAME,
                    properties.model(),
                    finishReason,
                    nonNegativeInteger(usage.path("prompt_tokens")),
                    nonNegativeInteger(usage.path("completion_tokens")));
        } catch (LlmProviderUnavailableException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new LlmProviderUnavailableException("LLM provider request failed", ex);
        }
    }

    private URI endpoint() {
        String baseUrl = properties.baseUrl().strip();
        if (baseUrl.endsWith("/chat/completions")) {
            return URI.create(baseUrl);
        }
        return URI.create(baseUrl.replaceAll("/+$", "") + "/chat/completions");
    }

    private Duration resolveTimeout(Duration requestTimeout) {
        if (requestTimeout == null || requestTimeout.isZero() || requestTimeout.isNegative()) {
            return properties.timeout();
        }
        return requestTimeout;
    }

    private Integer nonNegativeInteger(JsonNode node) {
        if (!node.isIntegralNumber() || !node.canConvertToInt()) {
            return null;
        }
        int value = node.intValue();
        return value < 0 ? null : value;
    }
}
