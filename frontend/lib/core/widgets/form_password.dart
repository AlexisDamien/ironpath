import 'package:flutter/material.dart';

class FormPassword extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController? confirmController;
  final bool showConfirm;
  final String label;
  final String? confirmLabel;
  final FormFieldValidator<String>? validator;
  final FormFieldValidator<String>? confirmValidator;
  final AutovalidateMode autovalidateMode;

  const FormPassword({
    super.key,
    required this.controller,
    this.confirmController,
    this.showConfirm = true,
    this.label = 'Mot de passe',
    this.confirmLabel = 'Confirmer le mot de passe',
    this.validator,
    this.confirmValidator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<FormPassword> createState() => _FormPasswordState();
}

class _FormPasswordState extends State<FormPassword> {
  bool _obscure = true;
  bool _obscureConfirm = true;
  late String _password;

  bool get _hasMinLength => _password.length >= 12;
  bool get _hasUppercase => _password.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _password.contains(RegExp(r'[a-z]'));
  bool get _hasDigit => _password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  int get _strength {
    var score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasDigit) score++;
    if (_hasSpecial) score++;
    return score;
  }

  String get _strengthLabel {
    return switch (_strength) {
      0 || 1 => 'Très faible',
      2 => 'Faible',
      3 => 'Moyen',
      4 => 'Fort',
      5 => 'Très fort',
      _ => '',
    };
  }

  @override
  void initState() {
    super.initState();
    _password = widget.controller.text;
  }

  @override
  void didUpdateWidget(covariant FormPassword oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _password = widget.controller.text;
    }
  }

  String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    if (value.length < 12) {
      return 'Utilisez au moins 12 caractères';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Ajoutez au moins une majuscule';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Ajoutez au moins une minuscule';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Ajoutez au moins un chiffre';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Ajoutez au moins un caractère spécial';
    }
    return null;
  }

  String? _defaultConfirmValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmez le mot de passe';
    }
    if (value != widget.controller.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  Color _strengthColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (_strength) {
      0 || 1 => colorScheme.error,
      2 => colorScheme.error,
      3 => colorScheme.primary,
      4 => colorScheme.primary,
      5 => colorScheme.primary,
      _ => colorScheme.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strengthColor = _strengthColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.label,
            helperText: '12 caractères minimum avec majuscule, minuscule, '
                'chiffre et caractère spécial',
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              tooltip: _obscure
                  ? 'Afficher le mot de passe'
                  : 'Masquer le mot de passe',
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          obscureText: _obscure,
          autofillHints: const [AutofillHints.newPassword],
          autovalidateMode: widget.autovalidateMode,
          validator: widget.validator ?? _defaultPasswordValidator,
          onChanged: (value) => setState(() => _password = value),
        ),
        if (_password.isNotEmpty) ...[
          const SizedBox(height: 8),
          Semantics(
            container: true,
            liveRegion: true,
            label: 'Force du mot de passe',
            value: '$_strengthLabel, $_strength critères sur 5 respectés',
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _strength / 5,
                      backgroundColor: colorScheme.outlineVariant,
                      color: strengthColor,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _strength >= 4
                                ? Icons.verified_outlined
                                : Icons.info_outline,
                            size: 16,
                            color: strengthColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$_strength/5',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildCriteria(context),
        ],
        if (widget.showConfirm && widget.confirmController != null) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.confirmController,
            decoration: InputDecoration(
              labelText: widget.confirmLabel,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                tooltip: _obscureConfirm
                    ? 'Afficher le mot de passe'
                    : 'Masquer le mot de passe',
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            obscureText: _obscureConfirm,
            autofillHints: const [AutofillHints.newPassword],
            autovalidateMode: widget.autovalidateMode,
            validator: widget.confirmValidator ?? _defaultConfirmValidator,
          ),
        ],
      ],
    );
  }

  Widget _buildCriteria(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Critères du mot de passe',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCriteriaRow(context, 'Au moins 12 caractères', _hasMinLength),
          _buildCriteriaRow(context, 'Au moins une majuscule', _hasUppercase),
          _buildCriteriaRow(context, 'Au moins une minuscule', _hasLowercase),
          _buildCriteriaRow(context, 'Au moins un chiffre', _hasDigit),
          _buildCriteriaRow(
            context,
            'Au moins un caractère spécial',
            _hasSpecial,
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaRow(BuildContext context, String label, bool met) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = met ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Semantics(
      label: '$label : ${met ? 'respecté' : 'non respecté'}',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                met ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: iconColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface,
                    fontWeight: met ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
