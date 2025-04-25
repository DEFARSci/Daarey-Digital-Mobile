import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Khotba extends StatefulWidget {
  const Khotba({super.key});

  @override
  State<Khotba> createState() => _KhotbaState();
}

class _KhotbaState extends State<Khotba> {
  // Liste fictive de khoutbas - à remplacer par vos données réelles
  final List<Map<String, dynamic>> khoutbas = [
    {
      'title': 'La patience en islam',
      'titleAr': 'الصبر في الإسلام',
      'date': '15 Ramadan 1445',
      'audio': 'https://example.com/audio1.mp3',
      'pdf': 'https://example.com/khoutba1.pdf',
      'video': 'https://youtube.com/embed/abc123'
    },
    {
      'title': 'L\'importance de la prière',
      'titleAr': 'أهمية الصلاة',
      'date': '22 Ramadan 1445',
      'audio': 'https://example.com/audio2.mp3',
      'pdf': 'https://example.com/khoutba2.pdf',
      'video': 'https://youtube.com/embed/def456'
    },
  ];

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khoutbas'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: khoutbas.length,
        itemBuilder: (context, index) {
          final khoutba = khoutbas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre français et arabe
                  Text(
                    khoutba['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    khoutba['titleAr'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Arabic',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Text(
                    khoutba['date'],
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Boutons pour les fichiers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Bouton Audio
                      ElevatedButton.icon(
                        icon: const Icon(Icons.audiotrack),
                        label: const Text('Audio'),
                        onPressed: () => _launchUrl(khoutba['audio']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                        ),
                      ),

                      // Bouton PDF
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('PDF'),
                        onPressed: () => _launchUrl(khoutba['pdf']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                        ),
                      ),

                      // Bouton Vidéo
                      ElevatedButton.icon(
                        icon: const Icon(Icons.videocam),
                        label: const Text('Vidéo'),
                        onPressed: () => _launchUrl(khoutba['video']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // Barre de navigation identique à MosqueeAssalam
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF51B37F),
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Index pour Khotba
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', (route) => false);
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/mosquee', (route) => false);
              break;
            case 2:
            // Déjà sur la page Khotba
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/projet_madrassa', (route) => false);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mosque),
            label: "Mosquée",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: "Khoutba",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Projet Madrassa",
          ),
        ],
      ),
    );
  }
}