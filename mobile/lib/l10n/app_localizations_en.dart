// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ZEROON';

  @override
  String get languageFollowSystem => 'Follow system';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSyncPending =>
      'This device has changed language. Account sync will retry when the network is available.';

  @override
  String get languageStorageUnavailable =>
      'Language settings cannot be saved right now. Your choice will remain for this session.';

  @override
  String get processing => 'Working…';

  @override
  String get retry => 'Try again';

  @override
  String get retryShort => 'Retry';

  @override
  String get genericLoadFailed => 'ZEROON couldn\'t load this just now.';

  @override
  String get genericActionFailed =>
      'That didn\'t complete. Please try again in a moment.';

  @override
  String get stateIdle => 'Waiting';

  @override
  String get stateCalm => 'Calm';

  @override
  String get stateFocus => 'Focused';

  @override
  String get stateCreate => 'Creating';

  @override
  String get stateTired => 'Tired';

  @override
  String get stateOverload => 'Overloaded';

  @override
  String get stateConfused => 'Unclear';

  @override
  String get helpAndContact => 'Help and contact';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get openProfile => 'Open profile and settings';

  @override
  String get languageSetting => 'Language';

  @override
  String get languageSettingHint =>
      'Choose how ZEROON speaks with you. Your records stay in their original language.';

  @override
  String get languagePickerTooltip => 'Change language / 切换语言';

  @override
  String get loginMark => 'RESET / ZEROON';

  @override
  String get loginWelcome => 'Welcome back.';

  @override
  String get loginBody =>
      'There is nothing to prove here.\nBegin with this moment.';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get verificationCode => 'Verification code';

  @override
  String get requestCode => 'Get code';

  @override
  String get enterZeroon => 'Enter ZEROON';

  @override
  String get loginAgreement =>
      'By signing in, you agree to the Terms of Use and Privacy Policy.';

  @override
  String get localCodeReady =>
      'A local code was created. The development default is 000000.';

  @override
  String get codeRequestFailed =>
      'The code couldn\'t be requested. Please try again.';

  @override
  String get loginUnavailable =>
      'Sign-in is unavailable just now. Your language choice is still saved on this device.';

  @override
  String get encounterMark => 'ZEROON ENCOUNTER';

  @override
  String get encounterTitle => 'Meet ZEROON';

  @override
  String get encounterBody =>
      'Before you begin recording, meet the ZEROON that will stay with the moments you choose to revisit.';

  @override
  String get confirmEncounter => 'Meet ZEROON';

  @override
  String get encounterCompleteTitle => 'Your ZEROON is here';

  @override
  String get encounterCompleteBody =>
      'I\'m here. The moments you leave behind can be revisited together, gently and in your time.';

  @override
  String get nameplate => 'NAMEPLATE';

  @override
  String get encounterUnavailableTitle => 'ZEROON isn\'t visible just now';

  @override
  String get encounterUnavailableBody =>
      'Your place is still here. Try again when you\'re ready.';

  @override
  String get navNow => 'Now';

  @override
  String get navArchive => 'Archive';

  @override
  String get navGrowth => 'Growth';

  @override
  String get navProfile => 'Me';

  @override
  String get greeting => 'Good to see you,';

  @override
  String get todayZeroon => 'TODAY\'S ZEROON';

  @override
  String get chooseCurrentState => 'Choose this moment';

  @override
  String get chooseStateFirst =>
      'Choose the state that feels closest. ZEROON will begin holding time from here.';

  @override
  String get startReset => 'Begin a Reset';

  @override
  String get todayArchive => 'TODAY\'S ARCHIVE';

  @override
  String get continuousReset => 'RESET RHYTHM';

  @override
  String get tapDateToReview => 'Choose a lit date to revisit';

  @override
  String get noArchiveToday =>
      'Nothing new has been placed in the Archive today.';

  @override
  String get stateHintFocus => 'A quiet moment for one thing that matters.';

  @override
  String get stateHintCreate => 'Place the idea here before it drifts away.';

  @override
  String get stateHintTired =>
      'You can move slowly and keep only the smallest next step.';

  @override
  String get stateHintOverload =>
      'Set some of the weight down. It does not all need solving now.';

  @override
  String get stateHintConfused =>
      'Uncertainty can be seen first, then gently reset.';

  @override
  String get stateHintDefault =>
      'There is nothing to prove here. Notice this moment first.';

  @override
  String get stateLoadFailed =>
      'This moment couldn\'t be read. Your records are unchanged.';

  @override
  String get justStarted => 'Just began';

  @override
  String minutesStayed(int minutes) {
    return 'About $minutes min';
  }

  @override
  String hoursStayed(int hours) {
    return 'About $hours hr';
  }

  @override
  String hoursMinutesStayed(int hours, int minutes) {
    return 'About $hours hr $minutes min';
  }

  @override
  String dayCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String get resetTitle => 'Reset';

  @override
  String get currentResetState => 'STATE BEING RESET';

  @override
  String get noStateSelected => 'NO STATE SELECTED';

  @override
  String get chooseStateFromNow => 'Choose a state from Now first';

  @override
  String get resetDurationHint =>
      'ZEROON starts holding time when you choose a state.';

  @override
  String get recordSomethingLabel => 'Leave a few words';

  @override
  String get recordSomethingHint => 'What happened today?';

  @override
  String get smallProgressLabel => 'A small thing for today';

  @override
  String get smallProgressHint => 'One quiet step is enough';

  @override
  String get saveReset => 'Save this Reset';

  @override
  String get selectStateValidation =>
      'Choose a current state before beginning a Reset.';

  @override
  String get recordContentValidation =>
      'Leave a feeling, a small step, or a few words first.';

  @override
  String get recordSaveFailed =>
      'This Reset wasn\'t saved. Your draft is still here.';

  @override
  String get resetCompleteTitle => 'Reset complete';

  @override
  String get resetStateMark => 'THIS MOMENT';

  @override
  String get resetSaved => 'This moment has been kept for you.';

  @override
  String get todayRecord => 'TODAY\'S RECORD';

  @override
  String get goalPrefix => 'Small step ·';

  @override
  String get returnNow => 'Return to Now';

  @override
  String get viewArchive => 'View Archive';

  @override
  String get reflectionLoading =>
      'This moment is safe. ZEROON is responding quietly.';

  @override
  String get completionFallback =>
      'This Reset is complete.\nThere is no need to explain it yet. Let it be held first.';

  @override
  String get completionPrompt =>
      'Offer one brief, warm line after I complete a Reset. Only acknowledge that this moment has been saved. Do not guess the record, diagnose me, or give too much advice.';

  @override
  String get archiveTitle => 'Archive';

  @override
  String get archivePrivate =>
      'Yours alone. Private, quiet, and not performed.';

  @override
  String get archiveCountSuffix => 'saved';

  @override
  String get archiveEmpty => 'The Archive is still quiet.';

  @override
  String get archiveEmptyFiltered => 'Nothing was placed here on this day.';

  @override
  String get archiveEmptyHint =>
      'Complete a Reset and your record will appear here.';

  @override
  String get archiveEmptyFilteredHint =>
      'Try another day. Something else may be waiting there.';

  @override
  String get memoryEntry => 'Memory';

  @override
  String get filter => 'Filter';

  @override
  String get allDates => 'All';

  @override
  String get chooseReviewDay => 'Choose a day to revisit';

  @override
  String get filterPrefix => 'Filter ·';

  @override
  String filterDate(String date) {
    return 'Filter · $date';
  }

  @override
  String get recordGoalPrefix => 'Small step ·';

  @override
  String get zeroonObservation => 'ZEROON REFLECTION';

  @override
  String get observationLoading =>
      'ZEROON is revisiting only the memories you allowed for companion responses…';

  @override
  String get observationFailed =>
      'This reflection couldn\'t return. Your records remain safely here.';

  @override
  String get observationConsentNote =>
      'Only memories you allowed for companion responses are referenced';

  @override
  String get today => 'Today';

  @override
  String get observationPrompt =>
      'Using only the memories explicitly provided by the system and allowed for AI context, offer a short, gentle ZEROON reflection. Mention only a light pattern the user can verify. Do not label, diagnose, direct, or guess. If there is not enough context, say so honestly.';

  @override
  String get recordDetailTitle => 'Record details';

  @override
  String get archiveMemoryMark => 'ARCHIVE MEMORY';

  @override
  String get privateRecord => 'Private record';

  @override
  String get recordNumber => 'Record';

  @override
  String get resetStatePrefix => 'Reset state:';

  @override
  String resetStateValue(String state) {
    return 'Reset state: $state';
  }

  @override
  String get recordTimePrefix => 'Recorded:';

  @override
  String recordTimeValue(String time) {
    return 'Recorded: $time';
  }

  @override
  String get smallProgressTitle => 'Today\'s small step';

  @override
  String get recordWordsTitle => 'Words left here';

  @override
  String get zeroonEchoTitle => 'ZEROON echo';

  @override
  String get recordLoadFailed =>
      'This record couldn\'t be read just now. It remains safely stored.';

  @override
  String get memoryTitle => 'What ZEROON remembers';

  @override
  String get memoryIntro =>
      'These came from your records and belong only to you.';

  @override
  String get memoryIntroControl =>
      'You can pause a memory or remove it from ZEROON.';

  @override
  String get memoryEmptyTitle => 'It is still quiet here.';

  @override
  String get memoryEmptyBody =>
      'After a Reset, ZEROON can place source-linked memories here.';

  @override
  String get memoryLoadFailedTitle =>
      'These memories couldn\'t be read just now.';

  @override
  String get memoryLoadFailedBody =>
      'Your records are still here. You can return later.';

  @override
  String get keepInMemory => 'Keep in continuous memory';

  @override
  String get keepInMemoryHint =>
      'When paused, it stays visible here but does not join future responses.';

  @override
  String get allowResponseReference => 'Allow as response context';

  @override
  String get memoryProcessing => 'Working…';

  @override
  String get deleteMemory => 'Delete this memory';

  @override
  String get memoryChangeFailed =>
      'That memory setting didn\'t change. Please try again.';

  @override
  String get memoryAiDisabledReceipt => 'Response-context permission is off.';

  @override
  String get memoryAiPausedReceipt =>
      'Permission saved. It will not be used until this memory rejoins continuous memory.';

  @override
  String get memoryAiEnabledReceipt =>
      'This memory may now be used as response context.';

  @override
  String get memoryPermissionFailed =>
      'That permission didn\'t change. Please try again.';

  @override
  String get memoryPausedPermissionOn =>
      'Not used now. This permission becomes active only after the memory rejoins continuous memory.';

  @override
  String get memoryPausedPermissionOff =>
      'This memory is paused. Turning permission on will not use it until it rejoins continuous memory.';

  @override
  String get memoryActivePermissionOn =>
      'This memory may be available as context for the next response.';

  @override
  String get memoryActivePermissionOff =>
      'Off by default. Turn it on only if you want it in ZEROON\'s responses.';

  @override
  String get deleteMemoryTitle => 'Delete this memory?';

  @override
  String get deleteMemoryBody =>
      'ZEROON\'s saved memory will be removed immediately. The original Zero Record remains in your Archive.';

  @override
  String get keepForNow => 'Keep for now';

  @override
  String get confirmDelete => 'Delete';

  @override
  String get memoryDeleted => 'The memory was deleted.';

  @override
  String get memoryDeleteFailed =>
      'The memory couldn\'t be deleted. Please try again.';

  @override
  String get memorySourceRecord => 'Source · one Zero Record';

  @override
  String get viewSource => 'View source';

  @override
  String get sourceUnavailable => 'Source unavailable just now';

  @override
  String get memoryActive => 'In memory';

  @override
  String get memoryPaused => 'Paused';

  @override
  String get boundaryNoticePrefix => 'Boundary note:';

  @override
  String get profileTitle => 'Me and ZEROON';

  @override
  String get profileIntro =>
      'Help ZEROON understand you gently. Everything below is optional and only supports the records you choose to leave.';

  @override
  String get nickname => 'Name';

  @override
  String get nicknameHint => 'How ZEROON may address you';

  @override
  String get avatarPreset => 'Avatar preset';

  @override
  String get ageRange => 'Age range';

  @override
  String get occupation => 'Role / identity';

  @override
  String get occupationHint =>
      'Student, designer, founder, or another role you choose to share';

  @override
  String get selfDescription => 'A short self-description';

  @override
  String get selfDescriptionHint =>
      'How you would like ZEROON to understand you';

  @override
  String get allowProfileContext => 'Allow ZEROON to use my information';

  @override
  String get allowProfileContextHint =>
      'When on, ZEROON may use only the name, age range, role, and self-description you entered. Turn it off and the next response stops using them.';

  @override
  String get saveProfile => 'Save my information';

  @override
  String get profileSaved => 'Saved.';

  @override
  String get profileSaveFailed =>
      'Your information wasn\'t saved. Please try again.';

  @override
  String get dataControlTitle => 'Your data, your choice';

  @override
  String get dataControlBody =>
      'You can take a copy of your data or leave at any time.';

  @override
  String get exportData => 'Copy my data';

  @override
  String get exportingData => 'Preparing your data…';

  @override
  String get dataCopied => 'Your JSON data copy is on the clipboard.';

  @override
  String get dataExportFailed =>
      'Your data copy couldn\'t be prepared. Please try again.';

  @override
  String get logout => 'Sign out';

  @override
  String get deleteAccount => 'Delete account and data';

  @override
  String get deletingAccount => 'Deleting…';

  @override
  String get deleteAccountTitle => 'Delete your account and all data?';

  @override
  String get deleteAccountBody =>
      'Your profile, records, conversations, Memory, and sessions will be deleted immediately and cannot be restored. Deidentified operational statistics may remain as described in the privacy notice.';

  @override
  String get deleteAccountFailed =>
      'Deletion didn\'t complete. Your data is still here. Please try again.';

  @override
  String get companionNotMetTitle => 'You haven\'t met ZEROON yet';

  @override
  String get companionNotMetBody =>
      'After first sign-in, you will meet ZEROON before recording and revisiting moments.';

  @override
  String get companionHereTitle => 'Your ZEROON is here';

  @override
  String get companionHereBody =>
      'I\'m here. The moments you leave can be revisited together.';

  @override
  String get companionChecking => 'Finding your ZEROON…';

  @override
  String get profileLoadFailed =>
      'Your information couldn\'t be read just now.';

  @override
  String get optionalNone => 'Prefer not to say';

  @override
  String get avatarDefault => 'Default';

  @override
  String get avatarMoon => 'Moonlight';

  @override
  String get avatarMountain => 'Mountain';

  @override
  String get avatarSea => 'Sea';

  @override
  String get avatarLight => 'Light';

  @override
  String get avatarSeed => 'Seed';

  @override
  String get ageUnder18 => 'Under 18';

  @override
  String get age18To24 => '18–24';

  @override
  String get age25To34 => '25–34';

  @override
  String get age35To44 => '35–44';

  @override
  String get age45To54 => '45–54';

  @override
  String get age55Plus => '55+';

  @override
  String get agePreferNot => 'Prefer not to say';

  @override
  String get growthTitle => 'Companion growth';

  @override
  String get growthTogetherSince => 'TOGETHER SINCE';

  @override
  String get growthIntro =>
      'Not every day needs to leave something behind.\nThe path you have walked is slowly becoming visible here.';

  @override
  String get metricContinuous => 'Reset rhythm';

  @override
  String get metricRecentContinuous => 'Most recent continuous record';

  @override
  String get metricArchive => 'Archive total';

  @override
  String get metricPrivate => 'Private moments you can revisit';

  @override
  String get metricFirstRecord => 'First record';

  @override
  String get metricTimeStarts => 'Time begins here';

  @override
  String get metricCompanionDays => 'Companion days';

  @override
  String get metricIncludesMeeting => 'Including the day you met';

  @override
  String get unitDays => 'days';

  @override
  String get unitRecords => 'saved';

  @override
  String get growthTogetherYear => 'We have been here together for a year.';

  @override
  String growthTogetherDays(int days) {
    return 'We have been here together for $days days.';
  }

  @override
  String get growthStartsFirst => 'Time begins with the first record.';

  @override
  String get notYet => 'Not yet';

  @override
  String get growthObservationLoading => 'Gathering a recent state reflection…';

  @override
  String get growthYearTitle => 'ZEROON OVER TIME';

  @override
  String get growthObservationUnavailable =>
      'A recent state reflection isn\'t available just now.';

  @override
  String get growthRetryObservation => 'Try reflection again';

  @override
  String get growthWaiting =>
      'ZEROON is quietly waiting for more records. There is no hurry; what stays will appear in time.';

  @override
  String growthFocusNarrative(String state) {
    return 'You return most often to “$state”, and are giving unclear thoughts a place where they can be seen, one small piece at a time.';
  }

  @override
  String growthStateNarrative(String state) {
    return 'You return most often to “$state”. ZEROON will remember these small shifts and help you notice them over time.';
  }

  @override
  String get growthNoteMark => 'GROWTH NOTE';

  @override
  String get growthNoteTitle => 'About companion growth';

  @override
  String get growthNoteRecords =>
      'Reset rhythm, Archive total, and first record come from your Reset records.';

  @override
  String get growthNotePattern =>
      'ZEROON over time comes from recent state distribution and visible Archive records.';

  @override
  String get growthNoteBoundary =>
      'ZEROON does not diagnose or fix labels onto you. It only helps you revisit changes you left behind.';

  @override
  String get growthLoadFailed =>
      'Growth information couldn\'t be read just now.';

  @override
  String get growthInfoTooltip => 'About growth information';
}
