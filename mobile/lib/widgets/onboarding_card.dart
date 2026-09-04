import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Reusable card for onboarding survey questions.
///
/// Displays a question with selectable options in a card layout.
class OnboardingCard extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onOptionSelected;

  const OnboardingCard({
    Key? key,
    required this.title,
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => RadioListTile<String>(
                  value: option,
                  groupValue: selectedOption,
                  title: Text(option),
                  onChanged: onOptionSelected,
                  dense: true,
                  activeColor: Theme.of(context).primaryColor,
                )),
          ],
        ),
      ),
    );
  }
}