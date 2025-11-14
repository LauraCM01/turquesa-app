import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/chat_list/chat_model.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  
  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        children: [
          // Avatar o Icono
          CircleAvatar(
            radius: 28,
            backgroundColor: chat.isIcon ? const Color(0xFF2CB7A6).withOpacity(0.1) : Colors.grey.shade200,
            backgroundImage: chat.isIcon ? null : NetworkImage(chat.avatarUrl),
            child: chat.isIcon 
                ? Icon(Icons.person, color: chat.avatarUrl == 'smiley_face' ? const Color(0xFF2CB7A6) : const Color(0xFF2CB7A6))
                : null,
          ),
          const SizedBox(width: 12),
          
          // Nombre y Mensaje
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  chat.lastMessage,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Hora y Contador
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat.time,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: chat.unreadCount > 0 ? const Color(0xFF2CB7A6) : Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              if (chat.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2CB7A6),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}