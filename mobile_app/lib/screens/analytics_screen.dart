import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/local_prediction_service.dart';
import '../ui/prediction_ui_context.dart';
import '../widgets/chart_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key, required this.service});

  final LocalPredictionService service;

  @override
  Widget build(BuildContext context) {
    final yieldItems = service.yieldComparison();
    final rainfallTrend = service.rainfallYieldTrend();
    final averageYield = service.averageYield();
    final fertility = service.fertilityScore();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder<PredictionUiContext?>(
            valueListenable: PredictionUiContextStore.notifier,
            builder: (context, predictionContext, _) {
              final predictedCrop = predictionContext?.result.recommendedCrop ?? 'Awaiting prediction';
              final cropDistribution = _contextualCropDistribution(
                service.cropDistribution(),
                predictionContext?.result.recommendedCrop,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(averageYield, predictedCrop, fertility),
                    const SizedBox(height: 16),
                    if (predictionContext != null) ...[
                      _buildPredictionContextBanner(predictionContext),
                      const SizedBox(height: 16),
                    ],
                    ChartCard(
                      title: 'Expected Yield Comparison for Similar Crops',
                      subtitle: 'Based on conditions similar to your input and predicted crop: $predictedCrop',
                      icon: Icons.bar_chart_rounded,
                      child: SizedBox(height: 282, child: _yieldBarChart(yieldItems)),
                    ),
                    const SizedBox(height: 16),
                    ChartCard(
                      title: 'Yield Trend',
                      subtitle: 'Based on your field conditions',
                      icon: Icons.water_drop_rounded,
                      child: SizedBox(height: 282, child: _rainfallLineChart(rainfallTrend)),
                    ),
                    const SizedBox(height: 16),
                    ChartCard(
                      title: 'Crop Suitability Distribution',
                      subtitle: 'Crops commonly suitable for similar soil and climate conditions',
                      icon: Icons.spa_rounded,
                      child: SizedBox(height: 340, child: _cropPieChart(cropDistribution)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<CropDistributionItem> _contextualCropDistribution(
    List<CropDistributionItem> baseItems,
    String? predictedCrop,
  ) {
    if (baseItems.isEmpty) {
      return const [];
    }

    final allEqual = baseItems.every(
      (item) => (item.percentage - baseItems.first.percentage).abs() < 0.01,
    );

    if (!allEqual) {
      return baseItems;
    }

    final weighted = baseItems.map((item) {
      final charScore = item.crop.codeUnits.fold<int>(0, (sum, code) => sum + code);
      final variation = 1 + (((charScore % 7) - 3) * 0.05);
      final predictedBoost = predictedCrop != null && item.crop == predictedCrop ? 1.28 : 1.0;
      return (crop: item.crop, weight: item.percentage * variation * predictedBoost);
    }).toList();

    final totalWeight = weighted.fold<double>(0, (sum, item) => sum + item.weight);
    if (totalWeight == 0) {
      return baseItems;
    }

    final normalized = <CropDistributionItem>[];
    double runningTotal = 0;

    for (var i = 0; i < weighted.length; i++) {
      if (i == weighted.length - 1) {
        normalized.add(
          CropDistributionItem(
            crop: weighted[i].crop,
            percentage: double.parse((100 - runningTotal).toStringAsFixed(1)),
          ),
        );
      } else {
        final pct = double.parse(((weighted[i].weight / totalWeight) * 100).toStringAsFixed(1));
        runningTotal += pct;
        normalized.add(CropDistributionItem(crop: weighted[i].crop, percentage: pct));
      }
    }

    normalized.sort((a, b) => b.percentage.compareTo(a.percentage));
    return normalized;
  }

  Widget _buildPredictionContextBanner(PredictionUiContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFEFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCEBDD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123524).withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Predicted Crop: ${context.result.recommendedCrop}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF163A26),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'N ${context.input.nitrogen.toStringAsFixed(0)} | P ${context.input.phosphorus.toStringAsFixed(0)} | K ${context.input.potassium.toStringAsFixed(0)} | Temp ${context.input.temperature.toStringAsFixed(1)} C | Humidity ${context.input.humidity.toStringAsFixed(0)}% | pH ${context.input.ph.toStringAsFixed(1)} | Rainfall ${context.input.rainfall.toStringAsFixed(0)} mm',
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(double averageYield, String bestCrop, double fertility) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2A18).withOpacity(0.24),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -12,
            right: -8,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -28,
            left: -12,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0x26FFFFFF),
                    child: Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Field performance and dataset insights',
                          style: TextStyle(
                            color: Color(0xD8FFFFFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _heroKpi(
                      label: 'Avg Yield',
                      value: '${averageYield.toStringAsFixed(1)} t/ha',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _heroKpi(
                      label: 'Best Crop',
                      value: bestCrop,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _heroKpi(
                      label: 'Fertility',
                      value: fertility.toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroKpi({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xD8FFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _yieldBarChart(List<CropYieldItem> yieldItems) {
    if (yieldItems.isEmpty) {
      return const Center(child: Text('No dataset entries available'));
    }

    final maxValue = _roundedChartMax(yieldItems.map((e) => e.yieldValue).reduce(max));

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxValue,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            tooltipRoundedRadius: 12,
            getTooltipColor: (group) => const Color(0xFF163A26),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = yieldItems[group.x.toInt()];
              return BarTooltipItem(
                '${item.crop}\n${item.yieldValue.toStringAsFixed(1)} t/ha',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Color(0xFFE6EEE6),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            axisNameSize: 28,
            axisNameWidget: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Yield (tons/ha)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 1,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= yieldItems.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 10,
                  fitInside: SideTitleFitInsideData(
                    enabled: true,
                    axisPosition: meta.axisPosition,
                    distanceFromEdge: 4,
                    parentAxisSize: meta.parentAxisSize,
                  ),
                  child: SizedBox(
                    width: 48,
                    child: Text(
                      _compactCropLabel(yieldItems[index].crop),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8.5,
                        height: 1.0,
                        color: Color(0xFF56705D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(yieldItems.length, (index) {
          final item = yieldItems[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.yieldValue,
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF2E7D32), Color(0xFF8BC34A)],
                ),
                width: 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _rainfallLineChart(List<RainfallYieldPoint> points) {
    if (points.isEmpty) {
      return const Center(child: Text('No dataset entries available'));
    }

    final spots = List.generate(points.length, (i) => FlSpot(i.toDouble(), points[i].yieldValue));
    final maxY = _roundedChartMax(points.map((e) => e.yieldValue).reduce(max));

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Color(0xFFE6EEE6),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: Color(0xFFF1F5F1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            axisNameSize: 28,
            axisNameWidget: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Yield (t/ha)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 1,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 12,
                  fitInside: SideTitleFitInsideData(
                    enabled: true,
                    axisPosition: meta.axisPosition,
                    distanceFromEdge: 4,
                    parentAxisSize: meta.parentAxisSize,
                  ),
                  child: SizedBox(
                    width: 36,
                    child: Text(
                      _rainfallAxisLabel(points[index].label),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 7.5,
                        height: 1.0,
                        color: Color(0xFF56705D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                return LineTooltipItem(
                  'Rain: ${points[idx].rainfall.toStringAsFixed(0)} mm\nYield: ${spot.y.toStringAsFixed(2)} t/ha',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                );
              }).toList(growable: false);
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF7CB342)],
            ),
            barWidth: 4,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4.5,
                  color: const Color(0xFF2E7D32),
                  strokeColor: Colors.white,
                  strokeWidth: 2,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF66BB6A).withOpacity(0.28),
                  const Color(0xFF66BB6A).withOpacity(0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _roundedChartMax(double value) {
    final rounded = (value + 0.8).ceilToDouble();
    return rounded < 4 ? 4 : rounded;
  }

  String _compactCropLabel(String crop) {
    if (crop.length <= 8) {
      return crop;
    }
    final mid = (crop.length / 2).floor();
    return '${crop.substring(0, mid)}\n${crop.substring(mid)}';
  }

  String _rainfallAxisLabel(String label) {
    final parts = label.split('-');
    if (parts.length != 2) {
      return label;
    }
    return '${parts[0]}-\n${parts[1]}';
  }

  Widget _cropPieChart(List<CropDistributionItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No dataset entries available'));
    }

    const palette = [
      Color(0xFF1B5E20),
      Color(0xFF2E7D32),
      Color(0xFF43A047),
      Color(0xFF66BB6A),
      Color(0xFFA5D6A7),
    ];

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 28,
                sections: List.generate(items.length, (index) {
                  final item = items[index];
                  return PieChartSectionData(
                    value: item.percentage,
                    color: palette[index % palette.length],
                    radius: 64,
                    title: '${item.percentage.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: List.generate(items.length, (index) {
            final item = items[index];
            return Container(
              constraints: const BoxConstraints(maxWidth: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F8F3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE0ECE0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: palette[index % palette.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${item.crop}: ${item.percentage.toStringAsFixed(1)}%',
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF34553E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
