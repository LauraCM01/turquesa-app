import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/chat_list/chat_list_item.dart';
import 'package:myapp/chat_list/chat_model.dart';
import 'package:uuid/uuid.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final List<Chat> _chats;
  late TextEditingController _searchController;
  List<Chat> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    const uuid = Uuid();
    _chats = [
      Chat(
        id: uuid.v4(),
        avatarUrl: 'smiley_face',
        name: 'Viviana García',
        lastMessage: 'La habitación doble necesita...',
        time: '12:25 pm',
        unreadCount: 3,
        isIcon: true,
      ),
      Chat(
        id: uuid.v4(),
        avatarUrl: 'smiley_face',
        name: 'Raúl Martínez',
        lastMessage: 'Ya está limpia la habitación suite...',
        time: '11:23 am',
        unreadCount: 1,
        isIcon: true,
      ),
      Chat(
        id: uuid.v4(),
        avatarUrl: 'smiley_face',
        name: 'Juan Pérez',
        lastMessage: 'No está en funcionamiento la habitación...',
        time: '10:20 am',
        unreadCount: 1,
        isIcon: true,
      ),
    ];

    _searchController = TextEditingController();
    _filteredChats = _chats;
    _searchController.addListener(_filterChats);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChats = _chats.where((chat) {
        return chat.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.0,
        toolbarHeight: 80.0,
        title: Text(
          'Chat',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2CB7A6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar chat...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredChats.length,
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                return InkWell(
                  // ⭐ CAMBIO: Pasar el objeto 'chat' en 'extra'
                  onTap: () => context.go(
                    '/chat/${chat.id}',
                    extra: chat, // Aquí se pasa el objeto completo
                  ),
                  child: ChatListItem(chat: chat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}