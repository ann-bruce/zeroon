package ai.zeroon.myzeroon;

import ai.zeroon.myzeroon.ZeroonCompanionDtos.MeetZeroonCompanionRequest;
import ai.zeroon.myzeroon.ZeroonCompanionDtos.ZeroonCompanionResponse;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserZeroonCompanionService {

    private static final DateTimeFormatter NAMEPLATE_DATE = DateTimeFormatter.BASIC_ISO_DATE;
    private static final char[] NAMEPLATE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".toCharArray();
    private static final int MAX_NAMEPLATE_ATTEMPTS = 20;

    private final UserRepository userRepository;
    private final UserZeroonCompanionRepository companionRepository;
    private final SecureRandom secureRandom = new SecureRandom();

    public UserZeroonCompanionService(
            UserRepository userRepository,
            UserZeroonCompanionRepository companionRepository) {
        this.userRepository = userRepository;
        this.companionRepository = companionRepository;
    }

    @Transactional(readOnly = true)
    public ZeroonCompanionResponse get(Long userId) {
        return companionRepository.findByUserId(userId)
                .map(this::toDto)
                .orElseGet(this::notMet);
    }

    @Transactional
    public ZeroonCompanionResponse meet(Long userId, MeetZeroonCompanionRequest request) {
        return companionRepository.findByUserId(userId)
                .map(this::toDto)
                .orElseGet(() -> create(userId, request));
    }

    private ZeroonCompanionResponse create(Long userId, MeetZeroonCompanionRequest request) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        ZeroonCompanionKey companionKey = request.companionKey() == null
                ? ZeroonCompanionKey.ZEROON_DEFAULT
                : request.companionKey();
        return toDto(companionRepository.save(new UserZeroonCompanionEntity(
                user,
                companionKey,
                generateNameplateSerial())));
    }

    private ZeroonCompanionResponse notMet() {
        return new ZeroonCompanionResponse(false, null, null, null, null, null, null);
    }

    private ZeroonCompanionResponse toDto(UserZeroonCompanionEntity companion) {
        return new ZeroonCompanionResponse(
                true,
                companion.getCompanionKey(),
                companion.getDisplayName(),
                companion.getNameplateSerial(),
                companion.getMetAt(),
                companion.getCreatedAt(),
                companion.getUpdatedAt());
    }

    private String generateNameplateSerial() {
        String date = LocalDate.now(ZoneId.of("Asia/Shanghai")).format(NAMEPLATE_DATE);
        for (int attempt = 0; attempt < MAX_NAMEPLATE_ATTEMPTS; attempt++) {
            String candidate = "ZR-" + date + "-" + randomSuffix();
            if (!companionRepository.existsByNameplateSerial(candidate)) {
                return candidate;
            }
        }
        throw new IllegalStateException("Unable to generate ZEROON nameplate serial");
    }

    private String randomSuffix() {
        StringBuilder suffix = new StringBuilder(4);
        for (int index = 0; index < 4; index++) {
            suffix.append(NAMEPLATE_CHARS[secureRandom.nextInt(NAMEPLATE_CHARS.length)]);
        }
        return suffix.toString();
    }
}
