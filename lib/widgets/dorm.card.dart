// lib/widgets/dorm_card.dart
import 'package:flutter/material.dart';

class DormCard extends StatelessWidget {
  final Map<String, dynamic> dorm;

  const DormCard({super.key, required this.dorm});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            dorm['image'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
          ),
        ),
        title: Text(dorm['name']),
        subtitle: Text('ราคา: ${dorm['price']}'),
        onTap: () {
          // Add navigation or detail logic here
        },
      ),
    );
  }
}
