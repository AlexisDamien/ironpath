import 'package:flutter/material.dart';

class FormPassword extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController? confirmController;
  final bool showConfirm;
  final String label;
  final String? confirmLabel;

  const FormPassword({
    super.key,
    required this.controller,
    this.confirmController,
    this.showConfirm = true,
    this.label = 'Mot de passe',
    this.confirmLabel = 'Confirmer le mot de passe',
  });

  @override
  State<FormPassword> createState() => _FormPasswordState();
}

class _FormPasswordState extends State<FormPassword> {
  bool _obscure = true;
  bool _obscureConfirm = true;
  String _password = '';

  bool get _hasMinLength => _password.length >= 12;
  bool get _hasUppercase => _password.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _password.contains(RegExp(r'[a-z]'));
  bool get _hasDigit => _password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  int get _strength {
    int score = 0;
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

  Color get _strengthColor {
    return switch (_strength) {
      0 || 1 => Colors.red,
      2 => Colors.orange,
      3 => Colors.yellow.shade700,
      4 => Colors.lightGreen,
      5 => Colors.green,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          obscureText: _obscure,
          onChanged: (value) => setState(() => _password = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Mot de passe obligatoire';
            }
            if (!_hasMinLength) return 'Au moins 12 caractères requis';
            if (!_hasUppercase) return 'Au moins une majuscule requise';
            if (!_hasLowercase) return 'Au moins une minuscule requise';
            if (!_hasDigit) return 'Au moins un chiffre requis';
            if (!_hasSpecial) return 'Au moins un caractère spécial requis';
            return null;
          },
        ),
        if (_password.isNotEmpty) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _strength / 5,
              backgroundColor: Colors.grey.shade300,
              color: _strengthColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _strengthLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: _strengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_strength}/5',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCriteria(),
        ],
        if (widget.showConfirm && widget.confirmController != null) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.confirmController,
            decoration: InputDecoration(
              labelText: widget.confirmLabel,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            obscureText: _obscureConfirm,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirmation obligatoire';
              }
              if (value != widget.controller.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCriteria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCriteriaRow('Au moins 12 caractères', _hasMinLength),
        _buildCriteriaRow('Au moins une majuscule', _hasUppercase),
        _buildCriteriaRow('Au moins une minuscule', _hasLowercase),
        _buildCriteriaRow('Au moins un chiffre', _hasDigit),
        _buildCriteriaRow('Au moins un caractère spécial', _hasSpecial),
      ],
    );
  }

  Widget _buildCriteriaRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: met ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}