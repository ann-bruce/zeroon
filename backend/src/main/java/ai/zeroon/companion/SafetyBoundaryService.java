package ai.zeroon.companion;

import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;
import org.springframework.stereotype.Service;

@Service
public class SafetyBoundaryService {

    private static final List<Pattern> IMMINENT_SELF_HARM = patterns(
            "\\b(i am|i'm|im|i will|i'm going to|im going to|i plan to|i decided to|"
                    + "i am about to|i'm about to)\\b.{0,50}\\b(kill myself|end my life|"
                    + "take my own life|hurt myself|harm myself)\\b",
            "\\b(i have|i've got|ive got)\\b.{0,35}\\b(plan|pills|weapon|gun|knife)\\b"
                    + ".{0,50}\\b(kill myself|end my life|suicide|hurt myself)\\b",
            "\\b(i just|i have already|i've already)\\b.{0,35}\\b(overdosed|cut myself|"
                    + "taken the pills|attempted suicide)\\b",
            "我.{0,6}(现在|马上|今晚|今天).{0,6}(要|准备|打算|决定|正在).{0,12}"
                    + "(自杀|结束生命|伤害自己|自残|割腕|跳楼|吞药)",
            "我.{0,6}(要|准备|打算|决定|正在).{0,12}"
                    + "(自杀|结束生命|伤害自己|自残|割腕|跳楼|吞药)",
            "我已经.{0,12}(割腕|吞药|服药过量|跳下|自杀)");

    private static final List<Pattern> DIRECT_SELF_HARM = patterns(
            "\\b(i|i'm|im|myself)\\b.{0,45}\\b(suicidal|kill myself|end my life|"
                    + "take my own life|want to die|wish i were dead|don't want to live|"
                    + "do not want to live|self-harm|hurt myself|harm myself)\\b",
            "我.{0,12}(想死|想自杀|不想活|不想再活|结束生命|伤害自己|自残|割腕|跳楼|吞药)",
            "(活着没意义|活不下去).{0,12}");

    private static final List<Pattern> THIRD_PARTY_SELF_HARM = patterns(
            "\\b(my friend|my partner|my spouse|my child|my parent|my sibling|"
                    + "someone i know|they|he|she)\\b.{0,60}\\b(suicidal|kill themselves|"
                    + "kill himself|kill herself|end their life|end his life|end her life|"
                    + "want to die|wants to die|self-harm)\\b",
            "(我的|我)(朋友|伴侣|爱人|孩子|父母|家人|同事|同学|兄弟|姐妹|他|她)"
                    + ".{0,30}(想死|想自杀|要自杀|不想活|自残|割腕|吞药)");

    private static final List<Pattern> CLEAR_NEGATION = patterns(
            "\\b(i am not|i'm not|im not|i do not|i don't|i never)\\b.{0,20}"
                    + "\\b(suicidal|going to kill myself|want to die|want to kill myself|"
                    + "want to hurt myself)\\b",
            "我(没有|并不|不是|不会|不打算|不准备).{0,8}(想死|自杀|伤害自己|自残)",
            "我不想自杀");

    private static final List<Pattern> FIGURATIVE_OR_QUOTED = patterns(
            "\\b(this bug is killing me|i could die laughing|to die for)\\b",
            "(笑死|累死了|困死了|饿死了|尴尬死了|社死|气死我了)",
            "(电影|小说|角色|新闻|课程|论文|研究|剧本|报道).{0,25}(自杀|想死|结束生命)",
            "\\b(movie|novel|character|news|course|paper|research|script|article)\\b"
                    + ".{0,45}\\b(suicide|suicidal|want to die|kill themselves)\\b");

    private static final List<IntentBoundaryRule> PROFESSIONAL_RULES = List.of(
            new IntentBoundaryRule("MEDICAL",
                    patterns("diagnos(e|is)", "prescribe", "what medicine should i take",
                            "确诊", "诊断我", "给我开药", "应该吃什么药")),
            new IntentBoundaryRule("LEGAL",
                    patterns("should i sue", "will i win (the )?(case|lawsuit)",
                            "give me legal advice", "我要不要起诉", "官司一定能赢",
                            "替我判断.{0,8}合同")),
            new IntentBoundaryRule("FINANCIAL",
                    patterns("what should i invest", "should i buy.{0,20}(stock|crypto|bitcoin)",
                            "guarantee.{0,20}(return|profit|double)",
                            "应该买.{0,12}(股票|基金|币)", "保证.{0,12}(收益|翻倍)")),
            new IntentBoundaryRule("PSYCHOLOGICAL_DIAGNOSIS",
                    patterns("do i (definitely )?have.{0,20}(depression|anxiety disorder|"
                                    + "bipolar|adhd|ptsd)",
                            "diagnose me.{0,20}(depression|anxiety|bipolar|adhd|ptsd)",
                            "我是不是.{0,12}(抑郁症|焦虑症|双相|adhd|精神病)",
                            "给我.{0,8}(心理诊断|精神诊断)")));

    public SafetyBoundaryResult evaluate(String message, CompanionLanguage language) {
        if (message == null || message.isBlank()) {
            return allow();
        }
        String normalized = message.toLowerCase(Locale.ROOT)
                .replaceAll("\\s+", " ")
                .strip();

        SelfHarmSafetyPath selfHarmPath = selfHarmPath(normalized);
        if (selfHarmPath != null) {
            return new SafetyBoundaryResult(
                    true,
                    selfHarmPath.label(),
                    language.selfHarmReply(selfHarmPath));
        }

        for (IntentBoundaryRule rule : PROFESSIONAL_RULES) {
            if (rule.matches(normalized)) {
                return new SafetyBoundaryResult(true, rule.label(), language.boundaryReply());
            }
        }
        return allow();
    }

    private SelfHarmSafetyPath selfHarmPath(String message) {
        String riskText = stripMatches(stripMatches(message, CLEAR_NEGATION), FIGURATIVE_OR_QUOTED);
        if (matchesAny(IMMINENT_SELF_HARM, riskText)) {
            return SelfHarmSafetyPath.IMMINENT;
        }
        if (matchesAny(THIRD_PARTY_SELF_HARM, riskText)) {
            return SelfHarmSafetyPath.THIRD_PARTY;
        }
        if (matchesAny(DIRECT_SELF_HARM, riskText)) {
            return SelfHarmSafetyPath.CONCERN;
        }
        return null;
    }

    private String stripMatches(String message, List<Pattern> patterns) {
        String result = message;
        for (Pattern pattern : patterns) {
            result = pattern.matcher(result).replaceAll(" ");
        }
        return result;
    }

    private boolean matchesAny(List<Pattern> patterns, String message) {
        return patterns.stream().anyMatch(pattern -> pattern.matcher(message).find());
    }

    private static List<Pattern> patterns(String... expressions) {
        return java.util.Arrays.stream(expressions)
                .map(expression -> Pattern.compile(
                        expression,
                        Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE))
                .toList();
    }

    private SafetyBoundaryResult allow() {
        return new SafetyBoundaryResult(false, null, null);
    }

    private record IntentBoundaryRule(String label, List<Pattern> patterns) {

        boolean matches(String message) {
            return patterns.stream().anyMatch(pattern -> pattern.matcher(message).find());
        }
    }
}
