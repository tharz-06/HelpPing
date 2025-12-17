// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import '../api_service.dart';

class ChatScreen extends StatefulWidget {
  final int requestId;
  final String currentUserId;   // 'user1' or 'user2'
  final String otherUserName;   // name/id shown in AppBar

  const ChatScreen({
    super.key,
    required this.requestId,
    required this.currentUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Future<List<Map<String, dynamic>>> _futureMessages;

  @override
  void initState() {
    super.initState();
    print(
      'ChatScreen opened: requestId=${widget.requestId}, '
          'currentUserId=${widget.currentUserId}',
    );
    _futureMessages = ApiService.getMessages(widget.requestId);
  }

  Future<void> _refreshMessages() async {
    setState(() {
      _futureMessages = ApiService.getMessages(widget.requestId);
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await ApiService.sendMessage(
      requestId: widget.requestId,
      senderId: widget.currentUserId,
      text: text,
    );

    _controller.clear();
    await _refreshMessages();

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMessages,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureMessages,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return const Center(
                      child: Text('Failed to load messages'),
                    );
                  }

                  final msgs = snap.data ?? [];

                  if (msgs.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('Say hi to start the chat')),
                      ],
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      final m = msgs[index];
                      final from = m['sender_id'] as String? ?? '';
                      final text = m['message'] as String? ?? '';
                      final ts = m['created_at'] as String? ?? '';
                      final isMe = from == widget.currentUserId;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? colorScheme.primaryContainer
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(text),
                              const SizedBox(height: 4),
                              Text(
                                ts,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
