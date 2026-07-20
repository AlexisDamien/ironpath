import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/format_exception.dart';
import '../../../../core/utils/parse_input.dart';
import '../../domain/models/body_composition.dart';
import '../providers/provider_bodymetrics.dart';

class FormComposition extends ConsumerStatefulWidget {
  final BodyComposition? compositionToEdit;

  const FormComposition({super.key, this.compositionToEdit});

  @override
  ConsumerState<FormComposition> createState() => _FormCompositionState();
}

class _FormCompositionState extends ConsumerState<FormComposition> {
  final _formKey = GlobalKey<FormState>();
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

  String? _validateInteger(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null) {
      return 'Saisissez un nombre entier pour $label';
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
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      if (widget.compositionToEdit != null) {
        await ref
            .read(providerBodyMetrics.notifier)
            .updateComposition(
              compositionId: widget.compositionToEdit!.id,
              bodyFat: parseDecimal(_bodyFatController.text),
              skeletalMuscle: parseDecimal(_skeletalMuscleController.text),
              fatFreeMass: parseDecimal(_fatFreeMassController.text),
              subcutaneousFat: parseDecimal(_subcutaneousFatController.text),
              visceralFat: _visceralFatController.text.trim().isEmpty
                  ? null
                  : int.parse(_visceralFatController.text.trim()),
              bodyWater: parseDecimal(_bodyWaterController.text),
              muscleMass: parseDecimal(_muscleMassController.text),
              boneMass: parseDecimal(_boneMassController.text),
              protein: parseDecimal(_proteinController.text),
              bmr: _bmrController.text.trim().isEmpty
                  ? null
                  : int.parse(_bmrController.text.trim()),
              notes: notes,
            );
      } else {
        await ref
            .read(providerBodyMetrics.notifier)
            .saveComposition(
              bodyFat: parseDecimal(_bodyFatController.text),
              skeletalMuscle: parseDecimal(_skeletalMuscleController.text),
              fatFreeMass: parseDecimal(_fatFreeMassController.text),
              subcutaneousFat: parseDecimal(_subcutaneousFatController.text),
              visceralFat: _visceralFatController.text.trim().isEmpty
                  ? null
                  : int.parse(_visceralFatController.text.trim()),
              bodyWater: parseDecimal(_bodyWaterController.text),
              muscleMass: parseDecimal(_muscleMassController.text),
              boneMass: parseDecimal(_boneMassController.text),
              protein: parseDecimal(_proteinController.text),
              bmr: _bmrController.text.trim().isEmpty
                  ? null
                  : int.parse(_bmrController.text.trim()),
              notes: notes,
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
    bool integer = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: maxLines > 1
          ? TextInputType.multiline
          : TextInputType.numberWithOptions(decimal: !integer),
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      maxLines: maxLines,
      validator: maxLines > 1
          ? null
          : (value) => integer
                ? _validateInteger(value, label)
                : _validateDecimal(value, label),
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
            _buildPair(
              _buildTextField(_bodyFatController, 'Masse grasse (%)'),
              _buildTextField(
                _skeletalMuscleController,
                'Muscle squelettique (%)',
              ),
            ),
            const SizedBox(height: 12),
            _buildPair(
              _buildTextField(_fatFreeMassController, 'Masse maigre (kg)'),
              _buildTextField(
                _subcutaneousFatController,
                'Graisse sous-cutanée (%)',
              ),
            ),
            const SizedBox(height: 12),
            _buildPair(
              _buildTextField(
                _visceralFatController,
                'Graisse viscérale',
                integer: true,
              ),
              _buildTextField(_bodyWaterController, 'Eau corporelle (%)'),
            ),
            const SizedBox(height: 12),
            _buildPair(
              _buildTextField(_muscleMassController, 'Masse musculaire (kg)'),
              _buildTextField(_boneMassController, 'Masse osseuse (kg)'),
            ),
            const SizedBox(height: 12),
            _buildPair(
              _buildTextField(_proteinController, 'Protéines (%)'),
              _buildTextField(
                _bmrController,
                'Métabolisme de base (kcal)',
                integer: true,
              ),
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
              'Les champs sont facultatifs, mais toute valeur saisie doit être numérique et positive.',
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
