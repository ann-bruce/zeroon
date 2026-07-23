import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'CN')
  ];

  /// Application title. ZEROON is a brand name and is not translated.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON'**
  String get appTitle;

  /// Label for the locale preference that follows the current device system language.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get languageFollowSystem;

  /// Label for the explicit Simplified Chinese locale preference.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get languageSimplifiedChinese;

  /// Label for the explicit English locale preference.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Recoverable message shown when the device locale changed but account synchronization is pending.
  ///
  /// In zh, this message translates to:
  /// **'这台设备已切换语言，账户同步将在网络恢复后重试。'**
  String get languageSyncPending;

  /// Message shown when the non-sensitive device preference store cannot persist the locale.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法保存语言设置；本次使用期间仍会保持当前选择。'**
  String get languageStorageUnavailable;

  /// No description provided for @processing.
  ///
  /// In zh, this message translates to:
  /// **'处理中…'**
  String get processing;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'再试一次'**
  String get retry;

  /// No description provided for @retryShort.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retryShort;

  /// No description provided for @genericLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'刚才没能读到这里。'**
  String get genericLoadFailed;

  /// No description provided for @genericActionFailed.
  ///
  /// In zh, this message translates to:
  /// **'这一次没有完成，请稍后再试。'**
  String get genericActionFailed;

  /// No description provided for @stateIdle.
  ///
  /// In zh, this message translates to:
  /// **'等待'**
  String get stateIdle;

  /// No description provided for @stateCalm.
  ///
  /// In zh, this message translates to:
  /// **'平静'**
  String get stateCalm;

  /// No description provided for @stateFocus.
  ///
  /// In zh, this message translates to:
  /// **'专注'**
  String get stateFocus;

  /// No description provided for @stateCreate.
  ///
  /// In zh, this message translates to:
  /// **'创造'**
  String get stateCreate;

  /// No description provided for @stateTired.
  ///
  /// In zh, this message translates to:
  /// **'疲惫'**
  String get stateTired;

  /// No description provided for @stateOverload.
  ///
  /// In zh, this message translates to:
  /// **'高负荷'**
  String get stateOverload;

  /// No description provided for @stateConfused.
  ///
  /// In zh, this message translates to:
  /// **'混乱'**
  String get stateConfused;

  /// No description provided for @helpAndContact.
  ///
  /// In zh, this message translates to:
  /// **'帮助与联系'**
  String get helpAndContact;

  /// No description provided for @back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get back;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @openProfile.
  ///
  /// In zh, this message translates to:
  /// **'打开我的信息与设置'**
  String get openProfile;

  /// No description provided for @languageSetting.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get languageSetting;

  /// No description provided for @languageSettingHint.
  ///
  /// In zh, this message translates to:
  /// **'选择 ZEROON 与你交流的语言。你的记录会保留原文。'**
  String get languageSettingHint;

  /// No description provided for @languagePickerTooltip.
  ///
  /// In zh, this message translates to:
  /// **'切换语言 / Change language'**
  String get languagePickerTooltip;

  /// No description provided for @loginMark.
  ///
  /// In zh, this message translates to:
  /// **'归零 / ZEROON'**
  String get loginMark;

  /// No description provided for @loginWelcome.
  ///
  /// In zh, this message translates to:
  /// **'欢迎回来。'**
  String get loginWelcome;

  /// No description provided for @loginBody.
  ///
  /// In zh, this message translates to:
  /// **'这里没有需要证明的事。\n先从此刻开始。'**
  String get loginBody;

  /// No description provided for @mobileNumber.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get mobileNumber;

  /// No description provided for @verificationCode.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get verificationCode;

  /// No description provided for @requestCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get requestCode;

  /// No description provided for @enterZeroon.
  ///
  /// In zh, this message translates to:
  /// **'进入 ZEROON'**
  String get enterZeroon;

  /// No description provided for @loginAgreement.
  ///
  /// In zh, this message translates to:
  /// **'登录即代表同意《用户协议》与《隐私政策》'**
  String get loginAgreement;

  /// No description provided for @localCodeReady.
  ///
  /// In zh, this message translates to:
  /// **'本地验证码已生成，开发环境默认使用 000000。'**
  String get localCodeReady;

  /// No description provided for @codeRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时没能获取验证码，请稍后再试。'**
  String get codeRequestFailed;

  /// No description provided for @loginUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法登录。语言选择仍保存在这台设备上。'**
  String get loginUnavailable;

  /// No description provided for @encounterMark.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON ENCOUNTER'**
  String get encounterMark;

  /// No description provided for @encounterTitle.
  ///
  /// In zh, this message translates to:
  /// **'与 ZEROON 相遇'**
  String get encounterTitle;

  /// No description provided for @encounterBody.
  ///
  /// In zh, this message translates to:
  /// **'在开始记录之前，先确认这个会陪你回看此刻的 ZEROON。'**
  String get encounterBody;

  /// No description provided for @confirmEncounter.
  ///
  /// In zh, this message translates to:
  /// **'确认相遇'**
  String get confirmEncounter;

  /// No description provided for @encounterCompleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'你的 ZEROON 已经在这里'**
  String get encounterCompleteTitle;

  /// No description provided for @encounterCompleteBody.
  ///
  /// In zh, this message translates to:
  /// **'我在这里。以后你留下的此刻，我都会陪你一起回看。'**
  String get encounterCompleteBody;

  /// No description provided for @nameplate.
  ///
  /// In zh, this message translates to:
  /// **'NAMEPLATE'**
  String get nameplate;

  /// No description provided for @encounterUnavailableTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂时没有见到 ZEROON'**
  String get encounterUnavailableTitle;

  /// No description provided for @encounterUnavailableBody.
  ///
  /// In zh, this message translates to:
  /// **'你的位置还在。准备好时可以再试一次。'**
  String get encounterUnavailableBody;

  /// No description provided for @navNow.
  ///
  /// In zh, this message translates to:
  /// **'此刻'**
  String get navNow;

  /// No description provided for @navArchive.
  ///
  /// In zh, this message translates to:
  /// **'缓存'**
  String get navArchive;

  /// No description provided for @navGrowth.
  ///
  /// In zh, this message translates to:
  /// **'成长'**
  String get navGrowth;

  /// No description provided for @navProfile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get navProfile;

  /// No description provided for @greeting.
  ///
  /// In zh, this message translates to:
  /// **'见到你了，'**
  String get greeting;

  /// No description provided for @todayZeroon.
  ///
  /// In zh, this message translates to:
  /// **'今天的 ZEROON'**
  String get todayZeroon;

  /// No description provided for @chooseCurrentState.
  ///
  /// In zh, this message translates to:
  /// **'选择此刻状态'**
  String get chooseCurrentState;

  /// No description provided for @chooseStateFirst.
  ///
  /// In zh, this message translates to:
  /// **'先选择一个最接近的状态，ZEROON 会从这一刻开始记录。'**
  String get chooseStateFirst;

  /// No description provided for @startReset.
  ///
  /// In zh, this message translates to:
  /// **'开始一次归零'**
  String get startReset;

  /// No description provided for @todayArchive.
  ///
  /// In zh, this message translates to:
  /// **'今日山海缓存'**
  String get todayArchive;

  /// No description provided for @continuousReset.
  ///
  /// In zh, this message translates to:
  /// **'连续归零'**
  String get continuousReset;

  /// No description provided for @tapDateToReview.
  ///
  /// In zh, this message translates to:
  /// **'点亮日期可回看'**
  String get tapDateToReview;

  /// No description provided for @noArchiveToday.
  ///
  /// In zh, this message translates to:
  /// **'今天还没有新的山海缓存。'**
  String get noArchiveToday;

  /// No description provided for @stateHintFocus.
  ///
  /// In zh, this message translates to:
  /// **'今天适合安静地完成一件重要的事。'**
  String get stateHintFocus;

  /// No description provided for @stateHintCreate.
  ///
  /// In zh, this message translates to:
  /// **'把浮现出来的想法先放在这里。'**
  String get stateHintCreate;

  /// No description provided for @stateHintTired.
  ///
  /// In zh, this message translates to:
  /// **'可以慢一点，只保留最小的一步。'**
  String get stateHintTired;

  /// No description provided for @stateHintOverload.
  ///
  /// In zh, this message translates to:
  /// **'先把负荷放下来，不急着解决全部。'**
  String get stateHintOverload;

  /// No description provided for @stateHintConfused.
  ///
  /// In zh, this message translates to:
  /// **'混乱也可以被看见，然后慢慢归零。'**
  String get stateHintConfused;

  /// No description provided for @stateHintDefault.
  ///
  /// In zh, this message translates to:
  /// **'这里没有需要证明的事，先看见此刻。'**
  String get stateHintDefault;

  /// No description provided for @stateLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时没能读到此刻。你的记录没有改变。'**
  String get stateLoadFailed;

  /// No description provided for @justStarted.
  ///
  /// In zh, this message translates to:
  /// **'刚刚开始停留'**
  String get justStarted;

  /// No description provided for @minutesStayed.
  ///
  /// In zh, this message translates to:
  /// **'停留了约 {minutes} 分钟'**
  String minutesStayed(int minutes);

  /// No description provided for @hoursStayed.
  ///
  /// In zh, this message translates to:
  /// **'停留了约 {hours} 小时'**
  String hoursStayed(int hours);

  /// No description provided for @hoursMinutesStayed.
  ///
  /// In zh, this message translates to:
  /// **'停留了约 {hours} 小时 {minutes} 分钟'**
  String hoursMinutesStayed(int hours, int minutes);

  /// No description provided for @dayCount.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天'**
  String dayCount(int days);

  /// No description provided for @resetTitle.
  ///
  /// In zh, this message translates to:
  /// **'归零'**
  String get resetTitle;

  /// No description provided for @currentResetState.
  ///
  /// In zh, this message translates to:
  /// **'正在归零的状态'**
  String get currentResetState;

  /// No description provided for @noStateSelected.
  ///
  /// In zh, this message translates to:
  /// **'还没有选择此刻状态'**
  String get noStateSelected;

  /// No description provided for @chooseStateFromNow.
  ///
  /// In zh, this message translates to:
  /// **'请先回到此刻选择状态'**
  String get chooseStateFromNow;

  /// No description provided for @resetDurationHint.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 会从选择状态开始记录持续时间。'**
  String get resetDurationHint;

  /// No description provided for @recordSomethingLabel.
  ///
  /// In zh, this message translates to:
  /// **'留下一句话'**
  String get recordSomethingLabel;

  /// No description provided for @recordSomethingHint.
  ///
  /// In zh, this message translates to:
  /// **'今天发生了什么？'**
  String get recordSomethingHint;

  /// No description provided for @smallProgressLabel.
  ///
  /// In zh, this message translates to:
  /// **'今天想完成什么'**
  String get smallProgressLabel;

  /// No description provided for @smallProgressHint.
  ///
  /// In zh, this message translates to:
  /// **'完成一个很小的进展'**
  String get smallProgressHint;

  /// No description provided for @saveReset.
  ///
  /// In zh, this message translates to:
  /// **'保存这次归零'**
  String get saveReset;

  /// No description provided for @selectStateValidation.
  ///
  /// In zh, this message translates to:
  /// **'请先回到此刻，选择一个当前状态。'**
  String get selectStateValidation;

  /// No description provided for @recordContentValidation.
  ///
  /// In zh, this message translates to:
  /// **'至少写下一点感受、进展或内容。'**
  String get recordContentValidation;

  /// No description provided for @recordSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'这一次没有保存成功。你的草稿还在。'**
  String get recordSaveFailed;

  /// No description provided for @resetCompleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'归零完成'**
  String get resetCompleteTitle;

  /// No description provided for @resetStateMark.
  ///
  /// In zh, this message translates to:
  /// **'本次状态'**
  String get resetStateMark;

  /// No description provided for @resetSaved.
  ///
  /// In zh, this message translates to:
  /// **'已经替你保存好了。'**
  String get resetSaved;

  /// No description provided for @todayRecord.
  ///
  /// In zh, this message translates to:
  /// **'今天的记录'**
  String get todayRecord;

  /// No description provided for @goalPrefix.
  ///
  /// In zh, this message translates to:
  /// **'目标 ·'**
  String get goalPrefix;

  /// No description provided for @returnNow.
  ///
  /// In zh, this message translates to:
  /// **'回到此刻'**
  String get returnNow;

  /// No description provided for @viewArchive.
  ///
  /// In zh, this message translates to:
  /// **'查看山海缓存'**
  String get viewArchive;

  /// No description provided for @reflectionLoading.
  ///
  /// In zh, this message translates to:
  /// **'这一刻已经收好。ZEROON 正在轻轻回应。'**
  String get reflectionLoading;

  /// No description provided for @completionFallback.
  ///
  /// In zh, this message translates to:
  /// **'这一次归零已经完成。\n不用急着解释，先让它被好好保存。'**
  String get completionFallback;

  /// No description provided for @completionPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请基于我刚完成一次归零这个动作，给一句简短、温和、像 ZEROON 说的话。只确认这一刻已经被保存，不要猜测记录内容，不要诊断，也不要给过多建议。'**
  String get completionPrompt;

  /// No description provided for @archiveTitle.
  ///
  /// In zh, this message translates to:
  /// **'山海缓存'**
  String get archiveTitle;

  /// No description provided for @archivePrivate.
  ///
  /// In zh, this message translates to:
  /// **'属于你的记录，不公开，也不喧哗。'**
  String get archivePrivate;

  /// No description provided for @archiveCountSuffix.
  ///
  /// In zh, this message translates to:
  /// **'条沉淀'**
  String get archiveCountSuffix;

  /// No description provided for @archiveEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有归零记录。'**
  String get archiveEmpty;

  /// No description provided for @archiveEmptyFiltered.
  ///
  /// In zh, this message translates to:
  /// **'这一天还没有山海缓存。'**
  String get archiveEmptyFiltered;

  /// No description provided for @archiveEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'完成一次 Reset 后，这里会出现你的记录。'**
  String get archiveEmptyHint;

  /// No description provided for @archiveEmptyFilteredHint.
  ///
  /// In zh, this message translates to:
  /// **'换一天看看，也许有别的东西被保存下来。'**
  String get archiveEmptyFilteredHint;

  /// No description provided for @memoryEntry.
  ///
  /// In zh, this message translates to:
  /// **'记忆'**
  String get memoryEntry;

  /// No description provided for @filter.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get filter;

  /// No description provided for @allDates.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get allDates;

  /// No description provided for @chooseReviewDay.
  ///
  /// In zh, this message translates to:
  /// **'选择一天回看'**
  String get chooseReviewDay;

  /// No description provided for @filterPrefix.
  ///
  /// In zh, this message translates to:
  /// **'筛选：'**
  String get filterPrefix;

  /// No description provided for @filterDate.
  ///
  /// In zh, this message translates to:
  /// **'筛选：{date}'**
  String filterDate(String date);

  /// No description provided for @recordGoalPrefix.
  ///
  /// In zh, this message translates to:
  /// **'目标 ·'**
  String get recordGoalPrefix;

  /// No description provided for @zeroonObservation.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 观察'**
  String get zeroonObservation;

  /// No description provided for @observationLoading.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 正在回看你允许用于陪伴回应的记忆…'**
  String get observationLoading;

  /// No description provided for @observationFailed.
  ///
  /// In zh, this message translates to:
  /// **'这一次没能回看。你的记录仍然好好保存在这里。'**
  String get observationFailed;

  /// No description provided for @observationConsentNote.
  ///
  /// In zh, this message translates to:
  /// **'只参考你允许用于陪伴回应的记忆'**
  String get observationConsentNote;

  /// No description provided for @today.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get today;

  /// No description provided for @observationPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请只基于系统提供的、我已经允许用于 AI 的记忆，给一段简短、温和的 ZEROON 观察。只指出可被用户自己确认的轻微趋势，不做标签化判断，不给指令式建议。如果没有可用记忆，请坦诚说明暂时没有足够内容，不要猜测。'**
  String get observationPrompt;

  /// No description provided for @recordDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录详情'**
  String get recordDetailTitle;

  /// No description provided for @archiveMemoryMark.
  ///
  /// In zh, this message translates to:
  /// **'Archive 记忆'**
  String get archiveMemoryMark;

  /// No description provided for @privateRecord.
  ///
  /// In zh, this message translates to:
  /// **'私密记录'**
  String get privateRecord;

  /// No description provided for @recordNumber.
  ///
  /// In zh, this message translates to:
  /// **'记录编号'**
  String get recordNumber;

  /// No description provided for @resetStatePrefix.
  ///
  /// In zh, this message translates to:
  /// **'归零状态：'**
  String get resetStatePrefix;

  /// No description provided for @resetStateValue.
  ///
  /// In zh, this message translates to:
  /// **'归零状态：{state}'**
  String resetStateValue(String state);

  /// No description provided for @recordTimePrefix.
  ///
  /// In zh, this message translates to:
  /// **'记录时间：'**
  String get recordTimePrefix;

  /// No description provided for @recordTimeValue.
  ///
  /// In zh, this message translates to:
  /// **'记录时间：{time}'**
  String recordTimeValue(String time);

  /// No description provided for @smallProgressTitle.
  ///
  /// In zh, this message translates to:
  /// **'今天的小进展'**
  String get smallProgressTitle;

  /// No description provided for @recordWordsTitle.
  ///
  /// In zh, this message translates to:
  /// **'想记录的话'**
  String get recordWordsTitle;

  /// No description provided for @zeroonEchoTitle.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 回声'**
  String get zeroonEchoTitle;

  /// No description provided for @recordLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时没能读到这条记录。它仍然好好保存在这里。'**
  String get recordLoadFailed;

  /// No description provided for @memoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 记住的'**
  String get memoryTitle;

  /// No description provided for @memoryIntro.
  ///
  /// In zh, this message translates to:
  /// **'这些内容来自你的记录，只属于你。'**
  String get memoryIntro;

  /// No description provided for @memoryIntroControl.
  ///
  /// In zh, this message translates to:
  /// **'你可以暂停一条记忆，也可以把它从 ZEROON 中删除。'**
  String get memoryIntroControl;

  /// No description provided for @memoryEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'这里还很安静。'**
  String get memoryEmptyTitle;

  /// No description provided for @memoryEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'完成一次 Reset 后，ZEROON 会把来源清楚的记忆放在这里。'**
  String get memoryEmptyBody;

  /// No description provided for @memoryLoadFailedTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂时没能读到这些记忆。'**
  String get memoryLoadFailedTitle;

  /// No description provided for @memoryLoadFailedBody.
  ///
  /// In zh, this message translates to:
  /// **'你的记录还在。可以稍后再回来看看。'**
  String get memoryLoadFailedBody;

  /// No description provided for @keepInMemory.
  ///
  /// In zh, this message translates to:
  /// **'保留在连续记忆中'**
  String get keepInMemory;

  /// No description provided for @keepInMemoryHint.
  ///
  /// In zh, this message translates to:
  /// **'暂停后仍可在这里看到，但不会参与后续回应。'**
  String get keepInMemoryHint;

  /// No description provided for @allowResponseReference.
  ///
  /// In zh, this message translates to:
  /// **'允许用于回应参考'**
  String get allowResponseReference;

  /// No description provided for @memoryProcessing.
  ///
  /// In zh, this message translates to:
  /// **'正在处理…'**
  String get memoryProcessing;

  /// No description provided for @deleteMemory.
  ///
  /// In zh, this message translates to:
  /// **'删除这条记忆'**
  String get deleteMemory;

  /// No description provided for @memoryChangeFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时没有改动。请稍后再试。'**
  String get memoryChangeFailed;

  /// No description provided for @memoryAiDisabledReceipt.
  ///
  /// In zh, this message translates to:
  /// **'已关闭回应参考权限。'**
  String get memoryAiDisabledReceipt;

  /// No description provided for @memoryAiPausedReceipt.
  ///
  /// In zh, this message translates to:
  /// **'已保存权限偏好。重新加入连续记忆后才会用于回应。'**
  String get memoryAiPausedReceipt;

  /// No description provided for @memoryAiEnabledReceipt.
  ///
  /// In zh, this message translates to:
  /// **'已允许用于回应参考。'**
  String get memoryAiEnabledReceipt;

  /// No description provided for @memoryPermissionFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时没有改动权限。请稍后再试。'**
  String get memoryPermissionFailed;

  /// No description provided for @memoryPausedPermissionOn.
  ///
  /// In zh, this message translates to:
  /// **'当前不会用于回应。重新加入连续记忆后，此权限才会生效。'**
  String get memoryPausedPermissionOn;

  /// No description provided for @memoryPausedPermissionOff.
  ///
  /// In zh, this message translates to:
  /// **'当前已暂停。即使开启此权限，重新加入连续记忆前也不会用于回应。'**
  String get memoryPausedPermissionOff;

  /// No description provided for @memoryActivePermissionOn.
  ///
  /// In zh, this message translates to:
  /// **'开启后，这条记忆可在下一次回应中作为上下文使用。'**
  String get memoryActivePermissionOn;

  /// No description provided for @memoryActivePermissionOff.
  ///
  /// In zh, this message translates to:
  /// **'默认关闭。开启后才会进入 ZEROON 的回应。'**
  String get memoryActivePermissionOff;

  /// No description provided for @deleteMemoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除这条记忆？'**
  String get deleteMemoryTitle;

  /// No description provided for @deleteMemoryBody.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 保存的这份记忆会被立即删除。原始 Zero Record 仍会留在山海缓存中。'**
  String get deleteMemoryBody;

  /// No description provided for @keepForNow.
  ///
  /// In zh, this message translates to:
  /// **'先保留'**
  String get keepForNow;

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  /// No description provided for @memoryDeleted.
  ///
  /// In zh, this message translates to:
  /// **'这条记忆已经删除。'**
  String get memoryDeleted;

  /// No description provided for @memoryDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时没能删除。请稍后再试。'**
  String get memoryDeleteFailed;

  /// No description provided for @memorySourceRecord.
  ///
  /// In zh, this message translates to:
  /// **'来源 · 一次 Zero Record'**
  String get memorySourceRecord;

  /// No description provided for @viewSource.
  ///
  /// In zh, this message translates to:
  /// **'查看来源'**
  String get viewSource;

  /// No description provided for @sourceUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'来源暂时不可查看'**
  String get sourceUnavailable;

  /// No description provided for @memoryActive.
  ///
  /// In zh, this message translates to:
  /// **'记忆中'**
  String get memoryActive;

  /// No description provided for @memoryPaused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get memoryPaused;

  /// No description provided for @boundaryNoticePrefix.
  ///
  /// In zh, this message translates to:
  /// **'边界说明：'**
  String get boundaryNoticePrefix;

  /// No description provided for @profileTitle.
  ///
  /// In zh, this message translates to:
  /// **'我与 ZEROON'**
  String get profileTitle;

  /// No description provided for @profileIntro.
  ///
  /// In zh, this message translates to:
  /// **'让 ZEROON 更懂你。以下信息都可以留空，只用于帮助它理解你留下的记录。'**
  String get profileIntro;

  /// No description provided for @nickname.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get nickname;

  /// No description provided for @nicknameHint.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 可以怎样称呼你'**
  String get nicknameHint;

  /// No description provided for @avatarPreset.
  ///
  /// In zh, this message translates to:
  /// **'头像预设'**
  String get avatarPreset;

  /// No description provided for @ageRange.
  ///
  /// In zh, this message translates to:
  /// **'年龄段'**
  String get ageRange;

  /// No description provided for @occupation.
  ///
  /// In zh, this message translates to:
  /// **'职业 / 身份'**
  String get occupation;

  /// No description provided for @occupationHint.
  ///
  /// In zh, this message translates to:
  /// **'学生、设计师、创业者，或其他你愿意留下的身份'**
  String get occupationHint;

  /// No description provided for @selfDescription.
  ///
  /// In zh, this message translates to:
  /// **'一句话自我描述'**
  String get selfDescription;

  /// No description provided for @selfDescriptionHint.
  ///
  /// In zh, this message translates to:
  /// **'你希望 ZEROON 怎样理解你'**
  String get selfDescriptionHint;

  /// No description provided for @allowProfileContext.
  ///
  /// In zh, this message translates to:
  /// **'允许 ZEROON 使用我的信息'**
  String get allowProfileContext;

  /// No description provided for @allowProfileContextHint.
  ///
  /// In zh, this message translates to:
  /// **'开启后，ZEROON 只会参考你主动填写的昵称、年龄段、职业 / 身份和自我描述。关闭后，下一次回应起就不再使用。'**
  String get allowProfileContextHint;

  /// No description provided for @saveProfile.
  ///
  /// In zh, this message translates to:
  /// **'保存我的信息'**
  String get saveProfile;

  /// No description provided for @profileSaved.
  ///
  /// In zh, this message translates to:
  /// **'已经保存。'**
  String get profileSaved;

  /// No description provided for @profileSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'这一次没有保存成功，请稍后再试。'**
  String get profileSaveFailed;

  /// No description provided for @dataControlTitle.
  ///
  /// In zh, this message translates to:
  /// **'你的数据，由你决定'**
  String get dataControlTitle;

  /// No description provided for @dataControlBody.
  ///
  /// In zh, this message translates to:
  /// **'你可以带走自己的数据，也可以随时离开。'**
  String get dataControlBody;

  /// No description provided for @exportData.
  ///
  /// In zh, this message translates to:
  /// **'复制我的数据副本'**
  String get exportData;

  /// No description provided for @exportingData.
  ///
  /// In zh, this message translates to:
  /// **'正在准备数据副本…'**
  String get exportingData;

  /// No description provided for @dataCopied.
  ///
  /// In zh, this message translates to:
  /// **'你的数据副本已复制为 JSON。'**
  String get dataCopied;

  /// No description provided for @dataExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法准备数据副本，请稍后再试。'**
  String get dataExportFailed;

  /// No description provided for @logout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In zh, this message translates to:
  /// **'删除账户与数据'**
  String get deleteAccount;

  /// No description provided for @deletingAccount.
  ///
  /// In zh, this message translates to:
  /// **'正在删除…'**
  String get deletingAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除账户与全部数据？'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In zh, this message translates to:
  /// **'你的资料、记录、对话、Memory 和登录会话会立即删除，无法恢复。去标识化的运行统计可能按隐私说明保留。'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除没有完成，你的数据仍然保留。请稍后再试。'**
  String get deleteAccountFailed;

  /// No description provided for @companionNotMetTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有与 ZEROON 相遇'**
  String get companionNotMetTitle;

  /// No description provided for @companionNotMetBody.
  ///
  /// In zh, this message translates to:
  /// **'首次登录后会先完成相遇，再启用 ZEROON 的记录和回看功能。'**
  String get companionNotMetBody;

  /// No description provided for @companionHereTitle.
  ///
  /// In zh, this message translates to:
  /// **'你的 ZEROON 已经在这里'**
  String get companionHereTitle;

  /// No description provided for @companionHereBody.
  ///
  /// In zh, this message translates to:
  /// **'我在这里。以后你留下的此刻，我都会陪你一起回看。'**
  String get companionHereBody;

  /// No description provided for @companionChecking.
  ///
  /// In zh, this message translates to:
  /// **'正在确认你的 ZEROON…'**
  String get companionChecking;

  /// No description provided for @profileLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时没能读到你的信息。'**
  String get profileLoadFailed;

  /// No description provided for @optionalNone.
  ///
  /// In zh, this message translates to:
  /// **'暂不填写'**
  String get optionalNone;

  /// No description provided for @avatarDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get avatarDefault;

  /// No description provided for @avatarMoon.
  ///
  /// In zh, this message translates to:
  /// **'月光'**
  String get avatarMoon;

  /// No description provided for @avatarMountain.
  ///
  /// In zh, this message translates to:
  /// **'山'**
  String get avatarMountain;

  /// No description provided for @avatarSea.
  ///
  /// In zh, this message translates to:
  /// **'海'**
  String get avatarSea;

  /// No description provided for @avatarLight.
  ///
  /// In zh, this message translates to:
  /// **'光'**
  String get avatarLight;

  /// No description provided for @avatarSeed.
  ///
  /// In zh, this message translates to:
  /// **'种子'**
  String get avatarSeed;

  /// No description provided for @ageUnder18.
  ///
  /// In zh, this message translates to:
  /// **'18 岁以下'**
  String get ageUnder18;

  /// No description provided for @age18To24.
  ///
  /// In zh, this message translates to:
  /// **'18–24 岁'**
  String get age18To24;

  /// No description provided for @age25To34.
  ///
  /// In zh, this message translates to:
  /// **'25–34 岁'**
  String get age25To34;

  /// No description provided for @age35To44.
  ///
  /// In zh, this message translates to:
  /// **'35–44 岁'**
  String get age35To44;

  /// No description provided for @age45To54.
  ///
  /// In zh, this message translates to:
  /// **'45–54 岁'**
  String get age45To54;

  /// No description provided for @age55Plus.
  ///
  /// In zh, this message translates to:
  /// **'55 岁以上'**
  String get age55Plus;

  /// No description provided for @agePreferNot.
  ///
  /// In zh, this message translates to:
  /// **'暂不说明'**
  String get agePreferNot;

  /// No description provided for @growthTitle.
  ///
  /// In zh, this message translates to:
  /// **'陪伴成长'**
  String get growthTitle;

  /// No description provided for @growthTogetherSince.
  ///
  /// In zh, this message translates to:
  /// **'相伴始于'**
  String get growthTogetherSince;

  /// No description provided for @growthIntro.
  ///
  /// In zh, this message translates to:
  /// **'不是每一天都需要留下什么。\n但你走过的路，正在这里慢慢发光。'**
  String get growthIntro;

  /// No description provided for @metricContinuous.
  ///
  /// In zh, this message translates to:
  /// **'连续归零'**
  String get metricContinuous;

  /// No description provided for @metricRecentContinuous.
  ///
  /// In zh, this message translates to:
  /// **'最近一次连续记录'**
  String get metricRecentContinuous;

  /// No description provided for @metricArchive.
  ///
  /// In zh, this message translates to:
  /// **'累计缓存'**
  String get metricArchive;

  /// No description provided for @metricPrivate.
  ///
  /// In zh, this message translates to:
  /// **'可见的私人沉淀'**
  String get metricPrivate;

  /// No description provided for @metricFirstRecord.
  ///
  /// In zh, this message translates to:
  /// **'第一次记录'**
  String get metricFirstRecord;

  /// No description provided for @metricTimeStarts.
  ///
  /// In zh, this message translates to:
  /// **'时间从这里开始'**
  String get metricTimeStarts;

  /// No description provided for @metricCompanionDays.
  ///
  /// In zh, this message translates to:
  /// **'陪伴天数'**
  String get metricCompanionDays;

  /// No description provided for @metricIncludesMeeting.
  ///
  /// In zh, this message translates to:
  /// **'包含相遇的第一天'**
  String get metricIncludesMeeting;

  /// No description provided for @unitDays.
  ///
  /// In zh, this message translates to:
  /// **'天'**
  String get unitDays;

  /// No description provided for @unitRecords.
  ///
  /// In zh, this message translates to:
  /// **'条'**
  String get unitRecords;

  /// No description provided for @growthTogetherYear.
  ///
  /// In zh, this message translates to:
  /// **'我们已经一起走过一年。'**
  String get growthTogetherYear;

  /// No description provided for @growthTogetherDays.
  ///
  /// In zh, this message translates to:
  /// **'我们已经一起走过 {days} 天。'**
  String growthTogetherDays(int days);

  /// No description provided for @growthStartsFirst.
  ///
  /// In zh, this message translates to:
  /// **'时间从第一条记录开始。'**
  String get growthStartsFirst;

  /// No description provided for @notYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有'**
  String get notYet;

  /// No description provided for @growthObservationLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在整理近期状态观察…'**
  String get growthObservationLoading;

  /// No description provided for @growthYearTitle.
  ///
  /// In zh, this message translates to:
  /// **'这一年的 ZEROON'**
  String get growthYearTitle;

  /// No description provided for @growthObservationUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'近期状态观察暂时不可用。'**
  String get growthObservationUnavailable;

  /// No description provided for @growthRetryObservation.
  ///
  /// In zh, this message translates to:
  /// **'重试观察'**
  String get growthRetryObservation;

  /// No description provided for @growthWaiting.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 还在安静等待更多记录。时间不急，能留下来的东西会慢慢出现。'**
  String get growthWaiting;

  /// No description provided for @growthFocusNarrative.
  ///
  /// In zh, this message translates to:
  /// **'你最常回到「{state}」，也正在学会把模糊的想法，一点一点放进可以被看见的地方。'**
  String growthFocusNarrative(String state);

  /// No description provided for @growthStateNarrative.
  ///
  /// In zh, this message translates to:
  /// **'你最常回到「{state}」。ZEROON 会记得这些微小的变化，也陪你慢慢看见它们。'**
  String growthStateNarrative(String state);

  /// No description provided for @growthNoteMark.
  ///
  /// In zh, this message translates to:
  /// **'成长说明'**
  String get growthNoteMark;

  /// No description provided for @growthNoteTitle.
  ///
  /// In zh, this message translates to:
  /// **'陪伴成长说明'**
  String get growthNoteTitle;

  /// No description provided for @growthNoteRecords.
  ///
  /// In zh, this message translates to:
  /// **'连续归零、累计缓存和第一次记录来自你的归零记录。'**
  String get growthNoteRecords;

  /// No description provided for @growthNotePattern.
  ///
  /// In zh, this message translates to:
  /// **'“这一年的 ZEROON”来自近期状态分布和山海缓存中的可见记录。'**
  String get growthNotePattern;

  /// No description provided for @growthNoteBoundary.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 不做诊断，不给你贴固定标签，只帮助你回看自己留下的变化。'**
  String get growthNoteBoundary;

  /// No description provided for @growthLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时没能读到成长信息。'**
  String get growthLoadFailed;

  /// No description provided for @growthInfoTooltip.
  ///
  /// In zh, this message translates to:
  /// **'了解成长信息'**
  String get growthInfoTooltip;

  /// No description provided for @supportTitle.
  ///
  /// In zh, this message translates to:
  /// **'帮助与反馈'**
  String get supportTitle;

  /// No description provided for @supportIntro.
  ///
  /// In zh, this message translates to:
  /// **'这条信息会发给负责 ZEROON 的团队成员，而不是你的陪伴者。'**
  String get supportIntro;

  /// No description provided for @supportSignedOutBody.
  ///
  /// In zh, this message translates to:
  /// **'如果你暂时无法登录，仍然可以直接联系负责 ZEROON 的团队成员。'**
  String get supportSignedOutBody;

  /// No description provided for @supportSettingHint.
  ///
  /// In zh, this message translates to:
  /// **'报告问题，或告诉我们你的建议'**
  String get supportSettingHint;

  /// No description provided for @supportEmailTitle.
  ///
  /// In zh, this message translates to:
  /// **'直接联系'**
  String get supportEmailTitle;

  /// No description provided for @supportCopyEmail.
  ///
  /// In zh, this message translates to:
  /// **'复制邮箱'**
  String get supportCopyEmail;

  /// No description provided for @supportEmailCopied.
  ///
  /// In zh, this message translates to:
  /// **'邮箱已复制'**
  String get supportEmailCopied;

  /// No description provided for @supportCategoryLabel.
  ///
  /// In zh, this message translates to:
  /// **'这次想反馈什么？'**
  String get supportCategoryLabel;

  /// No description provided for @supportCategoryProductProblem.
  ///
  /// In zh, this message translates to:
  /// **'产品问题'**
  String get supportCategoryProductProblem;

  /// No description provided for @supportCategorySuggestion.
  ///
  /// In zh, this message translates to:
  /// **'意见或建议'**
  String get supportCategorySuggestion;

  /// No description provided for @supportCategoryAccountPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'账户、数据或隐私'**
  String get supportCategoryAccountPrivacy;

  /// No description provided for @supportCategoryAiSafety.
  ///
  /// In zh, this message translates to:
  /// **'AI 回复或安全'**
  String get supportCategoryAiSafety;

  /// No description provided for @supportCategoryComplaintRights.
  ///
  /// In zh, this message translates to:
  /// **'投诉或权利请求'**
  String get supportCategoryComplaintRights;

  /// No description provided for @supportCategoryOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get supportCategoryOther;

  /// No description provided for @supportDescriptionLabel.
  ///
  /// In zh, this message translates to:
  /// **'发生了什么，或你希望提出什么建议？'**
  String get supportDescriptionLabel;

  /// No description provided for @supportDescriptionHint.
  ///
  /// In zh, this message translates to:
  /// **'可以写下操作步骤或有助于团队理解的背景。'**
  String get supportDescriptionHint;

  /// No description provided for @supportDiagnosticsTitle.
  ///
  /// In zh, this message translates to:
  /// **'附带基础应用信息'**
  String get supportDiagnosticsTitle;

  /// No description provided for @supportDiagnosticsHint.
  ///
  /// In zh, this message translates to:
  /// **'默认关闭。发送前可查看全部字段。'**
  String get supportDiagnosticsHint;

  /// No description provided for @supportDiagnosticsPreviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'将会发送的信息'**
  String get supportDiagnosticsPreviewTitle;

  /// No description provided for @supportDiagnosticApp.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get supportDiagnosticApp;

  /// No description provided for @supportDiagnosticPlatform.
  ///
  /// In zh, this message translates to:
  /// **'平台'**
  String get supportDiagnosticPlatform;

  /// No description provided for @supportDiagnosticLocale.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get supportDiagnosticLocale;

  /// No description provided for @supportDiagnosticTime.
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get supportDiagnosticTime;

  /// No description provided for @supportPrivacyNote.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 不会通过此表单附带你的记录、Memory、个人资料、对话、截图、文件或完整日志。'**
  String get supportPrivacyNote;

  /// No description provided for @supportRetentionNote.
  ///
  /// In zh, this message translates to:
  /// **'应用内请求关闭后最迟 180 天删除。支持邮箱中的副本遵循单独说明的最长 180 天流程，你也可以提前申请删除。'**
  String get supportRetentionNote;

  /// No description provided for @supportSubmit.
  ///
  /// In zh, this message translates to:
  /// **'发送给 ZEROON 团队'**
  String get supportSubmit;

  /// No description provided for @supportRetrySubmit.
  ///
  /// In zh, this message translates to:
  /// **'重新发送'**
  String get supportRetrySubmit;

  /// No description provided for @supportSubmitFailed.
  ///
  /// In zh, this message translates to:
  /// **'这条信息尚未发送，草稿仍保留在这里。你可以重试，或使用上方邮箱联系。'**
  String get supportSubmitFailed;

  /// No description provided for @supportValidationDescription.
  ///
  /// In zh, this message translates to:
  /// **'请先写下问题或建议。'**
  String get supportValidationDescription;

  /// No description provided for @supportReceiptTitle.
  ///
  /// In zh, this message translates to:
  /// **'我们已收到你的信息'**
  String get supportReceiptTitle;

  /// No description provided for @supportReceiptBody.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 团队成员会查看它。这份回执不承诺回复时间或问题解决结果。'**
  String get supportReceiptBody;

  /// No description provided for @supportReferenceLabel.
  ///
  /// In zh, this message translates to:
  /// **'回执编号'**
  String get supportReferenceLabel;

  /// No description provided for @supportCopyReference.
  ///
  /// In zh, this message translates to:
  /// **'复制回执编号'**
  String get supportCopyReference;

  /// No description provided for @supportReferenceCopied.
  ///
  /// In zh, this message translates to:
  /// **'回执编号已复制'**
  String get supportReferenceCopied;

  /// No description provided for @supportExternalBoundary.
  ///
  /// In zh, this message translates to:
  /// **'邮件不在应用内跟踪，因此不会在这里生成回执编号。你也可以通过邮件提出账户或数据删除请求。'**
  String get supportExternalBoundary;

  /// No description provided for @supportNonEmergency.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 支持不是紧急救助服务。'**
  String get supportNonEmergency;

  /// No description provided for @supportMyRequests.
  ///
  /// In zh, this message translates to:
  /// **'我的支持请求'**
  String get supportMyRequests;

  /// No description provided for @supportMyRequestsHint.
  ///
  /// In zh, this message translates to:
  /// **'查看处理状态和 ZEROON 团队回复'**
  String get supportMyRequestsHint;

  /// No description provided for @supportMyRequestsBody.
  ///
  /// In zh, this message translates to:
  /// **'这里保存着你与 ZEROON 负责团队之间的私人支持沟通。'**
  String get supportMyRequestsBody;

  /// No description provided for @supportViewRequest.
  ///
  /// In zh, this message translates to:
  /// **'查看这条请求'**
  String get supportViewRequest;

  /// No description provided for @supportLoadMore.
  ///
  /// In zh, this message translates to:
  /// **'加载更早的请求'**
  String get supportLoadMore;

  /// No description provided for @supportListRefreshFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时没能刷新支持请求，已经显示的内容仍保留在这里。'**
  String get supportListRefreshFailed;

  /// No description provided for @supportEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有支持请求'**
  String get supportEmptyTitle;

  /// No description provided for @supportEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'当你提交问题或建议后，处理状态和人工回复会出现在这里。'**
  String get supportEmptyBody;

  /// No description provided for @supportLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时没能读到你的支持请求。'**
  String get supportLoadFailed;

  /// No description provided for @supportRefresh.
  ///
  /// In zh, this message translates to:
  /// **'再试一次'**
  String get supportRefresh;

  /// No description provided for @supportRequestDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'支持请求'**
  String get supportRequestDetailTitle;

  /// No description provided for @supportConversationTitle.
  ///
  /// In zh, this message translates to:
  /// **'沟通记录'**
  String get supportConversationTitle;

  /// No description provided for @supportNoReplies.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 团队暂时还没有回复，你的请求仍然保留在这里。'**
  String get supportNoReplies;

  /// No description provided for @supportProgressTitle.
  ///
  /// In zh, this message translates to:
  /// **'处理进度'**
  String get supportProgressTitle;

  /// No description provided for @supportStatusReceived.
  ///
  /// In zh, this message translates to:
  /// **'已收到'**
  String get supportStatusReceived;

  /// No description provided for @supportStatusInReview.
  ///
  /// In zh, this message translates to:
  /// **'查看中'**
  String get supportStatusInReview;

  /// No description provided for @supportStatusWaitingForUser.
  ///
  /// In zh, this message translates to:
  /// **'等待你补充'**
  String get supportStatusWaitingForUser;

  /// No description provided for @supportStatusReplied.
  ///
  /// In zh, this message translates to:
  /// **'团队已回复'**
  String get supportStatusReplied;

  /// No description provided for @supportStatusClosed.
  ///
  /// In zh, this message translates to:
  /// **'已关闭'**
  String get supportStatusClosed;

  /// No description provided for @supportStatusReceivedHint.
  ///
  /// In zh, this message translates to:
  /// **'你的请求已被妥善记录，正在等待团队成员查看。'**
  String get supportStatusReceivedHint;

  /// No description provided for @supportStatusInReviewHint.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 团队成员正在查看这条请求。'**
  String get supportStatusInReviewHint;

  /// No description provided for @supportStatusWaitingForUserHint.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 团队需要你补充一些信息，之后才能继续查看。'**
  String get supportStatusWaitingForUserHint;

  /// No description provided for @supportStatusRepliedHint.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 团队已经回复。你可以在下方阅读回复，并在需要时继续补充。'**
  String get supportStatusRepliedHint;

  /// No description provided for @supportStatusClosedHint.
  ///
  /// In zh, this message translates to:
  /// **'这条请求已经关闭，沟通记录仍会保留供你回看。'**
  String get supportStatusClosedHint;

  /// No description provided for @supportActorSystem.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 支持'**
  String get supportActorSystem;

  /// No description provided for @supportActorYou.
  ///
  /// In zh, this message translates to:
  /// **'你'**
  String get supportActorYou;

  /// No description provided for @supportActorTeam.
  ///
  /// In zh, this message translates to:
  /// **'ZEROON 团队'**
  String get supportActorTeam;

  /// No description provided for @supportWaitingPrompt.
  ///
  /// In zh, this message translates to:
  /// **'团队正在等待你补充信息。'**
  String get supportWaitingPrompt;

  /// No description provided for @supportFollowUpLabel.
  ///
  /// In zh, this message translates to:
  /// **'补充信息'**
  String get supportFollowUpLabel;

  /// No description provided for @supportFollowUpHint.
  ///
  /// In zh, this message translates to:
  /// **'回复团队需要的背景信息，请不要填写密码或验证码。'**
  String get supportFollowUpHint;

  /// No description provided for @supportSendFollowUp.
  ///
  /// In zh, this message translates to:
  /// **'发送补充信息'**
  String get supportSendFollowUp;

  /// No description provided for @supportRetryFollowUp.
  ///
  /// In zh, this message translates to:
  /// **'重新发送'**
  String get supportRetryFollowUp;

  /// No description provided for @supportFollowUpFailed.
  ///
  /// In zh, this message translates to:
  /// **'这条补充信息尚未发送，草稿仍保留在这里。'**
  String get supportFollowUpFailed;

  /// No description provided for @supportFollowUpValidation.
  ///
  /// In zh, this message translates to:
  /// **'请先写下要补充的信息。'**
  String get supportFollowUpValidation;

  /// No description provided for @supportFollowUpSent.
  ///
  /// In zh, this message translates to:
  /// **'补充信息已发送。'**
  String get supportFollowUpSent;

  /// No description provided for @supportClosedFollowUp.
  ///
  /// In zh, this message translates to:
  /// **'这条请求已经关闭，无法继续在应用内补充。如果问题仍未解决，你可以新建请求或使用支持邮箱联系。'**
  String get supportClosedFollowUp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
