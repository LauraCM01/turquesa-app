class Chat {
  final String id;
  final String avatarUrl;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isIcon;

  const Chat({
    required this.id,
    required this.avatarUrl,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    this.isIcon = false,
  });
}