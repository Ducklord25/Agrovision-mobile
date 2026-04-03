import 'package:flutter/material.dart';

import '../services/local_prediction_service.dart';
import '../ui/prediction_ui_context.dart';
import '../widgets/input_card.dart';
import '../widgets/result_card.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key, required this.service});

  final LocalPredictionService service;

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  static const List<String> _indianStatesAndUts = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _areaController = TextEditingController();

  String? _selectedState;
  bool _isLoading = false;
  PredictionResult? _result;

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    final nitrogen = double.tryParse(_nitrogenController.text.trim());
    final phosphorus = double.tryParse(_phosphorusController.text.trim());
    final potassium = double.tryParse(_potassiumController.text.trim());
    final temperature = double.tryParse(_temperatureController.text.trim());
    final humidity = double.tryParse(_humidityController.text.trim());
    final ph = double.tryParse(_phController.text.trim());
    final rainfall = double.tryParse(_rainfallController.text.trim());
    final area = double.tryParse(_areaController.text.trim());

    if ([nitrogen, phosphorus, potassium, temperature, humidity, ph, rainfall, area].any((v) => v == null) ||
        _selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields with valid numeric values.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final predictionInput = PredictionInput(
      nitrogen: nitrogen!,
      phosphorus: phosphorus!,
      potassium: potassium!,
      temperature: temperature!,
      humidity: humidity!,
      ph: ph!,
      rainfall: rainfall!,
      state: _selectedState!,
      area: area!,
    );

    final result = await widget.service.predict(predictionInput);

    if (!mounted) {
      return;
    }

    PredictionUiContextStore.notifier.value = PredictionUiContext(
      input: predictionInput,
      result: result,
    );

    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(),
                const SizedBox(height: 16),
                _buildFormCard(),
                if (_result != null) ...[
                  const SizedBox(height: 16),
                  _buildResultsSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2A18).withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -18,
            right: -10,
            child: Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -24,
            left: -14,
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0x26FFFFFF),
                    child: Icon(Icons.eco, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AgroVision',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Smart agriculture insights for the field',
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
              SizedBox(height: 16),
              Text(
                'Crop recommendation, season planning, and yield guidance in one clean workflow.',
                style: TextStyle(
                  color: Color(0xF0FFFFFF),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              _buildInsightStrip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightStrip() {
    return Row(
      children: const [
        Expanded(
          child: _HeroMetric(
            icon: Icons.spa_outlined,
            label: 'Crop Match',
            value: 'Offline AI',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _HeroMetric(
            icon: Icons.cloud_outlined,
            label: 'Season Plan',
            value: 'On-device',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _HeroMetric(
            icon: Icons.bar_chart_rounded,
            label: 'Yield View',
            value: 'Instant',
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFC),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123524).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Soil & Climate Parameters',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF163A26),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter field conditions to generate crop, season, yield, and production insights.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildFormGrid(),
          const SizedBox(height: 16),
          _buildStateField(),
          const SizedBox(height: 16),
          InputCard(
            label: 'Area of Land - hectares',
            controller: _areaController,
            hintText: 'e.g., 2.5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF174D2A), Color(0xFF43A047)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B5E20).withOpacity(0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _predict,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Predict Crop Insights',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InputCard(
                label: 'Nitrogen (N) - kg/ha',
                controller: _nitrogenController,
                hintText: 'e.g., 90',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputCard(
                label: 'Phosphorus (P) - kg/ha',
                controller: _phosphorusController,
                hintText: 'e.g., 42',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InputCard(
                label: 'Potassium (K) - kg/ha',
                controller: _potassiumController,
                hintText: 'e.g., 43',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputCard(
                label: 'Temperature - C',
                controller: _temperatureController,
                hintText: 'e.g., 25.5',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InputCard(
                label: 'Humidity - %',
                controller: _humidityController,
                hintText: 'e.g., 80',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputCard(
                label: 'Soil pH',
                controller: _phController,
                hintText: 'e.g., 6.5',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InputCard(
          label: 'Rainfall - mm',
          controller: _rainfallController,
          hintText: 'e.g., 203.5',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildStateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'State',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6FAF6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDDECDD)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F3D22).withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedState,
            menuMaxHeight: 320,
            borderRadius: BorderRadius.circular(20),
            isExpanded: true,
            items: _indianStatesAndUts
                .map((state) => DropdownMenuItem<String>(
                      value: state,
                      child: Text(
                        state,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF123524),
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(growable: false),
            onChanged: (value) {
              setState(() {
                _selectedState = value;
              });
            },
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2E7D32)),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Select State',
              hintStyle: const TextStyle(
                color: Color(0xFF7B8B7E),
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                color: const Color(0xFF123524).withOpacity(0.22),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prediction Results',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your field-ready crop insights are available below.',
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.spa_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Predicted Crop',
                          style: TextStyle(
                            color: Color(0xD8FFFFFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result!.recommendedCrop.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ResultChip(
                          icon: Icons.calendar_month_rounded,
                          label: _result!.bestSeason,
                        ),
                        _ResultChip(
                          icon: Icons.water_drop_rounded,
                          label: '${_result!.yieldPerHectare.toStringAsFixed(2)} t/ha',
                        ),
                        _ResultChip(
                          icon: Icons.agriculture_rounded,
                          label: '${_result!.totalProduction.toStringAsFixed(2)} t',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ResultCard(
                title: 'Season',
                value: _result!.bestSeason,
                icon: Icons.calendar_month_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ResultCard(
                title: 'Yield',
                value: '${_result!.yieldPerHectare.toStringAsFixed(2)} tons/ha',
                icon: Icons.water_drop_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ResultCard(
          title: 'Production',
          value: '${_result!.totalProduction.toStringAsFixed(2)} tons total output',
          icon: Icons.agriculture_rounded,
        ),
      ],
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCEBDD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123524).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF163A26),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
