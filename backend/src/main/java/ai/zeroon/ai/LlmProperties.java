package ai.zeroon.ai;

import java.time.Duration;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class LlmProperties {

    private final String provider;
    private final String baseUrl;
    private final String apiKey;
    private final String model;
    private final Duration timeout;
    private final double temperature;

    public LlmProperties(
            @Value("${zeroon.ai.provider:openai-compatible}") String provider,
            @Value("${zeroon.ai.base-url:}") String baseUrl,
            @Value("${zeroon.ai.api-key:}") String apiKey,
            @Value("${zeroon.ai.model:gpt-4o-mini}") String model,
            @Value("${zeroon.ai.timeout-seconds:10}") long timeoutSeconds,
            @Value("${zeroon.ai.temperature:0.2}") double temperature) {
        this.provider = provider;
        this.baseUrl = baseUrl;
        this.apiKey = apiKey;
        this.model = model;
        this.timeout = Duration.ofSeconds(timeoutSeconds);
        if (!Double.isFinite(temperature) || temperature < 0 || temperature > 2) {
            throw new IllegalArgumentException("LLM temperature must be between 0 and 2");
        }
        this.temperature = temperature;
    }

    public String provider() {
        return provider;
    }

    public String baseUrl() {
        return baseUrl;
    }

    public String apiKey() {
        return apiKey;
    }

    public String model() {
        return model;
    }

    public Duration timeout() {
        return timeout;
    }

    public double temperature() {
        return temperature;
    }

    public boolean configured() {
        return hasText(baseUrl) && hasText(apiKey) && hasText(model);
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }
}
