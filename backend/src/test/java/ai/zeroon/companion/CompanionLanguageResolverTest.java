package ai.zeroon.companion;

import static org.assertj.core.api.Assertions.assertThat;

import ai.zeroon.user.LanguagePreference;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

class CompanionLanguageResolverTest {

    private final UserRepository userRepository = Mockito.mock(UserRepository.class);
    private final CompanionLanguageResolver resolver = new CompanionLanguageResolver(userRepository);

    @Test
    void selectsFirstSupportedHeaderByQualityAndIgnoresUnsupportedRanges() {
        assertThat(resolver.resolveHeader("fr;q=1, en-US;q=0.8, zh-CN;q=0.4"))
                .contains(CompanionLanguage.ENGLISH);
        assertThat(resolver.resolveHeader("zh-Hant;q=1, zh-Hans;q=0.7, en;q=0.5"))
                .contains(CompanionLanguage.SIMPLIFIED_CHINESE);
        assertThat(resolver.resolveHeader("en;q=0, zh-CN;q=0.5"))
                .contains(CompanionLanguage.SIMPLIFIED_CHINESE);
    }

    @Test
    void ignoresMissingMalformedAndUnsupportedHeaders() {
        assertThat(resolver.resolveHeader(null)).isEmpty();
        assertThat(resolver.resolveHeader(" ")).isEmpty();
        assertThat(resolver.resolveHeader("not a valid language range;;;")).isEmpty();
        assertThat(resolver.resolveHeader("fr-FR, zh-Hant")).isEmpty();
    }

    @Test
    void fallsBackToConcreteAccountPreferenceWithoutInspectingContent() {
        UserEntity englishUser = new UserEntity("resolver-en", "13800138901");
        englishUser.changeLanguagePreference(LanguagePreference.EN);
        Mockito.when(userRepository.findById(1L)).thenReturn(Optional.of(englishUser));

        UserEntity followingSystem = new UserEntity("resolver-system", "13800138902");
        Mockito.when(userRepository.findById(2L)).thenReturn(Optional.of(followingSystem));

        assertThat(resolver.resolve(1L, "unsupported")).isEqualTo(CompanionLanguage.ENGLISH);
        assertThat(resolver.resolve(2L, null)).isEqualTo(CompanionLanguage.SIMPLIFIED_CHINESE);
    }
}
