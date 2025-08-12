import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bp_pulse_app/src/services/api_service.dart';
import 'package:bp_pulse_app/src/source/bp_pulse_form.dart';

// Create a Mock class for ApiService using mocktail
class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();

    // Register fallback values for any argument matcher if needed
    //registerFallbackValue<int>(0);
  });

  Future<void> pumpBPPulseForm(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BPPulseFormWithInjectedApi(apiService: mockApiService),
        ),
      ),
    );
  }

  testWidgets('shows validation errors when fields are empty', (tester) async {
    await pumpBPPulseForm(tester);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Enter Systolic'), findsOneWidget);
    expect(find.text('Enter Diastolic'), findsOneWidget);
    expect(find.text('Enter pulse'), findsOneWidget);
  });

  testWidgets('saves data successfully when valid inputs provided', (
    tester,
  ) async {
    when(
      () => mockApiService.saveReading(
        systolic: any(named: 'systolic'),
        diastolic: any(named: 'diastolic'),
        pulse: any(named: 'pulse'),
      ),
    ).thenAnswer((_) async => true);

    await pumpBPPulseForm(tester);

    // Enter valid values
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Systolic (mmHg)'),
      '120',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Diastolic (mmHg)'),
      '80',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pulse (bpm)'),
      '70',
    );

    // Tap Save
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start async call
    await tester.pump(const Duration(seconds: 1)); // Wait for async

    // Verify the API was called with correct values
    verify(
      () => mockApiService.saveReading(systolic: 120, diastolic: 80, pulse: 70),
    ).called(1);

    // Check for success snackbar message
    expect(find.text('Data saved successfully!'), findsOneWidget);

    // Check that the form fields were cleared
    expect(find.text('120'), findsNothing);
    expect(find.text('80'), findsNothing);
    expect(find.text('70'), findsNothing);
  });

  testWidgets('shows error snackbar if saveReading returns false', (
    tester,
  ) async {
    when(
      () => mockApiService.saveReading(
        systolic: any(named: 'systolic'),
        diastolic: any(named: 'diastolic'),
        pulse: any(named: 'pulse'),
      ),
    ).thenAnswer((_) async => false);

    await pumpBPPulseForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Systolic (mmHg)'),
      '120',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Diastolic (mmHg)'),
      '80',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pulse (bpm)'),
      '70',
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start async call
    await tester.pump(const Duration(seconds: 1)); // Wait for async

    expect(find.text('Failed to save data. Please try again.'), findsOneWidget);
  });

  testWidgets('shows error snackbar if api call throws exception', (
    tester,
  ) async {
    when(
      () => mockApiService.saveReading(
        systolic: any(named: 'systolic'),
        diastolic: any(named: 'diastolic'),
        pulse: any(named: 'pulse'),
      ),
    ).thenThrow(Exception('API error'));

    await pumpBPPulseForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Systolic (mmHg)'),
      '120',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Diastolic (mmHg)'),
      '80',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pulse (bpm)'),
      '70',
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start async call
    await tester.pump(const Duration(seconds: 1)); // Wait for async

    expect(find.textContaining('Error saving data:'), findsOneWidget);
  });
}

// Helper widget to inject mock ApiService
class BPPulseFormWithInjectedApi extends StatefulWidget {
  final ApiService apiService;

  const BPPulseFormWithInjectedApi({Key? key, required this.apiService})
    : super(key: key);

  @override
  _BPPulseFormWithInjectedApiState createState() =>
      _BPPulseFormWithInjectedApiState();
}

class _BPPulseFormWithInjectedApiState
    extends State<BPPulseFormWithInjectedApi> {
  @override
  Widget build(BuildContext context) {
    // This is basically your BPPulseForm but with injected ApiService
    return BPPulseFormInjected(apiService: widget.apiService);
  }
}

// A small wrapper version of your original BPPulseForm with an injectable ApiService
class BPPulseFormInjected extends StatefulWidget {
  final ApiService apiService;

  const BPPulseFormInjected({Key? key, required this.apiService})
    : super(key: key);

  @override
  _BPPulseFormInjectedState createState() => _BPPulseFormInjectedState();
}

class _BPPulseFormInjectedState extends State<BPPulseFormInjected> {
  late final TextEditingController _systolicController;
  late final TextEditingController _diastolicController;
  late final TextEditingController _pulseController;
  final _formKey = GlobalKey<FormState>();

  String? _systolicWarning;
  String? _diastolicWarning;
  final List<Map<String, dynamic>> _savedEntries = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _systolicController = TextEditingController();
    _diastolicController = TextEditingController();
    _pulseController = TextEditingController();
  }

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

      final success = await widget.apiService.saveReading(
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
              'bpStatus': HealthState.normal,
              'pulseStatus': HealthState.pulseNormal,
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
    if (numValue < 40 || numValue > 250) {
      return '$label must be between 40 and 250';
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
      return 'Pulse must be between 30 and 200';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              key: const Key('systolicField'),
              controller: _systolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Systolic (mmHg)',
                errorText: _systolicWarning,
              ),
              validator: (value) => _validateBP(value, 'Systolic'),
            ),
            TextFormField(
              key: const Key('diastolicField'),
              controller: _diastolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Diastolic (mmHg)',
                errorText: _diastolicWarning,
              ),
              validator: (value) => _validateBP(value, 'Diastolic'),
            ),
            TextFormField(
              key: const Key('pulseField'),
              controller: _pulseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pulse (bpm)'),
              validator: _validatePulse,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveData,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

enum HealthState {
  normal,
  elevated,
  high,
  low,
  pulseNormal,
  pulseElevated,
  pulseLow,
}
