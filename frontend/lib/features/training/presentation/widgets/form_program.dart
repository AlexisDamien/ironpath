import 'package:flutter/material.dart';

class FormProgram extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const FormProgram({
    super.key,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom du programme',
            hintText: 'Ex: PPL, Full Body, Push...',
            prefixIcon: Icon(Icons.fitness_center),
          ),
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom est requis';
            }
            if (value.trim().length < 2) {
              return 'Le nom doit contenir au moins 2 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (optionnel)',
            hintText: 'Ex: Programme push pull legs 6 jours...',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
