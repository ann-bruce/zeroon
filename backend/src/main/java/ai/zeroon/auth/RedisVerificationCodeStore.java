package ai.zeroon.auth;

import java.time.Duration;
import java.util.List;
import org.springframework.context.annotation.Profile;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Component;

@Component
@Profile({"prod", "smtp-smoke"})
public class RedisVerificationCodeStore implements VerificationCodeStore {

    private static final DefaultRedisScript<Long> STORE_SCRIPT = new DefaultRedisScript<>("""
            redis.call('HSET', KEYS[1], 'code', ARGV[1], 'failedAttempts', '0')
            redis.call('PEXPIRE', KEYS[1], ARGV[2])
            return 1
            """, Long.class);

    private static final DefaultRedisScript<Long> VERIFY_SCRIPT = new DefaultRedisScript<>("""
            if redis.call('EXISTS', KEYS[1]) == 0 then
              return 0
            end
            if redis.call('HGET', KEYS[1], 'code') == ARGV[1] then
              redis.call('DEL', KEYS[1])
              return 1
            end
            local attempts = redis.call('HINCRBY', KEYS[1], 'failedAttempts', 1)
            if attempts >= tonumber(ARGV[2]) then
              redis.call('DEL', KEYS[1])
              return 2
            end
            return 0
            """, Long.class);

    private static final DefaultRedisScript<Long> RATE_SCRIPT = new DefaultRedisScript<>("""
            local count = redis.call('INCR', KEYS[1])
            if count == 1 then
              redis.call('PEXPIRE', KEYS[1], ARGV[2])
            end
            if count > tonumber(ARGV[1]) then
              local ttl = redis.call('PTTL', KEYS[1])
              if ttl < 1 then ttl = tonumber(ARGV[2]) end
              return -ttl
            end
            return 0
            """, Long.class);

    private final StringRedisTemplate redisTemplate;

    public RedisVerificationCodeStore(StringRedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    @Override
    public void store(String mobile, String code, Duration ttl) {
        try {
            redisTemplate.execute(
                    STORE_SCRIPT,
                    List.of(VerificationCodeKeyFactory.code(mobile)),
                    code,
                    Long.toString(ttl.toMillis()));
        } catch (DataAccessException ex) {
            throw new VerificationCodeInfrastructureException(ex);
        }
    }

    @Override
    public VerificationResult verify(String mobile, String code, int maxFailedAttempts) {
        try {
            Long result = redisTemplate.execute(
                    VERIFY_SCRIPT,
                    List.of(VerificationCodeKeyFactory.code(mobile)),
                    code,
                    Integer.toString(maxFailedAttempts));
            if (result == null || result == 0) {
                return VerificationResult.INVALID;
            }
            if (result == 1) {
                return VerificationResult.VALID;
            }
            return VerificationResult.ATTEMPTS_EXHAUSTED;
        } catch (DataAccessException ex) {
            throw new VerificationCodeInfrastructureException(ex);
        }
    }

    @Override
    public RateLimitDecision acquire(String scope, String subject, int limit, Duration window) {
        try {
            Long result = redisTemplate.execute(
                    RATE_SCRIPT,
                    List.of(VerificationCodeKeyFactory.rate(scope, subject)),
                    Integer.toString(limit),
                    Long.toString(window.toMillis()));
            if (result == null) {
                throw new VerificationCodeInfrastructureException(null);
            }
            if (result >= 0) {
                return new RateLimitDecision(true, 0);
            }
            return new RateLimitDecision(false, Math.max(1, Math.abs(result) / 1000));
        } catch (DataAccessException ex) {
            throw new VerificationCodeInfrastructureException(ex);
        }
    }
}
