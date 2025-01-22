import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Hadithsdogmes extends StatefulWidget {
  @override
  _HadithsdogmesState createState() => _HadithsdogmesState();
}

class _HadithsdogmesState extends State<Hadithsdogmes> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Instance d'AudioPlayer
  bool isPlaying = false;
  String? currentAudioPath; // Audio en cours de lecture

  // Liste des hadiths/dogmes avec leurs fichiers audio, titres et descriptions
  final List<Map<String, String>> hadithsdogmes = [
    {
      "title": "Hadith 1",
      "description": "Description du Hadith 1 : L'importance de la prière.",
      "audio": "audios/abdou.mp3"
    },
    {
      "title": "Dogme 1",
      "description": "Description du Dogme 1 : Les fondements de la foi.",
      "audio": "audios/dogme1.mp3"
    },
    {
      "title": "Hadith 2",
      "description": "Description du Hadith 2 : La bienveillance envers les autres.",
      "audio": "audios/hadith2.mp3"
    },
    {
      "title": "Dogme 2",
      "description": "Description du Dogme 1 : Les fondements de la foi.",
      "audio": "audios/dogme1.mp3"
    },
    {
      "title": "Hadith 3",
      "description": "Description du Hadith 2 : La bienveillance envers les autres.",
      "audio": "audios/hadith2.mp3"
    },
  ];

  // Méthode pour jouer ou arrêter un audio
  Future<void> _toggleAudio(String audioPath) async {
    try {
      if (!isPlaying || currentAudioPath != audioPath) {
        // Si un autre audio est joué ou aucun n'est actif
        await _audioPlayer.stop(); // Arrête l'audio en cours
        await _audioPlayer.setSource(AssetSource(audioPath)); // Charge l'audio
        await _audioPlayer.resume(); // Démarre la lecture
        setState(() {
          isPlaying = true;
          currentAudioPath = audioPath;
        });
      } else {
        // Pause l'audio actuel
        await _audioPlayer.pause();
        setState(() {
          isPlaying = false;
        });
      }
    } catch (e) {
      print("Erreur : $e"); // Affiche les erreurs en cas de problème
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Libère les ressources audio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hadiths et Dogmes"),
      ),

      body: ListView.builder(
        itemCount: hadithsdogmes.length,
        itemBuilder: (context, index) {
          final hadithDogme = hadithsdogmes[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    hadithDogme["title"] ?? "Titre inconnu",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Description
                  Text(
                    hadithDogme["description"] ?? "Pas de description disponible.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  // Player audio avec bouton lecture/pause
                  Row(
                    children: [
                      // Bouton lecture/pause
                      IconButton(
                        icon: Icon(
                          currentAudioPath == hadithDogme["audio"] && isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () {
                          if (hadithDogme["audio"] != null) {
                            _toggleAudio(hadithDogme["audio"]!);
                          }
                        },
                      ),
                      Text(
                        currentAudioPath == hadithDogme["audio"] && isPlaying
                            ? "Lecture en cours..."
                            : "Appuyez pour écouter",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Cours",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: "Hadith et Dogme",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: "FAQ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: "Salon privé",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Faire un don",
          ),
        ],
        currentIndex: 2, // Index correspondant à la page actuelle (Hadith et Dogme)
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/');
              break;
            case 1:
              Navigator.pushNamed(context, '/cours');
              break;
            case 2:
              break; // Page actuelle
            case 3:
              Navigator.pushNamed(context, '/faq');
              break;
            case 4:
              Navigator.pushNamed(context, '/salon');
              break;
            case 5:
              Navigator.pushNamed(context, '/don');
              break;
          }
        },
      ),
    );
  }
}
