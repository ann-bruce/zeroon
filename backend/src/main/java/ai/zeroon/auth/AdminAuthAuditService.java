package ai.zeroon.auth;

import ai.zeroon.user.UserEntity;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminAuthAuditService {

    private final AuditEventRepository repository;

    public AdminAuthAuditService(AuditEventRepository repository) {
        this.repository = repository;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(UserEntity actor, String action, String email, Map<String, Object> metadata) {
        repository.save(new AuditEventEntity(
                actor,
                action,
                "ADMIN_ACCOUNT",
                fingerprint(email),
                UUID.randomUUID().toString(),
                metadata));
    }

    private String fingerprint(String value) {
        try {
            return HexFormat.of().formatHex(
                    MessageDigest.getInstance("SHA-256")
                            .digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is unavailable", ex);
        }
    }
}
