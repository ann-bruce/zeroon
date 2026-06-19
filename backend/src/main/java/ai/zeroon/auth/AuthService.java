package ai.zeroon.auth;

import ai.zeroon.auth.AuthDtos.AuthResponse;
import ai.zeroon.auth.AuthDtos.UserPayload;
import ai.zeroon.security.TokenService;
import ai.zeroon.security.UserPrincipal;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import java.time.Duration;
import java.time.Instant;
import java.util.UUID;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final VerificationCodeService verificationCodeService;
    private final UserRepository userRepository;
    private final RefreshSessionRepository refreshSessionRepository;
    private final TokenService tokenService;

    public AuthService(
            VerificationCodeService verificationCodeService,
            UserRepository userRepository,
            RefreshSessionRepository refreshSessionRepository,
            TokenService tokenService) {
        this.verificationCodeService = verificationCodeService;
        this.userRepository = userRepository;
        this.refreshSessionRepository = refreshSessionRepository;
        this.tokenService = tokenService;
    }

    public void requestCode(String mobile) {
        verificationCodeService.requestCode(mobile);
    }

    @Transactional
    public AuthResponse login(String mobile, String code, String deviceId) {
        if (!verificationCodeService.verify(mobile, code)) {
            throw new BadCredentialsException("Invalid verification code");
        }
        UserEntity user = userRepository.findByMobile(mobile)
                .orElseGet(() -> userRepository.save(new UserEntity(createUid(), mobile)));
        return createSession(user, deviceId);
    }

    @Transactional
    public AuthResponse refresh(String refreshToken) {
        RefreshSessionEntity existing = findValidSession(refreshToken);
        existing.revoke();
        return createSession(existing.getUser(), existing.getDeviceId());
    }

    @Transactional
    public void logout(UserPrincipal principal, String refreshToken) {
        RefreshSessionEntity session = findValidSession(refreshToken);
        if (!session.getUser().getId().equals(principal.userId())) {
            throw new AccessDeniedException("Refresh token does not belong to current user");
        }
        session.revoke();
    }

    private RefreshSessionEntity findValidSession(String refreshToken) {
        String tokenHash = tokenService.hashRefreshToken(refreshToken);
        RefreshSessionEntity session = refreshSessionRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new BadCredentialsException("Invalid refresh token"));
        if (session.getRevokedAt() != null || session.getExpiresAt().isBefore(Instant.now())) {
            throw new BadCredentialsException("Invalid refresh token");
        }
        return session;
    }

    private AuthResponse createSession(UserEntity user, String deviceId) {
        TokenService.AccessToken accessToken = tokenService.createAccessToken(user);
        TokenService.RefreshToken refreshToken = tokenService.createRefreshToken();
        refreshSessionRepository.save(new RefreshSessionEntity(
                user,
                tokenService.hashRefreshToken(refreshToken.token()),
                deviceId,
                refreshToken.expiresAt()));
        long expiresIn = Duration.between(Instant.now(), accessToken.expiresAt()).toSeconds();
        return new AuthResponse(
                accessToken.token(),
                refreshToken.token(),
                expiresIn,
                new UserPayload(user.getId(), user.getUid(), user.getMobile(), user.getCurrentState().name()));
    }

    private String createUid() {
        return "u" + UUID.randomUUID().toString().replace("-", "").substring(0, 24);
    }
}
