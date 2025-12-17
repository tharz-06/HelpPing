import 'package:flutter/material.dart';
import '../api_service.dart';
import 'chat_screen.dart';

class HelperActivityScreen extends StatefulWidget {
  const HelperActivityScreen({super.key});

  @override
  State<HelperActivityScreen> createState() => _HelperActivityScreenState();
}

class _HelperActivityScreenState extends State<HelperActivityScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getHelpingRequests('user2'); // helper
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService.getHelpingRequests('user2');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(child: Text('Failed to load status'));
            }

            final items = snap.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('You are not helping anyone yet')),
                ],
              );
            }

            final r = items.first;
            final requester = r['created_by'] as String? ?? '';
            final description = r['description'] as String? ?? '';
            final requestId = r['id'] as int;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('You are helping $requester'),
                      const SizedBox(height: 8),
                      Text('For request: $description'),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                requestId: requestId,
                                otherUserName: requester,
                                currentUserId: 'user2',
                              ),
                            ),
                          );
                        },
                        child: const Text('Open chat'),
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
