package ai.zeroon.auth;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class VerificationCodeService {

    private final VerificationCodeSender sender;
    private final Map<String, CodeEntry> codes = new ConcurrentHashMap<>();
    private final Duration ttl;
    private final String localCode;

    public VerificationCodeService(
            VerificationCodeSender sender,
            @Value("${zeroon.auth.local-verification-code:000000}") String localCode,
            @Value("${zeroon.auth.verification-code-ttl-minutes:10}") long ttlMinutes) {
        this.sender = sender;
        this.localCode = localCode;
        this.ttl = Duration.ofMinutes(ttlMinutes);
    }

    public void requestCode(String mobile) {
        codes.put(mobile, new CodeEntry(localCode, Instant.now().plus(ttl)));
        sender.send(mobile, localCode);
    }

    public boolean verify(String mobile, String code) {
        CodeEntry entry = codes.get(mobile);
        if (entry == null || entry.expiresAt().isBefore(Instant.now()) || !entry.code().equals(code)) {
            return false;
        }
        codes.remove(mobile);
        return true;
    }

    private record CodeEntry(String code, Instant expiresAt) {
    }
}
