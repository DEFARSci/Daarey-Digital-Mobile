import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class Hadithsdogmes extends StatefulWidget {
  @override
  _HadithsdogmesState createState() => _HadithsdogmesState();
}

class _HadithsdogmesState extends State<Hadithsdogmes> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? currentAudioPath;
  List hadiths = [];
  List dogmes = [];

  final String staticAudioUrl = 'https://www.hadith.defarsci.fr/audios/1737634407.mp3';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchHadiths();
    _fetchDogmes();

    // Écouter les changements d'état du lecteur audio
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = (state == PlayerState.playing);
      });
    });
  }

  // Récupérer les Hadiths
  Future<void> _fetchHadiths() async {
    final url = Uri.parse('https://www.hadith.defarsci.fr/api/hadiths');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          hadiths = json.decode(response.body);
        });
      } else {
        print("Erreur Hadiths ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur Hadiths : $e");
    }
  }

  // Récupérer les Dogmes
  Future<void> _fetchDogmes() async {
    final url = Uri.parse('https://www.hadith.defarsci.fr/api/dogmes');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          dogmes = json.decode(response.body);
        });
      } else {
        print("Erreur Dogmes ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur Dogmes : $e");
    }
  }

  // Jouer ou arrêter l'audio
  Future<void> _toggleAudio(String audioPath) async {
    try {
      if (!isPlaying || currentAudioPath != audioPath) {
        await _audioPlayer.stop();
        await _audioPlayer.setSourceUrl(audioPath);
        await _audioPlayer.play(UrlSource(audioPath));
        setState(() {
          isPlaying = true;
          currentAudioPath = audioPath;
        });
      } else {
        await _audioPlayer.pause();
        setState(() {
          isPlaying = false;
        });
      }
    } catch (e) {
      print("Erreur audio : $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hadiths et Dogmes"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFF51B37F), // Couleur de l’indicateur sous l’onglet sélectionné
          labelColor: Color(0xFF51B37F), // Couleur du texte de l’onglet sélectionné
          unselectedLabelColor: Colors.black, // Couleur des onglets non sélectionnés
          tabs: [
            Tab(text: "Hadiths"),
            Tab(text: "Dogmes"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Lecture de l'audio statique
          Card(
            margin: EdgeInsets.all(16),
            child: ListTile(
              leading: IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () => _toggleAudio(staticAudioUrl),
              ),
              title: Text(
                "Écouter l'audio principal",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(isPlaying ? "Lecture en cours..." : "Appuyez pour écouter"),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Liste des Hadiths
                hadiths.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: hadiths.length,
                  itemBuilder: (context, index) {
                    final hadith = hadiths[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hadith["titre"] ?? "Titre inconnu",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              hadith["contenu"] ?? "Pas de description disponible.",
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    currentAudioPath == hadith["audio"] && isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                  ),
                                  onPressed: () {
                                    if (hadith["audio"] != null) {
                                      _toggleAudio(hadith["audio"]!);
                                    }
                                  },
                                ),
                                Text(
                                  currentAudioPath == hadith["audio"] && isPlaying
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
                // Liste des Dogmes
                dogmes.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: dogmes.length,
                  itemBuilder: (context, index) {
                    final dogme = dogmes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          dogme["titre"] ?? "Dogme inconnu",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(dogme["description"] ?? "Pas de description"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF51B37F), // Couleur de l'élément sélectionné
        unselectedItemColor: Colors.grey, // Couleur des éléments non sélectionnés
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
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/');
              break;
            case 1:
              Navigator.pushNamed(context, '/cours');
              break;
            case 2:
              break;
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
