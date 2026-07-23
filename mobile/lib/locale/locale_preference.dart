import 'package:flutter/widgets.dart';

enum LocalePreference {
  followSystem('FOLLOW_SYSTEM'),
  simplifiedChinese('ZH_CN'),
  english('EN');

  const LocalePreference(this.wireValue);

  final String wireValue;

  static LocalePreference fromWireValue(String? value) {
    return switch (value) {
      'ZH_CN' => LocalePreference.simplifiedChinese,
      'EN' => LocalePreference.english,
      _ => LocalePreference.followSystem,
    };
  }
}

const simplifiedChineseLocale = Locale('zh', 'CN');
const englishLocale = Locale('en');

Locale resolveEffectiveLocale(
  LocalePreference preference,
  List<Locale>? systemLocales,
) {
  return switch (preference) {
    LocalePreference.simplifiedChinese => simplifiedChineseLocale,
    LocalePreference.english => englishLocale,
    LocalePreference.followSystem => _resolveSystemLocale(systemLocales),
  };
}

Locale resolveSupportedSystemLocale(
  List<Locale>? systemLocales,
  Iterable<Locale> supportedLocales,
) {
  final effective = _resolveSystemLocale(systemLocales);
  return supportedLocales.any((locale) => locale == effective)
      ? effective
      : simplifiedChineseLocale;
}

Locale _resolveSystemLocale(List<Locale>? systemLocales) {
  if (systemLocales == null || systemLocales.isEmpty) {
    return simplifiedChineseLocale;
  }

  final primary = systemLocales.first;
  return switch (primary.languageCode.toLowerCase()) {
    'en' => englishLocale,
    'zh' => simplifiedChineseLocale,
    _ => simplifiedChineseLocale,
  };
}

extension LocalePreferenceMaterialLocale on LocalePreference {
  Locale? get materialLocale => switch (this) {
        LocalePreference.followSystem => null,
        LocalePreference.simplifiedChinese => simplifiedChineseLocale,
        LocalePreference.english => englishLocale,
      };

  Locale effectiveLocale(List<Locale>? systemLocales) {
    return resolveEffectiveLocale(this, systemLocales);
  }
}
