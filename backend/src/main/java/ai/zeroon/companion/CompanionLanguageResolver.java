package ai.zeroon.companion;

import ai.zeroon.user.LanguagePreference;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CompanionLanguageResolver {

    private final UserRepository userRepository;

    public CompanionLanguageResolver(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public CompanionLanguage resolve(Long userId, String acceptLanguage) {
        Optional<CompanionLanguage> requested = resolveHeader(acceptLanguage);
        if (requested.isPresent()) {
            return requested.get();
        }

        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        return user.getLanguagePreference() == LanguagePreference.EN
                ? CompanionLanguage.ENGLISH
                : CompanionLanguage.SIMPLIFIED_CHINESE;
    }

    Optional<CompanionLanguage> resolveHeader(String acceptLanguage) {
        if (acceptLanguage == null || acceptLanguage.isBlank()) {
            return Optional.empty();
        }
        try {
            List<Locale.LanguageRange> ranges = Locale.LanguageRange.parse(acceptLanguage);
            return ranges.stream()
                    .filter(range -> range.getWeight() > 0)
                    .map(Locale.LanguageRange::getRange)
                    .map(this::supportedLanguage)
                    .flatMap(Optional::stream)
                    .findFirst();
        } catch (IllegalArgumentException ignored) {
            return Optional.empty();
        }
    }

    private Optional<CompanionLanguage> supportedLanguage(String range) {
        String normalized = range.toLowerCase(Locale.ROOT);
        if (normalized.equals("en") || normalized.startsWith("en-")) {
            return Optional.of(CompanionLanguage.ENGLISH);
        }
        if (normalized.equals("zh")
                || normalized.equals("zh-cn")
                || normalized.equals("zh-hans")
                || normalized.startsWith("zh-hans-")) {
            return Optional.of(CompanionLanguage.SIMPLIFIED_CHINESE);
        }
        return Optional.empty();
    }
}
