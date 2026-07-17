import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (widget.measurementToEdit != null) {
        await ref.read(providerBodyMetrics.notifier).updateMeasurement(
              measurementId: widget.measurementToEdit!.id,
              weight: double.tryParse(_weightController.text),
              chest: double.tryParse(_chestController.text),
              waist: double.tryParse(_waistController.text),
              hips: double.tryParse(_hipsController.text),
              leftArm: double.tryParse(_leftArmController.text),
              rightArm: double.tryParse(_rightArmController.text),
              leftThigh: double.tryParse(_leftThighController.text),
              rightThigh: double.tryParse(_rightThighController.text),
              leftCalf: double.tryParse(_leftCalfController.text),
              rightCalf: double.tryParse(_rightCalfController.text),
              notes:
                  _notesController.text.isEmpty ? null : _notesController.text,
            );
      } else {
        await ref.read(providerBodyMetrics.notifier).saveMeasurement(
              weight: double.tryParse(_weightController.text),
              chest: double.tryParse(_chestController.text),
              waist: double.tryParse(_waistController.text),
              hips: double.tryParse(_hipsController.text),
              leftArm: double.tryParse(_leftArmController.text),
              rightArm: double.tryParse(_rightArmController.text),
              leftThigh: double.tryParse(_leftThighController.text),
              rightThigh: double.tryParse(_rightThighController.text),
              leftCalf: double.tryParse(_leftCalfController.text),
              rightCalf: double.tryParse(_rightCalfController.text),
              notes:
                  _notesController.text.isEmpty ? null : _notesController.text,
            );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
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
    bool decimal = false,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: readOnly,
        fillColor: readOnly
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : null,
      ),
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : maxLines > 1
              ? TextInputType.multiline
              : TextInputType.number,
      maxLines: maxLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    final unitSystem = ref.watch(providerUnitSystem);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(_weightController, 'Poids (${unitSystem.weightUnit})',
              decimal: true),
          const SizedBox(height: 12),
          _buildTextField(
            _heightController,
            'Taille (${unitSystem.lengthUnit})',
            decimal: true,
            readOnly: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Mensurations',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(width: 8),
              Text(
                '(${unitSystem.lengthUnit})',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_chestController, 'Poitrine',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    _buildTextField(_waistController, 'Taille', decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child:
                    _buildTextField(_hipsController, 'Hanches', decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_leftArmController, 'Bras G',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(_rightArmController, 'Bras D',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_leftThighController, 'Cuisse G',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(_rightThighController, 'Cuisse D',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_leftCalfController, 'Mollet G',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(_rightCalfController, 'Mollet D',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(_notesController, 'Notes (optionnel)', maxLines: 2),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}
