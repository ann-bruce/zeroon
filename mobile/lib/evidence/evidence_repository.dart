import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'evidence_models.dart';

final evidenceRepositoryProvider = Provider<EvidenceRepository>(
  (ref) => EvidenceRepository(ref.watch(dioProvider)),
);

class EvidenceRepository {
  EvidenceRepository(
    this._dio, {
    int maxQueueSize = 50,
    Duration maxEventAge = const Duration(days: 7),
  })  : _maxQueueSize = maxQueueSize,
        _maxEventAge = maxEventAge;

  final Dio _dio;
  final int _maxQueueSize;
  final Duration _maxEventAge;
  final List<EvidenceEvent> _queue = [];
  bool _flushing = false;

  int get pendingCount => _queue.length;

  Future<EvidencePreference> getPreference() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/me/preferences/beta-evidence',
    );
    return EvidencePreference.fromJson(response.data!);
  }

  Future<EvidencePreference> updatePreference({
    required bool enabled,
    required bool adultConfirmed,
    required String noticeVersion,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/me/preferences/beta-evidence',
      data: {
        'enabled': enabled,
        'adultConfirmed': adultConfirmed,
        'noticeVersion': noticeVersion,
      },
    );
    return EvidencePreference.fromJson(response.data!);
  }

  Future<void> record(EvidenceEvent event) async {
    try {
      _dropExpired();
      if (_queue.length >= _maxQueueSize) {
        _queue.removeAt(0);
      }
      _queue.add(event);
      await flush();
    } catch (_) {
      // Evidence must never change a primary product-flow result.
    }
  }

  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      _dropExpired();
      while (_queue.isNotEmpty) {
        final event = _queue.first;
        try {
          final response = await _dio.post<Map<String, dynamic>>(
            '/evidence/events',
            data: event.toJson(),
          );
          final status = response.statusCode ?? 0;
          if (status >= 200 && status < 300) {
            _queue.removeAt(0);
            continue;
          }
          if (status >= 400 && status < 500 && status != 429) {
            _queue.removeAt(0);
            continue;
          }
          break;
        } on DioException catch (error) {
          final status = error.response?.statusCode;
          if (status != null &&
              status >= 400 &&
              status < 500 &&
              status != 429) {
            _queue.removeAt(0);
            continue;
          }
          break;
        } catch (_) {
          break;
        }
      }
    } finally {
      _flushing = false;
    }
  }

  void _dropExpired() {
    final cutoff = DateTime.now().subtract(_maxEventAge);
    _queue.removeWhere((event) => event.occurredAt.isBefore(cutoff));
  }
}
