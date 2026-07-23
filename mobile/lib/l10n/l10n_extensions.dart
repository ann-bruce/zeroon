import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

extension ZeroonLocalizations on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get localeName => l10n.localeName;
}

String localizedStateLabel(BuildContext context, String state) {
  final l10n = context.l10n;
  return switch (state) {
    'IDLE' => l10n.stateIdle,
    'CALM' => l10n.stateCalm,
    'FOCUS' => l10n.stateFocus,
    'CREATE' => l10n.stateCreate,
    'TIRED' => l10n.stateTired,
    'OVERLOAD' => l10n.stateOverload,
    'CONFUSED' => l10n.stateConfused,
    _ => state,
  };
}

String localizedDate(BuildContext context, DateTime value) {
  return DateFormat.yMMMd(context.localeName).format(value.toLocal());
}

String localizedShortDate(BuildContext context, DateTime value) {
  return DateFormat.Md(context.localeName).format(value.toLocal());
}

String localizedTime(BuildContext context, DateTime value) {
  return DateFormat.Hm(context.localeName).format(value.toLocal());
}
