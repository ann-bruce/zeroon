import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const zeroonAppVersion = String.fromEnvironment(
  'ZEROON_APP_VERSION',
  defaultValue: '1.0.0',
);

class EvidencePreference {
  const EvidencePreference({
    required this.available,
    required this.enabled,
    required this.adultConfirmed,
    required this.requiredNoticeVersion,
    this.acceptedNoticeVersion,
    this.choiceChangedAt,
  });

  final bool available;
  final bool enabled;
  final bool adultConfirmed;
  final String requiredNoticeVersion;
  final String? acceptedNoticeVersion;
  final DateTime? choiceChangedAt;

  bool get requiresNotice =>
      !adultConfirmed || acceptedNoticeVersion != requiredNoticeVersion;

  factory EvidencePreference.fromJson(Map<String, dynamic> json) {
    return EvidencePreference(
      available: json['available'] as bool,
      enabled: json['enabled'] as bool,
      adultConfirmed: json['adultConfirmed'] as bool? ?? false,
      requiredNoticeVersion: json['requiredNoticeVersion'] as String,
      acceptedNoticeVersion: json['acceptedNoticeVersion'] as String?,
      choiceChangedAt: json['choiceChangedAt'] == null
          ? null
          : DateTime.parse(json['choiceChangedAt'] as String),
    );
  }
}

class EvidenceEvent {
  EvidenceEvent(
    this.eventName,
    Map<String, Object> properties, {
    DateTime? occurredAt,
    String? clientEventId,
  })  : properties = Map.unmodifiable(properties),
        occurredAt = occurredAt ?? DateTime.now(),
        clientEventId = clientEventId ?? _uuidV4();

  final String clientEventId;
  final String eventName;
  final DateTime occurredAt;
  final Map<String, Object> properties;

  Map<String, Object> toJson() => {
        'clientEventId': clientEventId,
        'eventName': eventName,
        'schemaVersion': 1,
        'occurredDate': shanghaiDate(occurredAt),
        ...properties,
      };
}

String evidencePlatform() {
  if (kIsWeb) return 'WEB';
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'IOS',
    TargetPlatform.android => 'ANDROID',
    _ => 'UNKNOWN',
  };
}

String shanghaiDate(DateTime value) {
  final shanghai = value.toUtc().add(const Duration(hours: 8));
  return '${shanghai.year.toString().padLeft(4, '0')}-'
      '${shanghai.month.toString().padLeft(2, '0')}-'
      '${shanghai.day.toString().padLeft(2, '0')}';
}

String durationBucket(Duration duration) {
  final seconds = duration.inSeconds;
  if (seconds < 10) return 'UNDER_10_SECONDS';
  if (seconds < 30) return 'FROM_10_TO_29_SECONDS';
  if (seconds < 60) return 'FROM_30_TO_59_SECONDS';
  if (seconds < 180) return 'FROM_1_TO_2_MINUTES';
  return 'OVER_2_MINUTES';
}

String latencyBucket(Duration duration) {
  final milliseconds = duration.inMilliseconds;
  if (milliseconds < 500) return 'UNDER_500_MS';
  if (milliseconds < 1500) return 'FROM_500_TO_1499_MS';
  if (milliseconds < 5000) return 'FROM_1500_TO_4999_MS';
  if (milliseconds < 15000) return 'FROM_5_TO_14_SECONDS';
  return 'OVER_15_SECONDS';
}

String retryCountBucket(int retries) {
  if (retries <= 0) return 'ZERO';
  if (retries == 1) return 'ONE';
  return 'TWO_OR_MORE';
}

String itemCountBucket(int count) {
  if (count <= 0) return 'EMPTY';
  if (count == 1) return 'ONE';
  if (count <= 5) return 'TWO_TO_FIVE';
  if (count <= 20) return 'SIX_TO_TWENTY';
  return 'OVER_TWENTY';
}

String recordAgeBucket(DateTime createdAt, {DateTime? now}) {
  final age = (now ?? DateTime.now()).difference(createdAt.toLocal()).inDays;
  if (age <= 0) return 'SAME_DAY';
  if (age <= 6) return 'ONE_TO_SIX_DAYS';
  if (age <= 28) return 'ONE_TO_FOUR_WEEKS';
  return 'OVER_FOUR_WEEKS';
}

EvidenceFailure classifyEvidenceFailure(Object error) {
  if (error is! DioException) {
    return const EvidenceFailure('UNKNOWN', false, 'UNKNOWN');
  }
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return const EvidenceFailure('TIMEOUT', true, 'TIMEOUT');
  }
  if (error.type == DioExceptionType.connectionError) {
    return const EvidenceFailure('NETWORK', true, 'OFFLINE');
  }
  final status = error.response?.statusCode;
  if (status == 401 || status == 403) {
    return const EvidenceFailure('AUTHORIZATION', false, 'ONLINE');
  }
  if (status == 409) {
    return const EvidenceFailure('CONFLICT', false, 'ONLINE');
  }
  if (status != null && status >= 400 && status < 500) {
    return EvidenceFailure(
      'VALIDATION',
      status == 408 || status == 429,
      'ONLINE',
    );
  }
  if (status != null && status >= 500) {
    return const EvidenceFailure('SERVER', true, 'ONLINE');
  }
  return const EvidenceFailure('UNKNOWN', false, 'UNKNOWN');
}

class EvidenceFailure {
  const EvidenceFailure(this.errorClass, this.retryable, this.networkStatus);

  final String errorClass;
  final bool retryable;
  final String networkStatus;
}

String _uuidV4() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex =
      bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}

final Random _random = Random.secure();
