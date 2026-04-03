import 'dart:math';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionInput {
  const PredictionInput({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.rainfall,
    required this.state,
    required this.area,
  });

  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double temperature;
  final double humidity;
  final double ph;
  final double rainfall;
  final String state;
  final double area;
}

class PredictionResult {
  const PredictionResult({
    required this.recommendedCrop,
    required this.yieldPerHectare,
    required this.totalProduction,
    required this.bestSeason,
  });

  final String recommendedCrop;
  final double yieldPerHectare;
  final double totalProduction;
  final String bestSeason;
}

class CropYieldItem {
  const CropYieldItem({required this.crop, required this.yieldValue});

  final String crop;
  final double yieldValue;
}

class RainfallYieldPoint {
  const RainfallYieldPoint({required this.label, required this.rainfall, required this.yieldValue});

  final String label;
  final double rainfall;
  final double yieldValue;
}

class CropDistributionItem {
  const CropDistributionItem({required this.crop, required this.percentage});

  final String crop;
  final double percentage;
}

class LocalPredictionService {
  LocalPredictionService._();

  static final LocalPredictionService instance = LocalPredictionService._();

  final List<Map<String, String>> _datasetRows = [];
  final List<String> _cropLabels = [
  'rice',
  'maize',
  'chickpea',
  'kidneybeans',
  'pigeonpeas',
  'mothbeans',
  'mungbean',
  'blackgram',
  'lentil',
  'pomegranate',
  'banana',
  'mango',
  'grapes',
  'watermelon',
  'muskmelon',
  'apple',
  'orange',
  'papaya',
  'coconut',
  'cotton',
  'jute',
  'coffee',
  ];

  Interpreter? _cropInterpreter;

  bool _initialized = false;

  final Map<String, int> _stateIndex = const {
    'Punjab': 0,
    'Haryana': 1,
    'Uttar Pradesh': 2,
    'Maharashtra': 3,
    'Karnataka': 4,
    'Tamil Nadu': 5,
    'West Bengal': 6,
    'Andhra Pradesh': 7,
  };

  final Map<String, String> _seasonMap = const {
    'rice': 'Kharif (June - October)',
    'maize': 'Kharif / Rabi',
    'chickpea': 'Rabi (October - March)',
    'kidneybeans': 'Kharif (June - September)',
    'pigeonpeas': 'Kharif (June - October)',
    'mothbeans': 'Kharif (June - September)',
    'mungbean': 'Kharif (June - September)',
    'blackgram': 'Kharif (June - September)',
    'lentil': 'Rabi (October - March)',

    'cotton': 'Kharif (June - November)',
    'jute': 'Kharif (March - May)',

    'banana': 'Year-round (Tropical)',
    'mango': 'Summer (March - June)',
    'grapes': 'Winter Harvest (Jan - Mar)',
    'orange': 'Winter (December - February)',
    'papaya': 'Year-round (Tropical)',
    'watermelon': 'Summer (February - May)',
    'muskmelon': 'Summer (February - May)',
    'apple': 'Temperate (September - November)',
    'pomegranate': 'Year-round (Tropical)',
    'coconut': 'Year-round (Tropical)',
    'coffee': 'October - March',
  };

