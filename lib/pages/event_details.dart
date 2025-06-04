import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final dynamic event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['title'] ?? 'Détail événement'),
        backgroundColor: const Color(0xFFF3EEE1),
        foregroundColor: const Color(0xFF5D4C3B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event['image_url'] != null)
              Image.network(
                "https://www.hadith.defarsci.fr/images/${event['image_url']}",
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text(
              event['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (event['date'] != null)
              Text(
                'Date : ${event['date']}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Text(
              event['content'] ?? 'Pas de détails disponibles.',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
