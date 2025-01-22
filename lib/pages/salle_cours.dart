import 'package:flutter/material.dart';
import 'salle_un.dart'; // Assurez-vous d'importer la page SalleUn

class SalleCours extends StatefulWidget {
  const SalleCours({super.key});

  @override
  State<SalleCours> createState() => _SalleCoursState();
}

class _SalleCoursState extends State<SalleCours> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salles de Cours'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCourseTile('Cours CORAN', '9h - 10h (Terminé)', false),
          _buildCourseTile('Cours CORAN', '11h - 12h (Annulé)', true),
          _buildCourseTile('Cours CORAN', '14h - 15h (En cours depuis 15min)', false),
          _buildCourseTile('Cours FIQH', '9h - 10h (Terminé)', false),
          _buildCourseTile('Cours FIQH', '11h - 12h (Annulé)', true),
          _buildCourseTile('Cours FIQH', '14h - 15h (En cours depuis 15min)', false),
        ],
      ),
    );
  }

  Widget _buildCourseTile(String title, String time, bool isCancelled) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(time),
        trailing: isCancelled
            ? const Text('Annulé', style: TextStyle(color: Colors.red))
            : ElevatedButton(
          onPressed: () {
            // Naviguer vers SalleUn
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SalleUn()),
            );
          },
          child: const Text('Entrer'),
        ),
      ),
    );
  }
}