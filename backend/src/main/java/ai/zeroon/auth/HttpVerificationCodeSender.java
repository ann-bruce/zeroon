package ai.zeroon.auth;

import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

@Component
@Profile("prod")
public class HttpVerificationCodeSender implements VerificationCodeSender {

    private final RestClient restClient;
    private final String senderUrl;
    private final String senderToken;

    public HttpVerificationCodeSender(
            RestClient.Builder restClientBuilder,
            @Value("${zeroon.auth.verification-code-sender-url}") String senderUrl,
            @Value("${zeroon.auth.verification-code-sender-token}") String senderToken) {
        this.restClient = restClientBuilder.build();
        this.senderUrl = senderUrl;
        this.senderToken = senderToken;
    }

    @Override
    public void send(String mobile, String code) {
        try {
            restClient.post()
                    .uri(senderUrl)
                    .headers(headers -> headers.setBearerAuth(senderToken))
                    .body(Map.of("mobile", mobile, "code", code))
                    .retrieve()
                    .toBodilessEntity();
        } catch (RestClientException ex) {
            throw new VerificationCodeDeliveryException(ex);
        }
    }
}
