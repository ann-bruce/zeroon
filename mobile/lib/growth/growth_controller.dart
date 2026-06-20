import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'growth_models.dart';
import 'growth_repository.dart';

final growthSummaryProvider = FutureProvider<GrowthSummary>((ref) {
  return ref.watch(growthRepositoryProvider).getSummary();
});

final statePatternSummaryProvider = FutureProvider<StatePatternSummary>((ref) {
  return ref.watch(growthRepositoryProvider).getStatePattern();
});
