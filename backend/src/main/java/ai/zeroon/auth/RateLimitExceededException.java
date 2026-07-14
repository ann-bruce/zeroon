package ai.zeroon.auth;

public class RateLimitExceededException extends RuntimeException {

    private final String error;
    private final long retryAfterSeconds;

    public RateLimitExceededException(String error, String message, long retryAfterSeconds) {
        super(message);
        this.error = error;
        this.retryAfterSeconds = Math.max(1, retryAfterSeconds);
    }

    public String getError() {
        return error;
    }

    public long getRetryAfterSeconds() {
        return retryAfterSeconds;
    }
}
