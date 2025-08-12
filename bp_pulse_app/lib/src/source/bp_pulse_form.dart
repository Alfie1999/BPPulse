import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Your service to call backend API
import 'health_state.dart'; // Enum or class defining health states

// Stateful widget to create a form for recording Blood Pressure & Pulse
class BPPulseForm extends StatefulWidget {
  @override
  _BPPulseFormState createState() => _BPPulseFormState();
}

class _BPPulseFormState extends State<BPPulseForm> {
  final _formKey = GlobalKey<FormState>();

  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();

  final ApiService apiService = ApiService(
    baseUrl: 'http://localhost:5194/api',
  );

  String? _systolicWarning;
  String? _diastolicWarning;

  final List<Map<String, dynamic>> _savedEntries = [];

  bool _isSaving = false;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final systolic = int.parse(_systolicController.text);
      final diastolic = int.parse(_diastolicController.text);
      final pulse = int.parse(_pulseController.text);

      final success = await apiService.saveReading(
        systolic: systolic,
        diastolic: diastolic,
        pulse: pulse,
      );

      if (success) {
        setState(() {
          _savedEntries
            ..clear()
            ..add({
              'systolic': systolic,
              'diastolic': diastolic,
              'pulse': pulse,
              'bpStatus': _getBPHealthState(systolic, diastolic),
              'pulseStatus': _getPulseHealthState(pulse),
            });
          _systolicWarning = null;
          _diastolicWarning = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data saved successfully!')),
        );

        _formKey.currentState!.reset();
        _systolicController.clear();
        _diastolicController.clear();
        _pulseController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save data. Please try again.'),
          ),
        );
      }
    } catch (e) {
      // Catch parsing or API exceptions gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String? _validateBP(String? value, String label) {
    if (value == null || value.isEmpty) {
      return 'Enter $label';
    }
    final numValue = int.tryParse(value);
    if (numValue == null) {
      return '$label must be a number';
    }
    if (numValue <= 0) {
      return '$label must be greater than zero';
    }
    return null;
  }

  String? _validatePulse(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter pulse';
    }
    final numValue = int.tryParse(value);
    if (numValue == null) {
      return 'Pulse must be a number';
    }
    if (numValue < 30 || numValue > 200) {
      return 'Pulse seems unrealistic';
    }
    return null;
  }

  HealthState _getBPHealthState(int systolic, int diastolic) {
    if (systolic < 90 || diastolic < 60) {
      return HealthState.low;
    } else if ((systolic >= 90 && systolic <= 120) &&
        (diastolic >= 60 && diastolic <= 80)) {
      return HealthState.normal;
    } else if ((systolic > 120 && systolic <= 139) ||
        (diastolic > 80 && diastolic <= 89)) {
      return HealthState.prehypertension;
    } else if ((systolic >= 140 && systolic <= 159) ||
        (diastolic >= 90 && diastolic <= 99)) {
      return HealthState.hypertensionStage1;
    } else if (systolic >= 160 || diastolic >= 100) {
      return HealthState.hypertensionStage2;
    } else {
      return HealthState.unknown;
    }
  }

  HealthState _getPulseHealthState(int pulse) {
    if (pulse < 60) {
      return HealthState.pulseLow;
    } else if (pulse >= 60 && pulse <= 100) {
      return HealthState.pulseNormal;
    } else {
      return HealthState.pulseHigh;
    }
  }

  String _healthStateToText(HealthState state) {
    switch (state) {
      case HealthState.low:
        return 'BP Low (Hypotension)';
      case HealthState.normal:
        return 'BP Normal';
      case HealthState.critical:
        return 'BP critical';
      case HealthState.elevated:
        return 'BP elevated';
      case HealthState.bradycardia:
        return 'BP bradycardia';
      case HealthState.tachycardia:
        return 'BP tachycardia';
      case HealthState.prehypertension:
        return 'BP prehypertension';
      case HealthState.hypertensionStage1:
        return 'BP High (Stage 1 Hypertension)';
      case HealthState.hypertensionStage2:
        return 'BP High (Stage 2 Hypertension)';
      case HealthState.unknown:
        return 'Unknown';
      case HealthState.pulseLow:
        return 'Pulse Low';
      case HealthState.pulseNormal:
        return 'Pulse Normal';
      case HealthState.pulseHigh:
        return 'Pulse High';
    }
  }

  Color _healthStateToColor(HealthState state) {
    switch (state) {
      case HealthState.low:
      case HealthState.pulseLow:
        return Colors.blue;
      case HealthState.normal:
      case HealthState.pulseNormal:
        return Colors.green;
      case HealthState.prehypertension:
        return Colors.orange;
      case HealthState.hypertensionStage1:
      case HealthState.hypertensionStage2:
      case HealthState.elevated:
      case HealthState.pulseHigh:
      case HealthState.bradycardia:
      case HealthState.tachycardia:
      case HealthState.critical:
        return Colors.red;
      case HealthState.unknown:
        return Colors.grey;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    String? helperText,
    void Function(String)? onChanged,
    double width = 250,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          helperText: helperText,
          helperStyle: const TextStyle(color: Colors.orange),
          helperMaxLines: 3,
          errorMaxLines: 3,
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLastReadingDisplay() {
    if (_savedEntries.isEmpty) return const SizedBox.shrink();

    final lastEntry = _savedEntries.first;
    final bpStatus = lastEntry['bpStatus'] as HealthState;
    final pulseStatus = lastEntry['pulseStatus'] as HealthState;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Reading',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Blood Pressure: ${lastEntry['systolic']}/${lastEntry['diastolic']} mmHg',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Pulse: ${lastEntry['pulse']} bpm',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _healthStateToColor(bpStatus),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _healthStateToText(bpStatus),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _healthStateToColor(pulseStatus),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _healthStateToText(pulseStatus),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _checkWarnings() {
    setState(() {
      _systolicWarning = null;
      _diastolicWarning = null;

      final sText = _systolicController.text;
      final dText = _diastolicController.text;

      final sVal = int.tryParse(sText);
      final dVal = int.tryParse(dText);

      if (sVal != null && (sVal < 90 || sVal > 140)) {
        _systolicWarning = 'Systolic value out of normal range (90-140)';
      }
      if (dVal != null && (dVal < 60 || dVal > 90)) {
        _diastolicWarning = 'Diastolic value out of normal range (60-90)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record BP & Pulse')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _systolicController,
                  label: 'Systolic (mmHg)',
                  validator: (value) => _validateBP(value, 'Systolic'),
                  helperText: _systolicWarning,
                  onChanged: (_) => _checkWarnings(),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _diastolicController,
                  label: 'Diastolic (mmHg)',
                  validator: (value) => _validateBP(value, 'Diastolic'),
                  helperText: _diastolicWarning,
                  onChanged: (_) => _checkWarnings(),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _pulseController,
                  label: 'Pulse (bpm)',
                  validator: _validatePulse,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save'),
                  onPressed: _isSaving ? null : _saveData,
                ),
                const SizedBox(height: 24),
                _buildLastReadingDisplay(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
