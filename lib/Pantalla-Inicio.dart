import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/room.dart';
import 'widgets/room_card.dart';

// Lista de habitaciones simuladas (sin const en los objetos Room)
final List<Room> dummyRooms = [
  Room(
    name: 'Habitación Familiar',
    imageUrl:
        'https://res.cloudinary.com/dfznn7pui/image/upload/v1762629773/Habitacion-1_ibttii.png',
    id: 'R001',
  ),
  Room(
    name: 'Habitación Doble Sencilla',
    imageUrl:
        'https://res.cloudinary.com/dfznn7pui/image/upload/v1762629773/Habitacion-5_ibm1pp.png',
    id: 'R002',
  ),
  Room(
    name: 'Habitación Triple',
    imageUrl:
        'https://res.cloudinary.com/dfznn7pui/image/upload/v1762629773/Habitacion-4_afjrlh.png',
    id: 'R003',
  ),
  Room(
    name: 'Habitación Suite',
    imageUrl:
        'https://res.cloudinary.com/dfznn7pui/image/upload/v1762629775/Habitacion-6_ommdkh.png',
    id: 'R004',
  ),
  Room(
    name: 'Habitación Familiar Grande',
    imageUrl:
        'https://res.cloudinary.com/dfznn7pui/image/upload/v1762631165/Habitacion-9-personas_zyeepv.png',
    id: 'R005',
  ),
  Room(
    name: 'Habitación Doble',
    imageUrl:
        'https://res.cloudinary.com/dfznn7pui/image/upload/v1762635431/habitacion_naranja_ome2oc.png',
    id: 'R006',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  List<Room> _filteredRooms = dummyRooms;

  void _addRoom(BuildContext context) {
    debugPrint('Botón "Agregar Habitación" presionado.');
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredRooms = dummyRooms
          .where((room) =>
              room.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turquesa Hostal',
      theme: ThemeData(
        primaryColor: const Color(0XFF2CB7A6),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.0,
          toolbarHeight: 80.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                child: SizedBox(
                  width: 150,
                  child: Image.network(
                    'https://res.cloudinary.com/dfznn7pui/image/upload/v1761514333/LOGO-HOSTAL_yvkmmi.png',
                    fit: BoxFit.contain,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSearchBar(),
              const SizedBox(height: 20),
              Expanded(
                child: _filteredRooms.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron resultados',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : GridView.count(
                        padding: const EdgeInsets.only(
                          top: 0.0,
                          left: 16.0,
                          right: 16.0,
                          bottom: 10.0,
                        ),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        children: _filteredRooms.map((room) {
                          return RoomCard(room: room);
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _addRoom(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'AGREGAR HABITACIÓN',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF2CB7A6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1.0,
        ),
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscador',
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(
            top: 10.0,
            bottom: 10.0,
            left: 0.0,
            right: 0.0,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
