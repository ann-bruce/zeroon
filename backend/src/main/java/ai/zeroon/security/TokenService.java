package ai.zeroon.security;

import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRole;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.EnumSet;
import java.util.Map;
import java.util.Set;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class TokenService {

    private static final Base64.Encoder BASE64_URL_ENCODER = Base64.getUrlEncoder().withoutPadding();
    private static final Base64.Decoder BASE64_URL_DECODER = Base64.getUrlDecoder();

    private final ObjectMapper objectMapper;
    private final SecureRandom secureRandom = new SecureRandom();
    private final byte[] accessTokenSecret;
    private final Duration accessTokenTtl;
    private final Duration refreshTokenTtl;

    public TokenService(
            ObjectMapper objectMapper,
            @Value("${zeroon.auth.access-token-secret}") String accessTokenSecret,
            @Value("${zeroon.auth.access-token-ttl-minutes:30}") long accessTokenTtlMinutes,
            @Value("${zeroon.auth.refresh-token-ttl-days:30}") long refreshTokenTtlDays) {
        this.objectMapper = objectMapper;
        this.accessTokenSecret = accessTokenSecret.getBytes(StandardCharsets.UTF_8);
        this.accessTokenTtl = Duration.ofMinutes(accessTokenTtlMinutes);
        this.refreshTokenTtl = Duration.ofDays(refreshTokenTtlDays);
    }

    public AccessToken createAccessToken(UserEntity user) {
        Instant issuedAt = Instant.now();
        Instant expiresAt = issuedAt.plus(accessTokenTtl);
        try {
            String header = encodeJson(Map.of("alg", "HS256", "typ", "JWT"));
            String payload = encodeJson(Map.of(
                    "sub", user.getId().toString(),
                    "uid", user.getUid(),
                    "roles", user.getRoles().stream().map(UserRole::name).sorted().toList(),
                    "iat", issuedAt.getEpochSecond(),
                    "exp", expiresAt.getEpochSecond()));
            String signature = sign(header + "." + payload);
            return new AccessToken(header + "." + payload + "." + signature, expiresAt);
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to create access token", ex);
        }
    }

    public UserPrincipal verifyAccessToken(String token) {
        try {
            String[] parts = token.split("\\.");
            if (parts.length != 3) {
                return null;
            }
            String expectedSignature = sign(parts[0] + "." + parts[1]);
            if (!MessageDigest.isEqual(
                    expectedSignature.getBytes(StandardCharsets.UTF_8),
                    parts[2].getBytes(StandardCharsets.UTF_8))) {
                return null;
            }
            JsonNode payload = objectMapper.readTree(BASE64_URL_DECODER.decode(parts[1]));
            if (payload.path("exp").asLong() <= Instant.now().getEpochSecond()) {
                return null;
            }
            Set<UserRole> roles = EnumSet.noneOf(UserRole.class);
            JsonNode roleClaims = payload.path("roles");
            if (roleClaims.isArray()) {
                for (JsonNode roleClaim : roleClaims) {
                    try {
                        roles.add(UserRole.valueOf(roleClaim.asText()));
                    } catch (IllegalArgumentException ignored) {
                        // Unknown roles never grant authority.
                    }
                }
            }
            if (roles.isEmpty()) {
                return null;
            }
            return new UserPrincipal(
                    payload.path("sub").asLong(),
                    payload.path("uid").asText(),
                    roles);
        } catch (Exception ex) {
            return null;
        }
    }

    public RefreshToken createRefreshToken() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return new RefreshToken(BASE64_URL_ENCODER.encodeToString(bytes), Instant.now().plus(refreshTokenTtl));
    }

    public String hashRefreshToken(String refreshToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(refreshToken.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to hash refresh token", ex);
        }
    }

    private String encodeJson(Map<String, Object> value) throws Exception {
        return BASE64_URL_ENCODER.encodeToString(objectMapper.writeValueAsBytes(value));
    }

    private String sign(String content) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(accessTokenSecret, "HmacSHA256"));
        return BASE64_URL_ENCODER.encodeToString(mac.doFinal(content.getBytes(StandardCharsets.UTF_8)));
    }

    public record AccessToken(String token, Instant expiresAt) {
    }

    public record RefreshToken(String token, Instant expiresAt) {
    }
}
