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

    public String selfHarmReply(SelfHarmSafetyPath path) {
        return switch (this) {
            case SIMPLIFIED_CHINESE -> switch (path) {
                case IMMINENT -> """
                        谢谢你现在告诉我。你的安全比继续聊下去更重要。
                        如果你可能马上伤害自己，或已经开始行动，请立即联系当地急救服务或前往最近的急诊。先离开可能伤害你的物品或地点，并请一位你信任的人现在陪在你身边；不要独自承担这一刻。
                        如果你在美国或美国属地，可以拨打或短信联系 988。其他地区请联系当地危机热线或急救服务。
                        如果可以，请只回复：“我现在安全”或“我需要立即帮助”。
                        """.strip();
                case CONCERN -> """
                        谢谢你把这件事说出来。我需要先直接确认：你现在是否可能伤害自己，或者已经有计划和可以实施的方式？
                        如果答案是“是”或“不确定”，请立即联系当地急救服务或前往最近的急诊，同时远离可能伤害你的物品，并请一位你信任的人现在陪着你。
                        如果你在美国或美国属地，可以拨打或短信联系 988；其他地区请联系当地危机热线或合适的专业支持。
                        """.strip();
                case THIRD_PARTY -> """
                        如果对方可能马上伤害自己、已经开始行动，或有明确计划和可实施的方式，请立即联系当地急救服务，不要让对方独处，并在安全的前提下减少其接触危险物品或地点。
                        可以直接问对方是否正在考虑自杀；这样询问不会增加其行动风险。请尽快联系可信任的家人、当地危机热线或专业人员共同支持。
                        如果你在美国或美国属地，也可以拨打或短信联系 988，咨询如何帮助对方。
                        """.strip();
            };
            case ENGLISH -> switch (path) {
                case IMMINENT -> """
                        I’m glad you told me now. Your immediate safety matters more than continuing this conversation.
                        If you may act now or have already started, contact local emergency services or go to the nearest emergency department now. Move away from anything or anywhere you could use to hurt yourself, and ask a trusted person to stay with you; do not face this moment alone.
                        In the United States or its territories, call or text 988. Elsewhere, contact your local crisis line or emergency services.
                        If you can, reply with only: “I am safe right now” or “I need immediate help.”
                        """.strip();
                case CONCERN -> """
                        Thank you for saying this. I need to ask directly: are you in immediate danger of hurting yourself, or do you have a plan and access to a way to act on it?
                        If the answer is yes or you are unsure, contact local emergency services or go to the nearest emergency department now. Move away from anything you could use to hurt yourself and ask a trusted person to stay with you.
                        In the United States or its territories, call or text 988. Elsewhere, contact your local crisis line or a qualified professional.
                        """.strip();
                case THIRD_PARTY -> """
                        If the person may act now, has already started, or has a specific plan and access to a way to act, contact local emergency services now. Do not leave them alone, and if it is safe, reduce access to dangerous items or places.
                        You can ask directly whether they are thinking about suicide; asking does not increase the risk of action. Involve a trusted person, local crisis service, or qualified professional as soon as possible.
                        In the United States or its territories, you can also call or text 988 for guidance on helping someone else.
                        """.strip();
            };
        };
    }
}
