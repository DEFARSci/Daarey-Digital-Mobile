import 'package:flutter/material.dart';
import 'salle_un.dart'; // Assurez-vous d'importer la page SalleUn

class SalleCours extends StatefulWidget {
  const SalleCours({super.key});

  @override
  State<SalleCours> createState() => _SalleCoursState();
}

class _SalleCoursState extends State<SalleCours> {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text('Salles de Cours'),
        backgroundColor: beigeClair,
        foregroundColor: marron,
        centerTitle: true,
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
      color: beigeClair,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title, style: TextStyle(color: marron, fontWeight: FontWeight.bold)),
        subtitle: Text(time, style: TextStyle(color: marron.withOpacity(0.8))),
        trailing: isCancelled
            ? const Text('Annulé', style: TextStyle(color: Colors.red))
            : ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: beigeClair,
            foregroundColor: marron,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: marron, width: 1.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onPressed: () {
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
