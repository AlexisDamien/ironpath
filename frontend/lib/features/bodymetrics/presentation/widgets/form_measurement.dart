import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/format_exception.dart';
import '../../../../core/utils/parse_input.dart';
import '../../../../core/providers/provider_enums.dart';
import '../../domain/models/body_measurement.dart';
import '../providers/provider_bodymetrics.dart';
import '../../../profile/presentation/providers/provider_profile.dart';

class FormMeasurement extends ConsumerStatefulWidget {
  final BodyMeasurement? measurementToEdit;

  const FormMeasurement({super.key, this.measurementToEdit});

  @override
  ConsumerState<FormMeasurement> createState() => _FormMeasurementState();
}

class _FormMeasurementState extends ConsumerState<FormMeasurement> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _leftArmController = TextEditingController();
  final _rightArmController = TextEditingController();
  final _leftThighController = TextEditingController();
  final _rightThighController = TextEditingController();
  final _leftCalfController = TextEditingController();
  final _rightCalfController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.measurementToEdit != null) {
      final measurement = widget.measurementToEdit!;
      _weightController.text = measurement.weight?.toString() ?? '';
      _chestController.text = measurement.chest?.toString() ?? '';
      _waistController.text = measurement.waist?.toString() ?? '';
      _hipsController.text = measurement.hips?.toString() ?? '';
      _leftArmController.text = measurement.leftArm?.toString() ?? '';
      _rightArmController.text = measurement.rightArm?.toString() ?? '';
      _leftThighController.text = measurement.leftThigh?.toString() ?? '';
      _rightThighController.text = measurement.rightThigh?.toString() ?? '';
      _leftCalfController.text = measurement.leftCalf?.toString() ?? '';
      _rightCalfController.text = measurement.rightCalf?.toString() ?? '';
      _notesController.text = measurement.notes ?? '';
    }

    Future.microtask(() {
      final profile = ref.read(providerProfile).profile;
      if (profile?.height != null && widget.measurementToEdit == null) {
        _heightController.text = profile!.height.toString();
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _leftArmController.dispose();
    _rightArmController.dispose();
    _leftThighController.dispose();
    _rightThighController.dispose();
    _leftCalfController.dispose();
    _rightCalfController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateDecimal(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = parseDecimal(text);
    if (parsed == null) {
      return 'Saisissez un nombre valide pour $label';
    }
    if (parsed < 0) {
      return '$label ne peut pas être négatif';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      if (widget.measurementToEdit != null) {
        await ref.read(providerBodyMetrics.notifier).updateMeasurement(
              measurementId: widget.measurementToEdit!.id,
              weight: parseDecimal(_weightController.text),
              chest: parseDecimal(_chestController.text),
              waist: parseDecimal(_waistController.text),
              hips: parseDecimal(_hipsController.text),
              leftArm: parseDecimal(_leftArmController.text),
              rightArm: parseDecimal(_rightArmController.text),
              leftThigh: parseDecimal(_leftThighController.text),
              rightThigh: parseDecimal(_rightThighController.text),
              leftCalf: parseDecimal(_leftCalfController.text),
              rightCalf: parseDecimal(_rightCalfController.text),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );
      } else {
        await ref.read(providerBodyMetrics.notifier).saveMeasurement(
              weight: parseDecimal(_weightController.text),
              chest: parseDecimal(_chestController.text),
              waist: parseDecimal(_waistController.text),
              hips: parseDecimal(_hipsController.text),
              leftArm: parseDecimal(_leftArmController.text),
              rightArm: parseDecimal(_rightArmController.text),
              leftThigh: parseDecimal(_leftThighController.text),
              rightThigh: parseDecimal(_rightThighController.text),
              leftCalf: parseDecimal(_leftCalfController.text),
              rightCalf: parseDecimal(_rightCalfController.text),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline),
                const SizedBox(width: 8),
                Expanded(child: Text(formatExceptionMessage(exception))),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: readOnly
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : null,
      ),
      keyboardType: maxLines > 1
          ? TextInputType.multiline
          : const TextInputType.numberWithOptions(decimal: true),
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      maxLines: maxLines,
      validator: readOnly || maxLines > 1
          ? null
          : (value) => _validateDecimal(value, label),
    );
  }

  Widget _buildPair(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final useColumn = constraints.maxWidth < 480 || textScale > 1.3;
        if (useColumn) {
          return Column(children: [first, const SizedBox(height: 12), second]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unitSystem = ref.watch(providerUnitSystem);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              _weightController,
              'Poids (${unitSystem.weightUnit})',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _heightController,
              'Taille (${unitSystem.lengthUnit})',
              readOnly: true,
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                'Mensurations (${unitSystem.lengthUnit})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildPair(
              _buildTextField(_chestController, 'Poitrine'),
              _buildTextField(_waistController, 'Tour de taille'),
            ),
            const SizedBox(height: 12),
            _buildTextField(_hipsController, 'Hanches'),
            const SizedBox(height: 12),
            _buildPair(
              _buildTextField(_leftArmController, 'Bras gauche'),
              _buildTextField(_rightArmController, 'Bras droit'),
            ),
            const SizedBox(height: 12),
            _buildPair(
              _buildTextField(_leftThighController, 'Cuisse gauche'),
              _buildTextField(_rightThighController, 'Cuisse droite'),
            ),
            const SizedBox(height: 12),
            _buildPair(
              _buildTextField(_leftCalfController, 'Mollet gauche'),
              _buildTextField(_rightCalfController, 'Mollet droit'),
            ),
            const SizedBox(height: 12),
            _buildTextField(_notesController, 'Notes (optionnel)', maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? Semantics(
                        label: 'Enregistrement en cours',
                        child: const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Text('Enregistrer'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les champs de mesure sont facultatifs, mais toute valeur saisie doit être numérique et positive.',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
