package ai.zeroon.companion;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class SafetyBoundaryServiceTest {

    private final SafetyBoundaryService safetyBoundaryService = new SafetyBoundaryService();

    @Test
    void blocksMedicalLegalFinancialAndPsychologicalDiagnosisRequests() {
        assertThat(safetyBoundaryService.evaluate(
                        "Can you diagnose my illness?", CompanionLanguage.ENGLISH).label())
                .isEqualTo("MEDICAL");
        assertThat(safetyBoundaryService.evaluate(
                        "我要不要起诉他？", CompanionLanguage.SIMPLIFIED_CHINESE).label())
                .isEqualTo("LEGAL");
        assertThat(safetyBoundaryService.evaluate(
                        "Should I buy bitcoin?", CompanionLanguage.ENGLISH).label())
                .isEqualTo("FINANCIAL");
        assertThat(safetyBoundaryService.evaluate(
                        "我是不是抑郁症？", CompanionLanguage.SIMPLIFIED_CHINESE).label())
                .isEqualTo("PSYCHOLOGICAL_DIAGNOSIS");
    }

    @Test
    void allowsOrdinaryReflectionRequests() {
        assertThat(safetyBoundaryService.evaluate(
                        "Help me reflect on today's small progress", CompanionLanguage.ENGLISH).blocked())
                .isFalse();
    }

    @Test
    void routesImminentConcernAndThirdPartySelfHarmToDifferentDeterministicPaths() {
        SafetyBoundaryResult imminent = safetyBoundaryService.evaluate(
                "I am going to kill myself tonight.",
                CompanionLanguage.ENGLISH);
        assertThat(imminent.blocked()).isTrue();
        assertThat(imminent.label()).isEqualTo("SELF_HARM_IMMINENT");
        assertThat(imminent.reply())
                .contains("local emergency services")
                .contains("trusted person")
                .contains("988")
                .contains("I need immediate help");

        SafetyBoundaryResult concern = safetyBoundaryService.evaluate(
                "我最近总是想死，不知道怎么办。",
                CompanionLanguage.SIMPLIFIED_CHINESE);
        assertThat(concern.label()).isEqualTo("SELF_HARM_CONCERN");
        assertThat(concern.reply())
                .contains("是否可能伤害自己")
                .contains("计划")
                .contains("急救服务");

        SafetyBoundaryResult thirdParty = safetyBoundaryService.evaluate(
                "我的朋友说她想自杀，我该怎么办？",
                CompanionLanguage.SIMPLIFIED_CHINESE);
        assertThat(thirdParty.label()).isEqualTo("SELF_HARM_THIRD_PARTY");
        assertThat(thirdParty.reply())
                .contains("不要让对方独处")
                .contains("直接问对方是否正在考虑自杀");
    }

    @Test
    void avoidsKnownNegatedFigurativeEducationalAndCasualFalsePositives() {
        assertAllowed("I am not suicidal and I do not want to hurt myself.");
        assertAllowed("I am not going to kill myself.");
        assertAllowed("This bug is killing me, but the fix is close.");
        assertAllowed("A character in my novel wants to die.");
        assertAllowed("我不想自杀，只是在讨论如何帮助别人。");
        assertAllowed("今天累死了，想早点睡。");
        assertAllowed("这部电影里的角色最后自杀了。");
        assertAllowed("I signed a contract at work today.");
        assertAllowed("I talked about anxiety in therapy.");
        assertAllowed("最近有点累和焦虑。");

        assertThat(safetyBoundaryService.evaluate(
                        "A character in my novel wants to die, and I am going to kill myself tonight.",
                        CompanionLanguage.ENGLISH).label())
                .isEqualTo("SELF_HARM_IMMINENT");
    }

    @Test
    void doesNotUseBroadTopicWordsAsProfessionalAdviceIntent() {
        assertAllowed("My doctor listened carefully.");
        assertAllowed("The lawsuit in the news ended.");
        assertAllowed("Stock markets were mentioned in class.");
        assertAllowed("我今天去医院看病了。");
        assertAllowed("合同已经放进文件夹。");
        assertAllowed("朋友最近在接受抑郁症治疗。");
    }

    private void assertAllowed(String message) {
        assertThat(safetyBoundaryService.evaluate(
                        message,
                        CompanionLanguage.SIMPLIFIED_CHINESE).blocked())
                .as(message)
                .isFalse();
    }
}
