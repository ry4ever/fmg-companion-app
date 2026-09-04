import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/athlete_user.dart';
import '../models/weekly_schedule.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class MyGymScreen extends ConsumerWidget {
  const MyGymScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final athleteAsync = ref.watch(athleteUserProvider);
    final weeklyAsync = ref.watch(weeklyScheduleProvider);
    final athleteUser = athleteAsync.value;
    final weeklySchedule = weeklyAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gym'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              ref.refresh(authStateProvider);
            },
          ),
        ],
      ),
      body: athleteUser == null
          ? const Center(child: Text('No user data'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(context, athleteUser),
                  const Divider(height: 32),
                  _buildArchetypeInfo(context, athleteUser),
                  const Divider(height: 32),
                  _buildWeeklySchedule(context, weeklySchedule),
                  const Divider(height: 32),
                  _buildConversationStarter(context, athleteUser),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AthleteUser user) {
    final bool shirtEligible = user.shirtEligibleFlag;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatCard(
          title: 'Streak',
          value: '${user.composureStreak} days',
          icon: Icons.fitness_center,
          color: Colors.purple,
          showBadge: shirtEligible,
          badgeText: shirtEligible ? '30+' : null,
        ),
        _StatCard(
          title: 'Sessions',
          value: 'Completed',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildArchetypeInfo(BuildContext context, AthleteUser user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Archetype: ${user.assignedArchetype}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildArchetypeDescription(context, user.assignedArchetype),
          ],
        ),
      ),
    );
  }

  Widget _buildArchetypeDescription(BuildContext context, String archetype) {
    final String description;
    switch (archetype) {
      case 'The Calm Operator':
        description = 'Active Sessions: Core — "Nerves = Performance" | Secondary — "Flow Trigger", "Play Your Next Game"';
        break;
      case 'The Resilient Bounceback':
        description = 'Active Sessions: Core — "Back To Your Best" | Secondary — "Empowered Thinking", "Enjoyment"';
        break;
      case 'The Sharp Decision-Maker':
        description = 'If Attacker: Core — "Ice Cold Finisher" | Secondary — "Better Final Ball"\nIf Midfielder: Core — "Better Final Ball" | Secondary — "Team Mate 6th Sense"\nIf Defender: Core — "Defending With Positive Aggression" | Secondary — "Sharpen Your Game"';
        break;
      case 'The Unshakable Competitor':
        description = 'Active Sessions: Core — "UNSHAKABLE" | Secondary — "Team Mate 6th Sense", "Play Your Next Game"';
        break;
      default:
        description = '';
    }
    return Text(
      description,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildWeeklySchedule(BuildContext context, WeeklySchedule? schedule) {
    if (schedule == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No schedule found'),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Training Plan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDayRow(context, 'Monday', schedule.days['monday'], Colors.blue),
            _buildDayRow(context, 'Tuesday', schedule.days['tuesday'], Colors.green),
            _buildDayRow(context, 'Wednesday', schedule.days['wednesday'], Colors.orange),
            _buildDayRow(context, 'Thursday', schedule.days['thursday'], Colors.red),
            _buildDayRow(context, 'Friday', schedule.days['friday'], Colors.teal),
            _buildDayRow(context, 'Saturday', schedule.days['saturday'], Colors.deepPurple),
            _buildDayRow(context, 'Sunday', schedule.days['sunday'], Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, String dayName, DailySchedule? day, Color color) {
    final isCompleted = day?.completed ?? false;
    final sessionId = day?.sessionId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isCompleted ? color : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                dayName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : null,
                ),
              ),
            ],
          ),
          if (sessionId != null && sessionId != 'rest_day' && sessionId.isNotEmpty)
            Text(
              sessionId,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
            )
          else
            const Text('Rest Day', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildConversationStarter(BuildContext context, AthleteUser user) {
    final String starter = _getConversationStarter(user.assignedArchetype);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversation Starter',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                starter,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getConversationStarter(String archetype) {
    switch (archetype) {
      case 'The Calm Operator':
        return 'How did your nerves affect your first rep this week?';
      case 'The Resilient Bounceback':
        return 'What was your favorite rep from your bounceback session?';
      case 'The Sharp Decision-Maker':
        return 'What was your best decision this week?';
      case 'The Unshakable Competitor':
        return 'How did you stay focused despite distractions?';
      default:
        return 'How was your training this week?';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool showBadge;
  final String? badgeText;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.showBadge = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final badge = showBadge && badgeText != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeText!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}