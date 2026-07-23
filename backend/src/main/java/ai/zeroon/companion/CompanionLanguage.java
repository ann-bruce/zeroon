package ai.zeroon.companion;

public enum CompanionLanguage {
    SIMPLIFIED_CHINESE(
            "zh-CN",
            """
                    Respond in Simplified Chinese unless the user explicitly requests another language in the current message.
                    Do not infer language from Profile, Memory, Records, conversation history, nationality, location, or identity.
                    """,
            "你正在把一些还没有完全成形的感受，慢慢放进可以回看的地方。"
                    + "这些记录里已经有了状态、感受和小进展的线索，"
                    + "ZEROON 会先安静保存它们，再陪你一点一点看清楚。",
            "我不能替代医疗、法律、财务或心理诊断建议。"
                    + "我可以陪你把感受记录下来，也建议你在需要时联系合适的专业人士。",
            "ZEROON 只能提供非诊断性的陪伴式反思，不能替代医疗、法律、财务或心理咨询。"),
    ENGLISH(
            "en",
            """
                    Respond in English unless the user explicitly requests another language in the current message.
                    Do not infer language from Profile, Memory, Records, conversation history, nationality, location, or identity.
                    """,
            "Some of what you are noticing may not be fully formed yet. "
                    + "ZEROON will keep this moment quietly, so you can return and see it more clearly over time.",
            "I can’t provide medical, legal, financial, or mental health diagnosis or professional advice. "
                    + "I can help you put what you are noticing into words, and it may be important to contact "
                    + "a qualified professional when needed.",
            "ZEROON offers non-diagnostic companion reflection. It cannot replace medical, legal, financial, "
                    + "or mental health professionals.");

    private final String languageTag;
    private final String providerInstruction;
    private final String fallbackReply;
    private final String boundaryReply;
    private final String safetyNotice;

    CompanionLanguage(
            String languageTag,
            String providerInstruction,
            String fallbackReply,
            String boundaryReply,
            String safetyNotice) {
        this.languageTag = languageTag;
        this.providerInstruction = providerInstruction;
        this.fallbackReply = fallbackReply;
        this.boundaryReply = boundaryReply;
        this.safetyNotice = safetyNotice;
    }

    public String languageTag() {
        return languageTag;
    }

    public String providerInstruction() {
        return providerInstruction;
    }

    public String fallbackReply() {
        return fallbackReply;
    }

    public String boundaryReply() {
        return boundaryReply;
    }

    public String safetyNotice() {
        return safetyNotice;
    }
}
