import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../users/presentation/bloc/user_bloc.dart';
import '../../../users/presentation/screens/user_list_screen.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_list_bloc.dart';
import '../bloc/chat_list_event.dart';
import '../bloc/chat_list_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/chat_room_entity.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    final authState = context.read<AuthBloc>().state;

    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      // Start loading chats
      context.read<ChatListBloc>().add(ChatListStarted(authState.user!.id));

      // Wait minimum time for smooth transition
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } else {
      // If not authenticated, stop initializing immediately
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: _isInitializing ? _buildInitialLoading() : _buildChatList(),
        floatingActionButton: _isInitializing ? null : _buildFAB(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Messages',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: Colors.black,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          offset: const Offset(0, 50),
          elevation: 8,
          onSelected: (value) {
            if (value == 'logout') {
              _showLogoutDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFE94560),
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Sign Out',
                    style: TextStyle(color: Color(0xFFE94560), fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildInitialLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0084FF).withValues(alpha: 0.2),
                  const Color(0xFF0084FF).withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF0084FF).withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Loading your chats...',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return BlocBuilder<ChatListBloc, ChatListState>(
      builder: (context, state) {
        if (state.chatRooms.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.chatRooms.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 88,
            endIndent: 16,
            color: Colors.grey.shade100,
          ),
          itemBuilder: (context, index) {
            final chatRoom = state.chatRooms[index];
            return _ChatListItem(
              chatRoom: chatRoom,
              onTap: () => _navigateToChat(context, chatRoom),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0084FF).withValues(alpha: 0.1),
                    const Color(0xFF00C6FF).withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80,
                color: const Color(0xFF0084FF).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start a conversation with\nyour friends and colleagues',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 56),
            ElevatedButton.icon(
              onPressed: () => _navigateToUsersList(context),
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text(
                'Start Chatting',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0084FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToUsersList(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.edit_rounded, size: 22, color: Colors.white),
        label: const Text(
          'New',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context, ChatRoomEntity chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AuthBloc>()),
            BlocProvider.value(value: context.read<ChatBloc>()),
          ],
          child: ChatScreen(
            otherUserId: chatRoom.otherUserId,
            otherUserName: chatRoom.otherUserName,
          ),
        ),
      ),
    );
  }

  void _navigateToUsersList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AuthBloc>()),
            BlocProvider.value(value: context.read<ChatBloc>()),
            BlocProvider.value(value: context.read<UsersBloc>()),
          ],
          child: const UsersListScreen(),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE94560),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// In chat_list_screen.dart, update the _ChatListItem class:

class _ChatListItem extends StatelessWidget {
  final ChatRoomEntity chatRoom;
  final VoidCallback onTap;

  const _ChatListItem({required this.chatRoom, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Avatar with gradient
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  chatRoom.otherUserName.isNotEmpty
                      ? chatRoom.otherUserName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.otherUserName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chatRoom.lastMessageTime != null)
                        Text(
                          _formatTime(chatRoom.lastMessageTime!),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.lastMessage ?? 'Start chatting...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: chatRoom.lastMessage != null
                                ? AppColors.textSecondary
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (chatRoom.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.badgeGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          child: Center(
                            child: Text(
                              '${chatRoom.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(time);
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
