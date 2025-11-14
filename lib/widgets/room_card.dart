import 'package:flutter/material.dart';
import 'package:myapp/Pantalla-Calendario.dart';
import 'package:myapp/constantes/colors.dart';
import 'package:myapp/models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Card(
        color: Colors.white, 
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Column(
          children: [
            // Imagen ocupando la mayor parte del espacio
            Expanded(
              flex: 3,
              child: Ink.image(
                image: NetworkImage(room.imageUrl),
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: () {
                    debugPrint('Ver detalles de ${room.name}');
                     Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CalendarPage(room: room),
                          ),
                        );
                  },
                ),
              ),
            ),
            // Nombre y Botón '+'
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nombre
                    Flexible(
                      child: Text(
                        room.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey, //
                        ),
                        maxLines: 2,
                        // 2. Cambiar TextOverflow a 'clip' o mantener 'ellipsis'
                        //    para que trunque SÓLO si supera el maxLines.
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Botón '+'
                    IconButton(
                      // ... (resto del código del IconButton)
                      icon: const Icon(
                        Icons.add_circle,
                        color: kPrimaryColor,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CalendarPage(room: room),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
