import '../l10n/app_localizations.dart';
import 'support_models.dart';

String supportCategoryLabel(
  AppLocalizations l10n,
  SupportCategory category,
) {
  return switch (category) {
    SupportCategory.productProblem => l10n.supportCategoryProductProblem,
    SupportCategory.suggestion => l10n.supportCategorySuggestion,
    SupportCategory.accountDataPrivacy => l10n.supportCategoryAccountPrivacy,
    SupportCategory.aiResponseSafety => l10n.supportCategoryAiSafety,
    SupportCategory.complaintRights => l10n.supportCategoryComplaintRights,
    SupportCategory.other => l10n.supportCategoryOther,
  };
}

String supportStatusLabel(
  AppLocalizations l10n,
  SupportRequestStatus status,
) {
  return switch (status) {
    SupportRequestStatus.received => l10n.supportStatusReceived,
    SupportRequestStatus.inReview => l10n.supportStatusInReview,
    SupportRequestStatus.waitingForUser => l10n.supportStatusWaitingForUser,
    SupportRequestStatus.replied => l10n.supportStatusReplied,
    SupportRequestStatus.closed => l10n.supportStatusClosed,
  };
}

String supportStatusExplanation(
  AppLocalizations l10n,
  SupportRequestStatus status,
) {
  return switch (status) {
    SupportRequestStatus.received => l10n.supportStatusReceivedHint,
    SupportRequestStatus.inReview => l10n.supportStatusInReviewHint,
    SupportRequestStatus.waitingForUser => l10n.supportStatusWaitingForUserHint,
    SupportRequestStatus.replied => l10n.supportStatusRepliedHint,
    SupportRequestStatus.closed => l10n.supportStatusClosedHint,
  };
}

String supportActorLabel(AppLocalizations l10n, SupportActorType actor) {
  return switch (actor) {
    SupportActorType.system => l10n.supportActorSystem,
    SupportActorType.user => l10n.supportActorYou,
    SupportActorType.admin => l10n.supportActorTeam,
  };
}
