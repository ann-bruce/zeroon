package ai.zeroon.common;

import ai.zeroon.auth.RateLimitExceededException;
import ai.zeroon.auth.VerificationCodeDeliveryException;
import ai.zeroon.auth.VerificationCodeInfrastructureException;
import ai.zeroon.evidence.EvidenceConflictException;
import ai.zeroon.support.SupportConflictException;
import java.util.Map;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(RateLimitExceededException.class)
    ResponseEntity<Map<String, String>> rateLimited(RateLimitExceededException ex) {
        return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS)
                .header(HttpHeaders.RETRY_AFTER, Long.toString(ex.getRetryAfterSeconds()))
                .body(Map.of("error", ex.getError(), "message", ex.getMessage()));
    }

    @ExceptionHandler(VerificationCodeDeliveryException.class)
    @ResponseStatus(HttpStatus.SERVICE_UNAVAILABLE)
    Map<String, String> verificationCodeDelivery(VerificationCodeDeliveryException ex) {
        return Map.of("error", "verification_delivery_unavailable", "message", ex.getMessage());
    }

    @ExceptionHandler(VerificationCodeInfrastructureException.class)
    @ResponseStatus(HttpStatus.SERVICE_UNAVAILABLE)
    Map<String, String> verificationCodeInfrastructure(VerificationCodeInfrastructureException ex) {
        return Map.of("error", "verification_service_unavailable", "message", ex.getMessage());
    }

    @ExceptionHandler(AuthenticationException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    Map<String, String> authentication(AuthenticationException ex) {
        return Map.of("error", "unauthorized", "message", ex.getMessage());
    }

    @ExceptionHandler(AccessDeniedException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    Map<String, String> accessDenied(AccessDeniedException ex) {
        return Map.of("error", "forbidden", "message", ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    Map<String, String> validation(MethodArgumentNotValidException ex) {
        return Map.of("error", "bad_request", "message", "Invalid request body");
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    Map<String, String> unreadable(HttpMessageNotReadableException ex) {
        return Map.of("error", "bad_request", "message", "Invalid request body");
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    Map<String, String> illegalArgument(IllegalArgumentException ex) {
        return Map.of("error", "bad_request", "message", ex.getMessage());
    }

    @ExceptionHandler(EntityNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    Map<String, String> notFound(EntityNotFoundException ex) {
        return Map.of("error", "not_found", "message", ex.getMessage());
    }

    @ExceptionHandler(SupportConflictException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    Map<String, String> conflict(SupportConflictException ex) {
        return Map.of("error", "conflict", "message", ex.getMessage());
    }

    @ExceptionHandler(EvidenceConflictException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    Map<String, String> evidenceConflict(EvidenceConflictException ex) {
        return Map.of("error", "conflict", "message", ex.getMessage());
    }
}
