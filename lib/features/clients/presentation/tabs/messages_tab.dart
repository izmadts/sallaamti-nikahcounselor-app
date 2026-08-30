import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/theme/matchmaker_theme.dart';
import '../client_list_screen.dart';

class _Message {
  final int id;
  final String message;
  final bool isMine;
  final String? senderName;
  final DateTime createdAt;
  _Message({required this.id, required this.message, required this.isMine, this.senderName, required this.createdAt});

  factory _Message.fromJson(Map<String, dynamic> json) => _Message(
        id: json['id'] as int,
        message: json['message'] as String,
        isMine: json['is_mine'] as bool? ?? false,
        senderName: json['sender_name'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

// Counselor's side of the client<->counselor channel — same endpoints the
// member app's "Message my counselor" screen uses
// (Api\V1\NikahHireCounselorController::messages()/sendMessage()), so a
// conversation started from either side shows up on both.
class MessagesTab extends ConsumerStatefulWidget {
  final int leadId;
  const MessagesTab({super.key, required this.leadId});

  @override
  ConsumerState<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends ConsumerState<MessagesTab> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  List<_Message> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(clientRepositoryProvider);
      final data = await repo.messages(widget.leadId);
      setState(() => _messages = (data['messages'] as List).map((e) => _Message.fromJson(Map<String, dynamic>.from(e as Map))).toList());
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final repo = ref.read(clientRepositoryProvider);
      final data = await repo.sendMessage(widget.leadId, text);
      final message = _Message.fromJson(Map<String, dynamic>.from(data['message'] as Map));
      setState(() => _messages = [..._messages, message]);
      _textController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.displayMessage)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not send — try again.')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildBody(context)),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(hintText: 'Type a message…', isDense: true),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: _sending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send),
                  onPressed: _sending ? null : _send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: MatchmakerTheme.plum));
    }

    if (_error != null && _messages.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)));
    }

    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('No messages yet.', style: TextStyle(color: Colors.grey.shade600)),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final m = _messages[index];
        return Align(
          alignment: m.isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: m.isMine ? MatchmakerTheme.plum : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(m.message, style: TextStyle(color: m.isMine ? Colors.white : Colors.black87)),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d MMM, h:mm a').format(m.createdAt.toLocal()),
                  style: TextStyle(fontSize: 10, color: m.isMine ? Colors.white70 : Colors.grey.shade500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
