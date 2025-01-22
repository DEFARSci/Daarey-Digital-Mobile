import 'package:flutter/material.dart';

class SalleUn extends StatefulWidget {
  const SalleUn({super.key});

  @override
  State<SalleUn> createState() => _SalleUnState();
}

class _SalleUnState extends State<SalleUn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SALLE 1'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildParticipantTile(),
                _buildParticipantTile(),
                _buildParticipantTile(),
              ],
            ),
          ),
          // Ajoutez ici les contrôles (micro, vidéo, etc.)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: Icon(Icons.mic), onPressed: () {}),
                IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
                IconButton(icon: Icon(Icons.call_end), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 40,
          color: Colors.blue,
        ),
      ),
    );
  }
}