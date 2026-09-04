import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  final int initialStep;
  const OnboardingScreen({super.key, required this.initialStep});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late int currentStep;
  late OnboardingService _service;

  // Selection States
  String? position;
  String? matchDayTarget;
  String? roadblock;
  String? trainingFrequency;
  String? competitiveLevel;

  @override
  void initState() {
    super.initState();
    currentStep = widget.initialStep;
    _service = OnboardingService();
  }

  void _nextStep() {
    if (currentStep < 4) {
      setState(() {
        currentStep++;
      });
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await _service.completeOnboarding(
      position: position,
      matchDayTarget: matchDayTarget,
      roadblock: roadblock,
      trainingFrequency: trainingFrequency,
      competitiveLevel: competitiveLevel,
    );
    // Navigate to /my-gym after completion
    context.go('/my-gym');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Setup Your Gym (Step ${currentStep + 1}/5)'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentStep == 0) _buildSelectionCard(
              "What is your position?",
              ["Attacker", "Midfielder", "Defender", "Goalkeeper"],
              position,
              (val) => position = val,
            ),
            if (currentStep == 1) _buildSelectionCard(
              "Match-Day Target?",
              ["Calm & Composed", "Sharp Decisions", "Fearless Play", "Unstoppable Focus"],
              matchDayTarget,
              (val) => matchDayTarget = val,
            ),
            if (currentStep == 2) _buildSelectionCard(
              "Primary Roadblock?",
              ["Pre-Match Nerves", "The Error Spiral", "The Form Slump", "Sideline Distractions"],
              roadblock,
              (val) => roadblock = val,
            ),
            if (currentStep == 3) _buildSelectionCard(
              "Weekly Frequency?",
              ["2 Days/Week", "3 Days/Week", "5 Days/Week"],
              trainingFrequency,
              (val) => trainingFrequency = val,
            ),
            if (currentStep == 4) _buildSelectionCard(
              "Competitive Level?",
              ["Grassroots", "Club-Travel", "Professional Academy"],
              competitiveLevel,
              (val) => competitiveLevel = val,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _nextStep,
              child: Text(currentStep == 4 ? 'Generate Routine ⚡' : 'Next Question'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(String question, List<String> options, String? selectedValue, void Function(String) onSelected) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selectedValue,
              onChanged: (val) {
                if (val != null) {
                  onSelected(val);
                  setState(() {});
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}