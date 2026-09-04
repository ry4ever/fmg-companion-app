import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/athlete_user.dart';
import '../models/weekly_schedule.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'session_player_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final athleteAsync = ref.watch(athleteUserProvider);
    final weeklyAsync = ref.watch(weeklyScheduleProvider);
    final athleteUser = athleteAsync.value;
    final weeklySchedule = weeklyAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              // Force re-evaluation of auth state
              ref.refresh(authStateProvider);
            },
          ),
        ],
      ),
      body: athleteUser == null
          ? const Center(child: Text('No user data'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileCard(athleteUser),
                const SizedBox(height: 20),
                _buildStreakCard(athleteUser),
                const SizedBox(height: 20),
                _buildWeeklyScheduleCard(weeklySchedule),
                const SizedBox(height: 20),
                _buildArchetypeCard(athleteUser),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start Today's Session"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  onPressed: () {
                    // For now, start a demo session. In production, this would
                    // come from the weekly schedule for today.
                    // TODO: Get actual session from weeklySchedule
                    final athleteUid = ref.watch(athleteUserProvider).value?.uid;
                    if (athleteUid != null) {
                      // Example: start the core session for the athlete's archetype
                      // In a real implementation, this would be selected based on today's day-of-week
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SessionPlayerScreen(
                            athleteUid: athleteUid,
                            sessionId: 'session_nerves_equal_performance', // TODO: dynamic
                            sessionName: 'Nerves = Performance',
                            targetDurationSeconds: 300, // 5 minutes
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AthleteUser user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.fitness_center, size: 16, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  user.assignedArchetype,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, AthleteUser user) {
    final bool isShirtEligible = user.shirtEligibleFlag;
    final String streakStatus = AppStrings.getStreakStatus(user.composureStreak);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isShirtEligible ? Icons.emoji_events : Icons.fitness_center,
              size: 32,
              color: isShirtEligible ? Colors.amber : Colors.purple,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streakStatus,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last completed: ${user.lastCompletedTimestamp.isNotEmpty ? user.lastCompletedTimestamp : 'Never'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isShirtEligible)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SHIRT ELIGIBLE!',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyScheduleCard(BuildContext context, WeeklySchedule? schedule) {
    if (schedule == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No weekly schedule found'),
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
              "This Week's Schedule",
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
          if (sessionId != null && sessionId.isNotEmpty && sessionId != 'rest_day')
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

  Widget _buildArchetypeCard(BuildContext context, AthleteUser user) {
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
            Text(
              _getArchetypeDescription(user.assignedArchetype),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _getArchetypeDescription(String archetype) {
    switch (archetype) {
      case 'The Calm Operator':
        return 'Channel nerves into performance. Stay calm under pressure.';
      case 'The Resilient Bounceback':
        return 'Recover quickly from mistakes. Turn setbacks into comebacks.';
      case 'The Sharp Decision-Maker':
        return 'Make quick, accurate decisions under pressure.';
      case 'The Unshakable Competitor':
        return 'Maintain focus despite distractions. Push through adversity.';
      default:
        return '';
    }
  }
}