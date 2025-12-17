// lib/screens/activity_screen.dart
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../main.dart' show currentUserId;
import 'chat_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late Future<List<Map<String, dynamic>>> _futureHelping;

  @override
  void initState() {
    super.initState();
    _futureHelping = ApiService.getHelpingRequests(currentUserId);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureHelping = ApiService.getHelpingRequests(currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureHelping,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(child: Text('Failed to load activity'));
            }

            final list = snap.data ?? [];
            if (list.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('You are not helping anyone yet')),
                ],
              );
            }

            // Take the first helping request (newest accepted)
            final data = list.first;
            final bool isAlarmOn = (data['is_alarm'] ?? false) as bool;
            final requester = data['created_by'] as String? ?? '';
            final title = data['description'] as String? ?? '';
            final requestId = data['id'] as int;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'You are helping $requester',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'For request: $title',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Open chat
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                requestId: requestId,
                                otherUserName: requester,
                                currentUserId: currentUserId,
                              ),
                            ),
                          );
                        },
                        child: const Text('Open chat'),
                      ),
                      const SizedBox(height: 16),

                      // Alarm + Disconnect row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(18),
                              backgroundColor: isAlarmOn
                                  ? Colors.red
                                  : colorScheme.primary,
                            ),
                            onPressed: () async {
                              final bool newState = !isAlarmOn;
                              await ApiService.setAlarm(requestId, newState);
                              await _refresh();
                            },
                            child: const Icon(
                              Icons.notifications_active_outlined,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 20),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.call_end),
                             label: const Text('Disconnect'),
                            onPressed: () async {
                              await ApiService.disconnectRequest(requestId);
                              await _refresh();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
