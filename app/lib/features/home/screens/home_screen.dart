import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Mock data for chat list
  final List<ChatItem> _chats = [
    ChatItem(
      name: 'Nguyễn Văn A',
      lastMessage: 'Chào bạn! Bạn có khỏe không?',
      time: '10:30',
      unreadCount: 2,
      avatar: '🧑',
      isOnline: true,
    ),
    ChatItem(
      name: 'Trần Thị B',
      lastMessage: 'Hẹn gặp lại nhé!',
      time: '09:15',
      unreadCount: 0,
      avatar: '👩',
      isOnline: true,
    ),
    ChatItem(
      name: 'Lê Văn C',
      lastMessage: 'Cảm ơn bạn rất nhiều',
      time: 'Hôm qua',
      unreadCount: 1,
      avatar: '👨',
      isOnline: false,
    ),
    ChatItem(
      name: 'Phạm Thị D',
      lastMessage: 'Tôi sẽ gửi file cho bạn sau',
      time: 'Hôm qua',
      unreadCount: 0,
      avatar: '👩‍🦱',
      isOnline: false,
    ),
    ChatItem(
      name: 'Hoàng Văn E',
      lastMessage: 'Được rồi, tôi hiểu',
      time: 'T2',
      unreadCount: 0,
      avatar: '👨‍💼',
      isOnline: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ZapChat',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                context.pushReplacement('/login');
              }
            },
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person, color: AppColors.textPrimary),
                      title: Text('Hồ sơ', style: AppTextStyles.labelMedium),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: AppColors.textPrimary,
                      ),
                      title: Text('Cài đặt', style: AppTextStyles.labelMedium),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: AppColors.error),
                      title: Text(
                        'Đăng xuất',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildChatList(), _buildStatusPage(), _buildCallsPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Trạng thái',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Cuộc gọi'),
        ],
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  // TODO: Start new chat
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: _HomeScreenStyles.avatarRadius,
                backgroundColor: AppColors.inputBackground,
                child: Text(chat.avatar, style: const TextStyle(fontSize: 24)),
              ),
              if (chat.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: _HomeScreenStyles.onlineIndicatorSize,
                    height: _HomeScreenStyles.onlineIndicatorSize,
                    decoration: BoxDecoration(
                      color: AppColors.online,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(chat.name, style: AppTextStyles.chatTitle),
          subtitle: Text(
            chat.lastMessage,
            style: AppTextStyles.chatSubtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat.time,
                style: AppTextStyles.chatTime.copyWith(
                  color:
                      chat.unreadCount > 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                  fontWeight:
                      chat.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                ),
              ),
              if (chat.unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.unreadBadge,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: AppTextStyles.unreadBadge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
          onTap: () {
            // TODO: Navigate to chat detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mở chat với ${chat.name}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.update,
            size: _HomeScreenStyles.placeholderIconSize,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Trạng thái',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            'Chức năng đang phát triển',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call,
            size: _HomeScreenStyles.placeholderIconSize,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Cuộc gọi',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            'Chức năng đang phát triển',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Style riêng cho HomeScreen
class _HomeScreenStyles {
  static const double avatarRadius = 25.0;
  static const double onlineIndicatorSize = 16.0;
  static const double placeholderIconSize = 64.0;
}

class ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String avatar;
  final bool isOnline;

  ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.avatar,
    required this.isOnline,
  });
}
