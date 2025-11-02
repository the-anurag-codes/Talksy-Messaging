import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/empty_messages_widget.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start chat when page loads
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      context.read<ChatBloc>().add(
        ChatStarted(
          userId: authState.user!.id,
          otherUserId: widget.otherUserId,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.status == ChatStatus.loaded) {
                  return const Text(
                    'Online',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  );
                }
                return const Text(
                  'Offline',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state.messages.isNotEmpty) {
            _scrollToBottom();
          }

          if (state.status == ChatStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: const Color(0xFFE94560),
              ),
            );
          }
        },
        builder: (context, chatState) {
          final authState = context.watch<AuthBloc>().state;

          if (authState.user == null) {
            return const Center(child: Text('Not authenticated'));
          }

          if (chatState.status == ChatStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading messages...'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Messages list
              Expanded(
                child: chatState.messages.isEmpty
                    ? const EmptyMessagesWidget()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.messages[index];
                          final isSentByMe =
                              message.senderId == authState.user!.id;

                          return MessageBubble(
                            message: message,
                            isSentByMe: isSentByMe,
                          );
                        },
                      ),
              ),

              // Typing indicator
              if (chatState.isOtherUserTyping)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: TypingIndicator(),
                ),

              // Message input
              MessageInput(
                onSendMessage: (content) {
                  context.read<ChatBloc>().add(
                    ChatMessageSent(
                      content: content,
                      senderId: authState.user!.id,
                      senderName: authState.user!.displayName,
                      receiverId: widget.otherUserId,
                    ),
                  );
                },
                onTypingStarted: () {
                  context.read<ChatBloc>().add(
                    ChatTypingStarted(
                      userId: authState.user!.id,
                      otherUserId: widget.otherUserId,
                    ),
                  );
                },
                onTypingStopped: () {
                  context.read<ChatBloc>().add(
                    ChatTypingStopped(
                      userId: authState.user!.id,
                      otherUserId: widget.otherUserId,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF0084FF)),
              title: const Text('Chat Info'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFE94560)),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Color(0xFFE94560)),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(AuthSignOutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}