  List<String> get availableStates => _stateIndex.keys.toList(growable: false);

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _loadDataset();
    await _loadModels();
    _initialized = true;
  }

  Future<void> _loadDataset() async {
    _datasetRows.clear();

    final csvRaw = await rootBundle.loadString('assets/dataset/crop_dataset.csv');
    final lines = csvRaw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.length < 2) {
      return;
    }

    final headers = lines.first.split(',').map((e) => e.trim()).toList(growable: false);

    for (final line in lines.skip(1)) {
      final values = line.split(',').map((e) => e.trim()).toList(growable: false);
      if (values.length != headers.length) {
        continue;
      }

      final row = <String, String>{};
      for (var i = 0; i < headers.length; i++) {
        row[headers[i]] = values[i];
      }
      _datasetRows.add(row);

    }
  }

  Future<void> _loadModels() async {
    try {
      _cropInterpreter = await Interpreter.fromAsset('assets/models/crop_model.tflite');
    } catch (_) {
      _cropInterpreter = null;
    }
  }

  Future<PredictionResult> predict(PredictionInput input) async {
    await initialize();

    final crop = _predictCrop(input);
    final yieldPerHectare = _predictYield(input, crop);
    final bestSeason = _seasonMap[crop] ?? 'Kharif (June - October)';

    final totalProduction = yieldPerHectare * input.area;

    return PredictionResult(
      recommendedCrop: crop,
      yieldPerHectare: yieldPerHectare,
      totalProduction: totalProduction,
      bestSeason: bestSeason,
    );
  }

  String _predictCrop(PredictionInput input) {
    final modelCrop = _predictCropFromModel(input);
    if (modelCrop != null) {
      return modelCrop;
    }

    final nearest = _nearestRows(input, 12);
    if (nearest.isEmpty) {
      return 'rice';
    }

    final votes = <String, int>{};
    for (final row in nearest) {
      final crop = row['label'] ?? 'rice';
      votes[crop] = (votes[crop] ?? 0) + 1;
    }

    return votes.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  double _predictYield(PredictionInput input, String crop) {
    final cropRows = _datasetRows.where((row) => (row['label'] ?? '') == crop).toList();
    if (cropRows.isEmpty) {
      return 4.0;
    }

    final yields = cropRows
        .map((row) => 3.0 + (double.tryParse(row['rainfall'] ?? '0') ?? 0) / 200)
        .where((v) => v > 0)
        .toList();

    if (yields.isEmpty) {
      return 4.0;
    }

    final baseYield = yields.reduce((a, b) => a + b) / yields.length;
    final rainfallFactor = _clamp(1 + ((input.rainfall - 100) / 600), 0.75, 1.25);
    final phFactor = _clamp(1 - (input.ph - 6.5).abs() * 0.05, 0.75, 1.1);
    final nutrientFactor = _clamp((input.nitrogen + input.phosphorus + input.potassium) / 180, 0.7, 1.3);

    final predicted = baseYield * rainfallFactor * phFactor * nutrientFactor;
    return double.parse(predicted.toStringAsFixed(2));
  }

  String? _predictCropFromModel(PredictionInput input) {
    if (_cropInterpreter == null || _cropLabels.isEmpty) {
      return null;
    }

    try {
      final features = _featureVector(input);
      final modelInput = [features];
      final output = List.generate(1, (_) => List<double>.filled(_cropLabels.length, 0));
      _cropInterpreter!.run(modelInput, output);

      var maxIdx = 0;
      var maxScore = output[0][0];
      for (var i = 1; i < output[0].length; i++) {
        if (output[0][i] > maxScore) {
          maxScore = output[0][i];
          maxIdx = i;
        }
      }

      return _cropLabels[maxIdx.clamp(0, _cropLabels.length - 1)];
    } catch (_) {
      return null;
    }
  }

  List<double> _featureVector(PredictionInput input) {
    return [
      input.nitrogen,
      input.phosphorus,
      input.potassium,
      input.temperature,
      input.humidity,
      input.ph,
      input.rainfall, 
    ];
  }

  List<Map<String, String>> _nearestRows(PredictionInput input, int k) {
    final scored = _datasetRows.map((row) {
      final distance = _rowDistance(row, input);
      return (distance: distance, row: row);
    }).toList();

    scored.sort((a, b) => a.distance.compareTo(b.distance));
    return scored.take(min(k, scored.length)).map((e) => e.row).toList(growable: false);
  }

  double _rowDistance(Map<String, String> row, PredictionInput input) {
    double diff(String key, double value, [double scale = 1]) {
      final rowValue = double.tryParse(row[key] ?? '0') ?? 0;
      return ((rowValue - value) / scale).abs();
    }

    return diff('N', input.nitrogen, 150) +
       diff('P', input.phosphorus, 120) +
       diff('K', input.potassium, 150) +
       diff('temperature', input.temperature, 40) +
       diff('humidity', input.humidity, 100) +
       diff('ph', input.ph, 14) +
       diff('rainfall', input.rainfall, 300);
  }
  double _clamp(double value, double minValue, double maxValue) {
    if (value < minValue) {
      return minValue;
    }
    if (value > maxValue) {
      return maxValue;
    }
    return value;
  }

  List<CropYieldItem> yieldComparison() {
    final byCrop = <String, List<double>>{};

    for (final row in _datasetRows) {
      final crop = row['label'] ?? '';
      final y = 3.0 + (double.tryParse(row['rainfall'] ?? '0') ?? 0) / 200;
      if (crop.isEmpty || y <= 0) {
        continue;
      }
      byCrop.putIfAbsent(crop, () => []).add(y);
    }

    final items = byCrop.entries
        .map((entry) => CropYieldItem(
              crop: entry.key,
              yieldValue: double.parse((entry.value.reduce((a, b) => a + b) / entry.value.length).toStringAsFixed(1)),
            ))
        .toList();

    items.sort((a, b) => b.yieldValue.compareTo(a.yieldValue));
    return items.take(5).toList(growable: false);
  }

  List<RainfallYieldPoint> rainfallYieldTrend() {
    final buckets = <String, List<double>>{};
    final rainPerBucket = <String, double>{};

    for (final row in _datasetRows) {
      final rain = double.tryParse(row['rainfall'] ?? '0') ?? 0;
      final y = 3.0 + rain / 200;
      if (rain <= 0 || y <= 0) {
        continue;
      }
      final bucketStart = (rain ~/ 40) * 40;
      final key = '${bucketStart.toInt()}-${(bucketStart + 40).toInt()}';
      buckets.putIfAbsent(key, () => []).add(y);
      rainPerBucket[key] = bucketStart + 20;
    }

    final points = buckets.entries.map((entry) {
      final avgYield = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return RainfallYieldPoint(
        label: entry.key,
        rainfall: rainPerBucket[entry.key] ?? 0,
        yieldValue: double.parse(avgYield.toStringAsFixed(2)),
      );
    }).toList();

    points.sort((a, b) => a.rainfall.compareTo(b.rainfall));
    return points;
  }

  List<CropDistributionItem> cropDistribution() {
    final counts = <String, int>{};
    for (final row in _datasetRows) {
      final crop = row['label'] ?? '';
      if (crop.isEmpty) {
        continue;
      }
      counts[crop] = (counts[crop] ?? 0) + 1;
    }

    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) {
      return const [];
    }

    final items = counts.entries
        .map((entry) => CropDistributionItem(
              crop: entry.key,
              percentage: double.parse(((entry.value / total) * 100).toStringAsFixed(1)),
            ))
        .toList();

    items.sort((a, b) => b.percentage.compareTo(a.percentage));
    return items.take(5).toList(growable: false);
  }

  double averageYield() {
    final yields = _datasetRows
        .map((row) => 3.0 + (double.tryParse(row['rainfall'] ?? '0') ?? 0) / 200)
        .where((y) => y > 0)
        .toList();

    if (yields.isEmpty) {
      return 0;
    }
    final avg = yields.reduce((a, b) => a + b) / yields.length;
    return double.parse(avg.toStringAsFixed(1));
  }

  CropYieldItem? bestCrop() {
    final items = yieldComparison();
    return items.isEmpty ? null : items.first;
  }

  double fertilityScore() {
    final n = _datasetRows.map((row) => double.tryParse(row['N'] ?? '0') ?? 0).toList();
    final p = _datasetRows.map((row) => double.tryParse(row['P'] ?? '0') ?? 0).toList();
    final k = _datasetRows.map((row) => double.tryParse(row['K'] ?? '0') ?? 0).toList();

    if (n.isEmpty || p.isEmpty || k.isEmpty) {
      return 0;
    }

    final avgN = n.reduce((a, b) => a + b) / n.length;
    final avgP = p.reduce((a, b) => a + b) / p.length;
    final avgK = k.reduce((a, b) => a + b) / k.length;

    final score = ((avgN + avgP + avgK) / 3) / 12;
    return double.parse(_clamp(score, 1, 10).toStringAsFixed(1));
  }
}
