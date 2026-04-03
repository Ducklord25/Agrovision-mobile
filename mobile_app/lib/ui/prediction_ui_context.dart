import 'package:flutter/foundation.dart';

import '../services/local_prediction_service.dart';

class PredictionUiContext {
  const PredictionUiContext({
    required this.input,
    required this.result,
  });

  final PredictionInput input;
  final PredictionResult result;
}

class PredictionUiContextStore {
  PredictionUiContextStore._();

  static final ValueNotifier<PredictionUiContext?> notifier = ValueNotifier<PredictionUiContext?>(null);
}
