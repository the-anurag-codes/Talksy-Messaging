// lib/features/chat/presentation/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talksy/core/theme/app_colors.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
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
    _initializeChat();

    // Auto-scroll after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _scrollToBottom();
      });
    });
  }

  void _initializeChat() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      context.read<ChatBloc>().add(
        ChatStarted(
          userId: authState.user!.id,
          otherUserId: widget.otherUserId,
          userName: authState.user!.displayName,
          otherUserName: widget.otherUserName,
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
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state.messages.isNotEmpty) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) _scrollToBottom();
                  });
                }

                // Show error snackbar
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
              builder: (context, chatState) {
                final authState = context.watch<AuthBloc>().state;

                if (authState.user == null) {
                  return const Center(
                    child: Text(
                      'Not authenticated',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                if (chatState.status == ChatStatus.loading) {
                  return Container(
                    color: AppColors.background,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (chatState.messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatState.messages[index];
                    final isSentByMe = message.senderId == authState.user!.id;

                    return MessageBubble(
                      message: message,
                      isSentByMe: isSentByMe,
                    );
                  },
                );
              },
            ),
          ),

          // Typing indicator
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state.isOtherUserTyping) {
                return const Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TypingIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Message input
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                return MessageInput(
                  onSendMessage: (content) {
                    if (authState.user != null) {
                      context.read<ChatBloc>().add(
                        ChatMessageSent(
                          content: content,
                          senderId: authState.user!.id,
                          senderName: authState.user!.displayName,
                          receiverId: widget.otherUserId,
                        ),
                      );
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (mounted) _scrollToBottom();
                      });
                    }
                  },
                  onTypingStarted: () {
                    if (authState.user != null) {
                      context.read<ChatBloc>().add(
                        ChatTypingStarted(
                          userId: authState.user!.id,
                          otherUserId: widget.otherUserId,
                        ),
                      );
                    }
                  },
                  onTypingStopped: () {
                    if (authState.user != null) {
                      context.read<ChatBloc>().add(
                        ChatTypingStopped(
                          userId: authState.user!.id,
                          otherUserId: widget.otherUserId,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          // Avatar with gradient
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state.isOtherUserTyping) {
                      return const Text(
                        'typing...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }
                    return const Text(
                      'Active now',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.videocam_rounded,
            color: AppColors.primary,
            size: 26,
          ),
          onPressed: () {
            // TODO: Implement video call
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.call_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          onPressed: () {
            // TODO: Implement voice call
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradientWithOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.waving_hand_rounded,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Say hi! 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start the conversation',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
