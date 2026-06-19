package ai.zeroon.ai;

public interface LlmProvider {

    LlmResponse generate(LlmRequest request);
}
