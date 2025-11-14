import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatMessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2CB7A6) : const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          message,
          style: GoogleFonts.poppins(
            color: isMe ? Colors.white : Colors.grey,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}