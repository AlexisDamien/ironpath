import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/body_composition.dart';
import '../providers/provider_bodymetrics.dart';

class FormComposition extends ConsumerStatefulWidget {
  final BodyComposition? compositionToEdit;

  const FormComposition({super.key, this.compositionToEdit});

  @override
  ConsumerState<FormComposition> createState() => _FormCompositionState();
}

class _FormCompositionState extends ConsumerState<FormComposition> {
  final _bodyFatController = TextEditingController();
  final _skeletalMuscleController = TextEditingController();
  final _fatFreeMassController = TextEditingController();
  final _subcutaneousFatController = TextEditingController();
  final _visceralFatController = TextEditingController();
  final _bodyWaterController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _boneMassController = TextEditingController();
  final _proteinController = TextEditingController();
  final _bmrController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.compositionToEdit != null) {
      final composition = widget.compositionToEdit!;
      _bodyFatController.text = composition.bodyFat?.toString() ?? '';
      _skeletalMuscleController.text =
          composition.skeletalMuscle?.toString() ?? '';
      _fatFreeMassController.text = composition.fatFreeMass?.toString() ?? '';
      _subcutaneousFatController.text =
          composition.subcutaneousFat?.toString() ?? '';
      _visceralFatController.text = composition.visceralFat?.toString() ?? '';
      _bodyWaterController.text = composition.bodyWater?.toString() ?? '';
      _muscleMassController.text = composition.muscleMass?.toString() ?? '';
      _boneMassController.text = composition.boneMass?.toString() ?? '';
      _proteinController.text = composition.protein?.toString() ?? '';
      _bmrController.text = composition.bmr?.toString() ?? '';
      _notesController.text = composition.notes ?? '';
    }
  }

  @override
  void dispose() {
    _bodyFatController.dispose();
    _skeletalMuscleController.dispose();
    _fatFreeMassController.dispose();
    _subcutaneousFatController.dispose();
    _visceralFatController.dispose();
    _bodyWaterController.dispose();
    _muscleMassController.dispose();
    _boneMassController.dispose();
    _proteinController.dispose();
    _bmrController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (widget.compositionToEdit != null) {
        await ref.read(providerBodyMetrics.notifier).updateComposition(
              compositionId: widget.compositionToEdit!.id,
              bodyFat: double.tryParse(_bodyFatController.text),
              skeletalMuscle: double.tryParse(_skeletalMuscleController.text),
              fatFreeMass: double.tryParse(_fatFreeMassController.text),
              subcutaneousFat: double.tryParse(_subcutaneousFatController.text),
              visceralFat: int.tryParse(_visceralFatController.text),
              bodyWater: double.tryParse(_bodyWaterController.text),
              muscleMass: double.tryParse(_muscleMassController.text),
              boneMass: double.tryParse(_boneMassController.text),
              protein: double.tryParse(_proteinController.text),
              bmr: int.tryParse(_bmrController.text),
              notes:
                  _notesController.text.isEmpty ? null : _notesController.text,
            );
      } else {
        await ref.read(providerBodyMetrics.notifier).saveComposition(
              bodyFat: double.tryParse(_bodyFatController.text),
              skeletalMuscle: double.tryParse(_skeletalMuscleController.text),
              fatFreeMass: double.tryParse(_fatFreeMassController.text),
              subcutaneousFat: double.tryParse(_subcutaneousFatController.text),
              visceralFat: int.tryParse(_visceralFatController.text),
              bodyWater: double.tryParse(_bodyWaterController.text),
              muscleMass: double.tryParse(_muscleMassController.text),
              boneMass: double.tryParse(_boneMassController.text),
              protein: double.tryParse(_proteinController.text),
              bmr: int.tryParse(_bmrController.text),
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
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
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
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(_bodyFatController, 'Masse grasse (%)',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                    _skeletalMuscleController, 'Muscle squelettique (%)',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    _fatFreeMassController, 'Masse maigre (kg)',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                    _subcutaneousFatController, 'Graisse sous-cutanée (%)',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    _visceralFatController, 'Graisse viscérale'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                    _bodyWaterController, 'Eau corporelle (%)',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    _muscleMassController, 'Masse musculaire (kg)',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                    _boneMassController, 'Masse osseuse (kg)',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_proteinController, 'Protéines (%)',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(_bmrController, 'BMR (kcal)'),
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
