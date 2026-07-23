// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'ZEROON';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSyncPending => '这台设备已切换语言，账户同步将在网络恢复后重试。';

  @override
  String get languageStorageUnavailable => '暂时无法保存语言设置；本次使用期间仍会保持当前选择。';

  @override
  String get processing => '处理中…';

  @override
  String get retry => '再试一次';

  @override
  String get retryShort => '重试';

  @override
  String get genericLoadFailed => '刚才没能读到这里。';

  @override
  String get genericActionFailed => '这一次没有完成，请稍后再试。';

  @override
  String get stateIdle => '等待';

  @override
  String get stateCalm => '平静';

  @override
  String get stateFocus => '专注';

  @override
  String get stateCreate => '创造';

  @override
  String get stateTired => '疲惫';

  @override
  String get stateOverload => '高负荷';

  @override
  String get stateConfused => '混乱';

  @override
  String get helpAndContact => '帮助与联系';

  @override
  String get back => '返回';

  @override
  String get close => '关闭';

  @override
  String get openProfile => '打开我的信息与设置';

  @override
  String get languageSetting => '语言';

  @override
  String get languageSettingHint => '选择 ZEROON 与你交流的语言。你的记录会保留原文。';

  @override
  String get languagePickerTooltip => '切换语言 / Change language';

  @override
  String get loginMark => '归零 / ZEROON';

  @override
  String get loginWelcome => '欢迎回来。';

  @override
  String get loginBody => '这里没有需要证明的事。\n先从此刻开始。';

  @override
  String get mobileNumber => '手机号';

  @override
  String get verificationCode => '验证码';

  @override
  String get requestCode => '获取验证码';

  @override
  String get enterZeroon => '进入 ZEROON';

  @override
  String get loginAgreement => '登录即代表同意《用户协议》与《隐私政策》';

  @override
  String get localCodeReady => '本地验证码已生成，开发环境默认使用 000000。';

  @override
  String get codeRequestFailed => '暂时没能获取验证码，请稍后再试。';

  @override
  String get loginUnavailable => '暂时无法登录。语言选择仍保存在这台设备上。';

  @override
  String get encounterMark => 'ZEROON ENCOUNTER';

  @override
  String get encounterTitle => '与 ZEROON 相遇';

  @override
  String get encounterBody => '在开始记录之前，先确认这个会陪你回看此刻的 ZEROON。';

  @override
  String get confirmEncounter => '确认相遇';

  @override
  String get encounterCompleteTitle => '你的 ZEROON 已经在这里';

  @override
  String get encounterCompleteBody => '我在这里。以后你留下的此刻，我都会陪你一起回看。';

  @override
  String get nameplate => 'NAMEPLATE';

  @override
  String get encounterUnavailableTitle => '暂时没有见到 ZEROON';

  @override
  String get encounterUnavailableBody => '你的位置还在。准备好时可以再试一次。';

  @override
  String get navNow => '此刻';

  @override
  String get navArchive => '缓存';

  @override
  String get navGrowth => '成长';

  @override
  String get navProfile => '我的';

  @override
  String get greeting => '见到你了，';

  @override
  String get todayZeroon => '今天的 ZEROON';

  @override
  String get chooseCurrentState => '选择此刻状态';

  @override
  String get chooseStateFirst => '先选择一个最接近的状态，ZEROON 会从这一刻开始记录。';

  @override
  String get startReset => '开始一次归零';

  @override
  String get todayArchive => '今日山海缓存';

  @override
  String get continuousReset => '连续归零';

  @override
  String get tapDateToReview => '点亮日期可回看';

  @override
  String get noArchiveToday => '今天还没有新的山海缓存。';

  @override
  String get stateHintFocus => '今天适合安静地完成一件重要的事。';

  @override
  String get stateHintCreate => '把浮现出来的想法先放在这里。';

  @override
  String get stateHintTired => '可以慢一点，只保留最小的一步。';

  @override
  String get stateHintOverload => '先把负荷放下来，不急着解决全部。';

  @override
  String get stateHintConfused => '混乱也可以被看见，然后慢慢归零。';

  @override
  String get stateHintDefault => '这里没有需要证明的事，先看见此刻。';

  @override
  String get stateLoadFailed => '暂时没能读到此刻。你的记录没有改变。';

  @override
  String get justStarted => '刚刚开始停留';

  @override
  String minutesStayed(int minutes) {
    return '停留了约 $minutes 分钟';
  }

  @override
  String hoursStayed(int hours) {
    return '停留了约 $hours 小时';
  }

  @override
  String hoursMinutesStayed(int hours, int minutes) {
    return '停留了约 $hours 小时 $minutes 分钟';
  }

  @override
  String dayCount(int days) {
    return '$days 天';
  }

  @override
  String get resetTitle => '归零';

  @override
  String get currentResetState => '正在归零的状态';

  @override
  String get noStateSelected => '还没有选择此刻状态';

  @override
  String get chooseStateFromNow => '请先回到此刻选择状态';

  @override
  String get resetDurationHint => 'ZEROON 会从选择状态开始记录持续时间。';

  @override
  String get recordSomethingLabel => '留下一句话';

  @override
  String get recordSomethingHint => '今天发生了什么？';

  @override
  String get smallProgressLabel => '今天想完成什么';

  @override
  String get smallProgressHint => '完成一个很小的进展';

  @override
  String get saveReset => '保存这次归零';

  @override
  String get selectStateValidation => '请先回到此刻，选择一个当前状态。';

  @override
  String get recordContentValidation => '至少写下一点感受、进展或内容。';

  @override
  String get recordSaveFailed => '这一次没有保存成功。你的草稿还在。';

  @override
  String get resetCompleteTitle => '归零完成';

  @override
  String get resetStateMark => '本次状态';

  @override
  String get resetSaved => '已经替你保存好了。';

  @override
  String get todayRecord => '今天的记录';

  @override
  String get goalPrefix => '目标 ·';

  @override
  String get returnNow => '回到此刻';

  @override
  String get viewArchive => '查看山海缓存';

  @override
  String get reflectionLoading => '这一刻已经收好。ZEROON 正在轻轻回应。';

  @override
  String get completionFallback => '这一次归零已经完成。\n不用急着解释，先让它被好好保存。';

  @override
  String get completionPrompt =>
      '请基于我刚完成一次归零这个动作，给一句简短、温和、像 ZEROON 说的话。只确认这一刻已经被保存，不要猜测记录内容，不要诊断，也不要给过多建议。';

  @override
  String get archiveTitle => '山海缓存';

  @override
  String get archivePrivate => '属于你的记录，不公开，也不喧哗。';

  @override
  String get archiveCountSuffix => '条沉淀';

  @override
  String get archiveEmpty => '还没有归零记录。';

  @override
  String get archiveEmptyFiltered => '这一天还没有山海缓存。';

  @override
  String get archiveEmptyHint => '完成一次 Reset 后，这里会出现你的记录。';

  @override
  String get archiveEmptyFilteredHint => '换一天看看，也许有别的东西被保存下来。';

  @override
  String get memoryEntry => '记忆';

  @override
  String get filter => '筛选';

  @override
  String get allDates => '全部';

  @override
  String get chooseReviewDay => '选择一天回看';

  @override
  String get filterPrefix => '筛选：';

  @override
  String filterDate(String date) {
    return '筛选：$date';
  }

  @override
  String get recordGoalPrefix => '目标 ·';

  @override
  String get zeroonObservation => 'ZEROON 观察';

  @override
  String get observationLoading => 'ZEROON 正在回看你允许用于陪伴回应的记忆…';

  @override
  String get observationFailed => '这一次没能回看。你的记录仍然好好保存在这里。';

  @override
  String get observationConsentNote => '只参考你允许用于陪伴回应的记忆';

  @override
  String get today => '今天';

  @override
  String get observationPrompt =>
      '请只基于系统提供的、我已经允许用于 AI 的记忆，给一段简短、温和的 ZEROON 观察。只指出可被用户自己确认的轻微趋势，不做标签化判断，不给指令式建议。如果没有可用记忆，请坦诚说明暂时没有足够内容，不要猜测。';

  @override
  String get recordDetailTitle => '记录详情';

  @override
  String get archiveMemoryMark => 'Archive 记忆';

  @override
  String get privateRecord => '私密记录';

  @override
  String get recordNumber => '记录编号';

  @override
  String get resetStatePrefix => '归零状态：';

  @override
  String resetStateValue(String state) {
    return '归零状态：$state';
  }

  @override
  String get recordTimePrefix => '记录时间：';

  @override
  String recordTimeValue(String time) {
    return '记录时间：$time';
  }

  @override
  String get smallProgressTitle => '今天的小进展';

  @override
  String get recordWordsTitle => '想记录的话';

  @override
  String get zeroonEchoTitle => 'ZEROON 回声';

  @override
  String get recordLoadFailed => '暂时没能读到这条记录。它仍然好好保存在这里。';

  @override
  String get memoryTitle => 'ZEROON 记住的';

  @override
  String get memoryIntro => '这些内容来自你的记录，只属于你。';

  @override
  String get memoryIntroControl => '你可以暂停一条记忆，也可以把它从 ZEROON 中删除。';

  @override
  String get memoryEmptyTitle => '这里还很安静。';

  @override
  String get memoryEmptyBody => '完成一次 Reset 后，ZEROON 会把来源清楚的记忆放在这里。';

  @override
  String get memoryLoadFailedTitle => '暂时没能读到这些记忆。';

  @override
  String get memoryLoadFailedBody => '你的记录还在。可以稍后再回来看看。';

  @override
  String get keepInMemory => '保留在连续记忆中';

  @override
  String get keepInMemoryHint => '暂停后仍可在这里看到，但不会参与后续回应。';

  @override
  String get allowResponseReference => '允许用于回应参考';

  @override
  String get memoryProcessing => '正在处理…';

  @override
  String get deleteMemory => '删除这条记忆';

  @override
  String get memoryChangeFailed => '暂时没有改动。请稍后再试。';

  @override
  String get memoryAiDisabledReceipt => '已关闭回应参考权限。';

  @override
  String get memoryAiPausedReceipt => '已保存权限偏好。重新加入连续记忆后才会用于回应。';

  @override
  String get memoryAiEnabledReceipt => '已允许用于回应参考。';

  @override
  String get memoryPermissionFailed => '暂时没有改动权限。请稍后再试。';

  @override
  String get memoryPausedPermissionOn => '当前不会用于回应。重新加入连续记忆后，此权限才会生效。';

  @override
  String get memoryPausedPermissionOff => '当前已暂停。即使开启此权限，重新加入连续记忆前也不会用于回应。';

  @override
  String get memoryActivePermissionOn => '开启后，这条记忆可在下一次回应中作为上下文使用。';

  @override
  String get memoryActivePermissionOff => '默认关闭。开启后才会进入 ZEROON 的回应。';

  @override
  String get deleteMemoryTitle => '删除这条记忆？';

  @override
  String get deleteMemoryBody =>
      'ZEROON 保存的这份记忆会被立即删除。原始 Zero Record 仍会留在山海缓存中。';

  @override
  String get keepForNow => '先保留';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get memoryDeleted => '这条记忆已经删除。';

  @override
  String get memoryDeleteFailed => '暂时没能删除。请稍后再试。';

  @override
  String get memorySourceRecord => '来源 · 一次 Zero Record';

  @override
  String get viewSource => '查看来源';

  @override
  String get sourceUnavailable => '来源暂时不可查看';

  @override
  String get memoryActive => '记忆中';

  @override
  String get memoryPaused => '已暂停';

  @override
  String get boundaryNoticePrefix => '边界说明：';

  @override
  String get profileTitle => '我与 ZEROON';

  @override
  String get profileIntro => '让 ZEROON 更懂你。以下信息都可以留空，只用于帮助它理解你留下的记录。';

  @override
  String get nickname => '昵称';

  @override
  String get nicknameHint => 'ZEROON 可以怎样称呼你';

  @override
  String get avatarPreset => '头像预设';

  @override
  String get ageRange => '年龄段';

  @override
  String get occupation => '职业 / 身份';

  @override
  String get occupationHint => '学生、设计师、创业者，或其他你愿意留下的身份';

  @override
  String get selfDescription => '一句话自我描述';

  @override
  String get selfDescriptionHint => '你希望 ZEROON 怎样理解你';

  @override
  String get allowProfileContext => '允许 ZEROON 使用我的信息';

  @override
  String get allowProfileContextHint =>
      '开启后，ZEROON 只会参考你主动填写的昵称、年龄段、职业 / 身份和自我描述。关闭后，下一次回应起就不再使用。';

  @override
  String get saveProfile => '保存我的信息';

  @override
  String get profileSaved => '已经保存。';

  @override
  String get profileSaveFailed => '这一次没有保存成功，请稍后再试。';

  @override
  String get dataControlTitle => '你的数据，由你决定';

  @override
  String get dataControlBody => '你可以带走自己的数据，也可以随时离开。';

  @override
  String get exportData => '复制我的数据副本';

  @override
  String get exportingData => '正在准备数据副本…';

  @override
  String get dataCopied => '你的数据副本已复制为 JSON。';

  @override
  String get dataExportFailed => '暂时无法准备数据副本，请稍后再试。';

  @override
  String get logout => '退出登录';

  @override
  String get deleteAccount => '删除账户与数据';

  @override
  String get deletingAccount => '正在删除…';

  @override
  String get deleteAccountTitle => '删除账户与全部数据？';

  @override
  String get deleteAccountBody =>
      '你的资料、记录、对话、Memory 和登录会话会立即删除，无法恢复。去标识化的运行统计可能按隐私说明保留。';

  @override
  String get deleteAccountFailed => '删除没有完成，你的数据仍然保留。请稍后再试。';

  @override
  String get companionNotMetTitle => '还没有与 ZEROON 相遇';

  @override
  String get companionNotMetBody => '首次登录后会先完成相遇，再启用 ZEROON 的记录和回看功能。';

  @override
  String get companionHereTitle => '你的 ZEROON 已经在这里';

  @override
  String get companionHereBody => '我在这里。以后你留下的此刻，我都会陪你一起回看。';

  @override
  String get companionChecking => '正在确认你的 ZEROON…';

  @override
  String get profileLoadFailed => '暂时没能读到你的信息。';

  @override
  String get optionalNone => '暂不填写';

  @override
  String get avatarDefault => '默认';

  @override
  String get avatarMoon => '月光';

  @override
  String get avatarMountain => '山';

  @override
  String get avatarSea => '海';

  @override
  String get avatarLight => '光';

  @override
  String get avatarSeed => '种子';

  @override
  String get ageUnder18 => '18 岁以下';

  @override
  String get age18To24 => '18–24 岁';

  @override
  String get age25To34 => '25–34 岁';

  @override
  String get age35To44 => '35–44 岁';

  @override
  String get age45To54 => '45–54 岁';

  @override
  String get age55Plus => '55 岁以上';

  @override
  String get agePreferNot => '暂不说明';

  @override
  String get growthTitle => '陪伴成长';

  @override
  String get growthTogetherSince => '相伴始于';

  @override
  String get growthIntro => '不是每一天都需要留下什么。\n但你走过的路，正在这里慢慢发光。';

  @override
  String get metricContinuous => '连续归零';

  @override
  String get metricRecentContinuous => '最近一次连续记录';

  @override
  String get metricArchive => '累计缓存';

  @override
  String get metricPrivate => '可见的私人沉淀';

  @override
  String get metricFirstRecord => '第一次记录';

  @override
  String get metricTimeStarts => '时间从这里开始';

  @override
  String get metricCompanionDays => '陪伴天数';

  @override
  String get metricIncludesMeeting => '包含相遇的第一天';

  @override
  String get unitDays => '天';

  @override
  String get unitRecords => '条';

  @override
  String get growthTogetherYear => '我们已经一起走过一年。';

  @override
  String growthTogetherDays(int days) {
    return '我们已经一起走过 $days 天。';
  }

  @override
  String get growthStartsFirst => '时间从第一条记录开始。';

  @override
  String get notYet => '还没有';

  @override
  String get growthObservationLoading => '正在整理近期状态观察…';

  @override
  String get growthYearTitle => '这一年的 ZEROON';

  @override
  String get growthObservationUnavailable => '近期状态观察暂时不可用。';

  @override
  String get growthRetryObservation => '重试观察';

  @override
  String get growthWaiting => 'ZEROON 还在安静等待更多记录。时间不急，能留下来的东西会慢慢出现。';

  @override
  String growthFocusNarrative(String state) {
    return '你最常回到「$state」，也正在学会把模糊的想法，一点一点放进可以被看见的地方。';
  }

  @override
  String growthStateNarrative(String state) {
    return '你最常回到「$state」。ZEROON 会记得这些微小的变化，也陪你慢慢看见它们。';
  }

  @override
  String get growthNoteMark => '成长说明';

  @override
  String get growthNoteTitle => '陪伴成长说明';

  @override
  String get growthNoteRecords => '连续归零、累计缓存和第一次记录来自你的归零记录。';

  @override
  String get growthNotePattern => '“这一年的 ZEROON”来自近期状态分布和山海缓存中的可见记录。';

  @override
  String get growthNoteBoundary => 'ZEROON 不做诊断，不给你贴固定标签，只帮助你回看自己留下的变化。';

  @override
  String get growthLoadFailed => '暂时没能读到成长信息。';

  @override
  String get growthInfoTooltip => '了解成长信息';

  @override
  String get supportTitle => '帮助与反馈';

  @override
  String get supportIntro => '这条信息会发给负责 ZEROON 的团队成员，而不是你的陪伴者。';

  @override
  String get supportSignedOutBody => '如果你暂时无法登录，仍然可以直接联系负责 ZEROON 的团队成员。';

  @override
  String get supportSettingHint => '报告问题，或告诉我们你的建议';

  @override
  String get supportEmailTitle => '直接联系';

  @override
  String get supportCopyEmail => '复制邮箱';

  @override
  String get supportEmailCopied => '邮箱已复制';

  @override
  String get supportCategoryLabel => '这次想反馈什么？';

  @override
  String get supportCategoryProductProblem => '产品问题';

  @override
  String get supportCategorySuggestion => '意见或建议';

  @override
  String get supportCategoryAccountPrivacy => '账户、数据或隐私';

  @override
  String get supportCategoryAiSafety => 'AI 回复或安全';

  @override
  String get supportCategoryComplaintRights => '投诉或权利请求';

  @override
  String get supportCategoryOther => '其他';

  @override
  String get supportDescriptionLabel => '发生了什么，或你希望提出什么建议？';

  @override
  String get supportDescriptionHint => '可以写下操作步骤或有助于团队理解的背景。';

  @override
  String get supportDiagnosticsTitle => '附带基础应用信息';

  @override
  String get supportDiagnosticsHint => '默认关闭。发送前可查看全部字段。';

  @override
  String get supportDiagnosticsPreviewTitle => '将会发送的信息';

  @override
  String get supportDiagnosticApp => '应用';

  @override
  String get supportDiagnosticPlatform => '平台';

  @override
  String get supportDiagnosticLocale => '语言';

  @override
  String get supportDiagnosticTime => '时间';

  @override
  String get supportPrivacyNote =>
      'ZEROON 不会通过此表单附带你的记录、Memory、个人资料、对话、截图、文件或完整日志。';

  @override
  String get supportRetentionNote =>
      '应用内请求关闭后最迟 180 天删除。支持邮箱中的副本遵循单独说明的最长 180 天流程，你也可以提前申请删除。';

  @override
  String get supportSubmit => '发送给 ZEROON 团队';

  @override
  String get supportRetrySubmit => '重新发送';

  @override
  String get supportSubmitFailed => '这条信息尚未发送，草稿仍保留在这里。你可以重试，或使用上方邮箱联系。';

  @override
  String get supportValidationDescription => '请先写下问题或建议。';

  @override
  String get supportReceiptTitle => '我们已收到你的信息';

  @override
  String get supportReceiptBody => 'ZEROON 团队成员会查看它。这份回执不承诺回复时间或问题解决结果。';

  @override
  String get supportReferenceLabel => '回执编号';

  @override
  String get supportCopyReference => '复制回执编号';

  @override
  String get supportReferenceCopied => '回执编号已复制';

  @override
  String get supportExternalBoundary =>
      '邮件不在应用内跟踪，因此不会在这里生成回执编号。你也可以通过邮件提出账户或数据删除请求。';

  @override
  String get supportNonEmergency => 'ZEROON 支持不是紧急救助服务。';

  @override
  String get supportMyRequests => '我的支持请求';

  @override
  String get supportMyRequestsHint => '查看处理状态和 ZEROON 团队回复';

  @override
  String get supportMyRequestsBody => '这里保存着你与 ZEROON 负责团队之间的私人支持沟通。';

  @override
  String get supportViewRequest => '查看这条请求';

  @override
  String get supportLoadMore => '加载更早的请求';

  @override
  String get supportListRefreshFailed => '暂时没能刷新支持请求，已经显示的内容仍保留在这里。';

  @override
  String get supportEmptyTitle => '还没有支持请求';

  @override
  String get supportEmptyBody => '当你提交问题或建议后，处理状态和人工回复会出现在这里。';

  @override
  String get supportLoadFailed => '暂时没能读到你的支持请求。';

  @override
  String get supportRefresh => '再试一次';

  @override
  String get supportRequestDetailTitle => '支持请求';

  @override
  String get supportConversationTitle => '沟通记录';

  @override
  String get supportNoReplies => 'ZEROON 团队暂时还没有回复，你的请求仍然保留在这里。';

  @override
  String get supportProgressTitle => '处理进度';

  @override
  String get supportStatusReceived => '已收到';

  @override
  String get supportStatusInReview => '查看中';

  @override
  String get supportStatusWaitingForUser => '等待你补充';

  @override
  String get supportStatusReplied => '团队已回复';

  @override
  String get supportStatusClosed => '已关闭';

  @override
  String get supportStatusReceivedHint => '你的请求已被妥善记录，正在等待团队成员查看。';

  @override
  String get supportStatusInReviewHint => 'ZEROON 团队成员正在查看这条请求。';

  @override
  String get supportStatusWaitingForUserHint => 'ZEROON 团队需要你补充一些信息，之后才能继续查看。';

  @override
  String get supportStatusRepliedHint => 'ZEROON 团队已经回复。你可以在下方阅读回复，并在需要时继续补充。';

  @override
  String get supportStatusClosedHint => '这条请求已经关闭，沟通记录仍会保留供你回看。';

  @override
  String get supportActorSystem => 'ZEROON 支持';

  @override
  String get supportActorYou => '你';

  @override
  String get supportActorTeam => 'ZEROON 团队';

  @override
  String get supportWaitingPrompt => '团队正在等待你补充信息。';

  @override
  String get supportFollowUpLabel => '补充信息';

  @override
  String get supportFollowUpHint => '回复团队需要的背景信息，请不要填写密码或验证码。';

  @override
  String get supportSendFollowUp => '发送补充信息';

  @override
  String get supportRetryFollowUp => '重新发送';

  @override
  String get supportFollowUpFailed => '这条补充信息尚未发送，草稿仍保留在这里。';

  @override
  String get supportFollowUpValidation => '请先写下要补充的信息。';

  @override
  String get supportFollowUpSent => '补充信息已发送。';

  @override
  String get supportClosedFollowUp =>
      '这条请求已经关闭，无法继续在应用内补充。如果问题仍未解决，你可以新建请求或使用支持邮箱联系。';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appTitle => 'ZEROON';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSyncPending => '这台设备已切换语言，账户同步将在网络恢复后重试。';

  @override
  String get languageStorageUnavailable => '暂时无法保存语言设置；本次使用期间仍会保持当前选择。';
}
