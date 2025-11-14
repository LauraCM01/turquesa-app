/// Define la estructura de una sala de reunión
class Room {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final String imageUrl;

  const Room({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.imageUrl,
  });
}