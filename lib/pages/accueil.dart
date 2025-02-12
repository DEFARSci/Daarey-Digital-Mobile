import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  late Future<List<dynamic>> _actualites;
  late Future<List<dynamic>> _events;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/videos/fatiha.mp4',
    );
    _initializeVideoPlayerFuture = _videoController.initialize();
    _videoController.setLooping(true);

    _actualites = _fetchActualites();
    _events = _fetchEvents();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  // Fonction pour récupérer les actualités
  Future<List<dynamic>> _fetchActualites() async {
    final url = Uri.parse('https://www.hadith.defarsci.fr/api/actualites');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      }
    } catch (e) {
      print("Erreur lors de la récupération des actualités : $e");
    }

    return [];
  }

  // Fonction pour récupérer les événements
  Future<List<dynamic>> _fetchEvents() async {
    final url = Uri.parse('https://www.hadith.defarsci.fr/api/events');

    try {
      final response = await http.get(url);
      print("Réponse API événements : ${response.body}"); //  Affiche la réponse brute

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Données après décodage : $data"); //  Vérifie le format des données
        return data is List ? data : [];
      } else {
        print("Erreur API événements : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la récupération des événements : $e");
    }

    return [];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎥 Section Vidéo avec contrôles
            Container(
              height: 200,
              width: double.infinity,
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        ),
                        IconButton(
                          iconSize: 50,
                          icon: Icon(
                            _videoController.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_videoController.value.isPlaying) {
                                _videoController.pause();
                              } else {
                                _videoController.play();
                              }
                            });
                          },
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),

            // 📰 Section Nos Actualités
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Nos actualités",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            FutureBuilder<List<dynamic>>(
              future: _actualites,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Aucune actualité disponible pour le moment"),
                  );
                }

                return Column(
                  children: snapshot.data!.map((actualite) {
                    return ListTile(
                      leading: actualite['image'] != null
                          ? Image.network(
                        actualite['image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.article, size: 40),
                      title: Text(
                        actualite['titre'] ?? "Titre inconnu",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                      Text(actualite['description'] ?? "Sans description"),
                    );
                  }).toList(),
                );
              },
            ),

            // 📅 Section Événements à venir
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Événements à venir",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            FutureBuilder<List<dynamic>>(
              future: _events,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Aucun événement à venir"),
                  );
                }

                return Column(
                  children: snapshot.data!.map((event) {
                    return ListTile(
                      leading: event['image_url'] != null
                          ? Image.network(
                        "https://www.hadith.defarsci.fr/images/${event['image_url']}",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.event, size: 40),
                      title: Text(
                        event['title'] ?? "Titre inconnu",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        event['content'] ?? "Sans description",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        // Ajouter une action lorsqu'on clique sur un événement
                      },
                    );
                  }).toList(),
                );
              },
            ),

            // 🖼️ Carrousel d'images
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: [
                  'assets/images/photo.jpg',
                  'assets/images/photo1.jpg',
                  'assets/images/photo2.jpg',
                  'assets/images/coran.jpg',
                ].map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),

      // 🔍 Barre de Navigation
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
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/cours');
              break;
            case 2:
              Navigator.pushNamed(context, '/hadith');
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