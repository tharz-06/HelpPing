// lib/screens/requester_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../api_service.dart';
import '../main.dart' show currentUserId;
import 'chat_screen.dart';
import '../widgets/helper_profile_card.dart';

class RequesterActivityScreen extends StatefulWidget {
  const RequesterActivityScreen({super.key});

  @override
  State<RequesterActivityScreen> createState() =>
      _RequesterActivityScreenState();
}

class _RequesterActivityScreenState extends State<RequesterActivityScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _alarmAlreadyPlayed = false;

  late Future<Map<String, dynamic>?> _futureLatest;

  // controls rating vs empty state
  bool _showRatingCard = false;

  @override
  void initState() {
    super.initState();
    _futureLatest = ApiService.getLatestAccepted(currentUserId);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureLatest = ApiService.getLatestAccepted(currentUserId);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _showHelperProfileSheet(String helper) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: HelperProfileCard(
            name: helper,
            role: 'Trusted helper',
            rating: 4.5,      // TODO: load real rating
            ratingCount: 23,  // TODO: load real count
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await _refresh();
        },
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _futureLatest,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(child: Text('Failed to load activity'));
            }

            final data = snap.data;

            // 1) No active request
            if (data == null) {
              if (!_showRatingCard) {
                return ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(child: Text('No one is helping you yet')),
                  ],
                );
              }

              // rating card after disconnect
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 120),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Session finished',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'How was the help you received?',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star_border,
                                  size: 28, color: Colors.amber),
                              SizedBox(width: 6),
                              Icon(Icons.star_border,
                                  size: 28, color: Colors.amber),
                              SizedBox(width: 6),
                              Icon(Icons.star_border,
                                  size: 28, color: Colors.amber),
                              SizedBox(width: 6),
                              Icon(Icons.star_border,
                                  size: 28, color: Colors.amber),
                              SizedBox(width: 6),
                              Icon(Icons.star_border,
                                  size: 28, color: Colors.amber),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showRatingCard = false;
                              });
                            },
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // 3) There is an active accepted request → normal card
            final helper = data['helper_id'] as String? ?? '';
            final title = data['description'] as String? ?? '';
            final requestId = data['id'] as int;
            final bool isAlarmOn = (data['is_alarm'] ?? false) as bool;

            // Play sound once when alarm is ON (user1 side)
            if (isAlarmOn && !_alarmAlreadyPlayed) {
              print(
                  'Requester alarm ON for request $requestId, playing sound');
              _alarmAlreadyPlayed = true;
              _player.play(AssetSource('sounds/beep.wav'));
            } else if (!isAlarmOn && _alarmAlreadyPlayed) {
              print(
                  'Requester alarm OFF for request $requestId, resetting flag');
              _alarmAlreadyPlayed = false;
            }

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
                        'You are being helped by $helper',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          _showHelperProfileSheet(helper);
                        },
                        child: const Text('View helper profile'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'For request: $title',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Open chat (user1)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                requestId: requestId,
                                otherUserName: helper,
                                currentUserId: currentUserId,
                              ),
                            ),
                          );
                        },
                        child: const Text('Open chat'),
                      ),
                      const SizedBox(height: 16),

                      // Alarm icon (read-only) + Disconnect
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
                            onPressed: null,
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
                              setState(() {
                                _showRatingCard = true;
                                _futureLatest =
                                Future<Map<String, dynamic>?>.value(null);
                              });
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
