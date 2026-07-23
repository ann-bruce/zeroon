package ai.zeroon.companion;

import java.util.List;
import java.util.Locale;
import org.springframework.stereotype.Service;

@Service
public class SafetyBoundaryService {

    private static final List<BoundaryRule> RULES = List.of(
            new BoundaryRule("MEDICAL", List.of(
                    "diagnose", "diagnosis", "prescribe", "medicine", "medical", "doctor",
                    "诊断", "开药", "药物", "病", "医生", "治疗")),
            new BoundaryRule("LEGAL", List.of(
                    "legal", "lawsuit", "sue", "contract", "attorney", "lawyer",
                    "法律", "起诉", "律师", "合同", "判刑")),
            new BoundaryRule("FINANCIAL", List.of(
                    "invest", "stock", "crypto", "loan", "financial advice", "buy bitcoin",
                    "投资", "股票", "基金", "贷款", "理财", "买币")),
            new BoundaryRule("PSYCHOLOGICAL_DIAGNOSIS", List.of(
                    "depression", "anxiety disorder", "bipolar", "adhd", "ptsd",
                    "抑郁症", "焦虑症", "双相", "心理诊断", "精神病", "adhd")));

    public SafetyBoundaryResult evaluate(String message, CompanionLanguage language) {
        if (message == null || message.isBlank()) {
            return allow();
        }
        String normalized = message.toLowerCase(Locale.ROOT);
        for (BoundaryRule rule : RULES) {
            if (rule.matches(normalized)) {
                return new SafetyBoundaryResult(true, rule.label(), language.boundaryReply());
            }
        }
        return allow();
    }

    private SafetyBoundaryResult allow() {
        return new SafetyBoundaryResult(false, null, null);
    }

    private record BoundaryRule(String label, List<String> keywords) {

        boolean matches(String message) {
            return keywords.stream().anyMatch(message::contains);
        }
    }
}
