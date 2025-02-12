import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Fairedon extends StatefulWidget {
  const Fairedon({Key? key}) : super(key: key);

  @override
  State<Fairedon> createState() => _FairedonState();
}

class _FairedonState extends State<Fairedon> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  int _currentIndex = 5; // Index de la page "Faire un don"
  String selectedOption = "10€"; // Option sélectionnée par défaut

  @override
  void initState() {
    super.initState();
    // Initialisation de la vidéo
    _videoController = VideoPlayerController.asset(
      'assets/videos/fatiha.mp4', // Chemin de la vidéo locale
    );
    _initializeVideoPlayerFuture = _videoController.initialize();
    _videoController.setLooping(true); // Lecture en boucle
  }

  @override
  void dispose() {
    _videoController.dispose(); // Libération des ressources
    super.dispose();
  }

  // Méthode pour gérer la navigation entre les pages
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Navigation vers les pages correspondantes
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/accueil');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/cours');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/hadith_dogme');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/faq');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/salon_prive');
        break;
      case 5:
      // Reste sur la page actuelle
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faire un Don"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section Vidéo
                    FutureBuilder(
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
                    const SizedBox(height: 20),

                    // Texte explicatif
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Faites un don pour soutenir notre communauté.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Votre contribution nous aide à maintenir et développer nos services. Merci pour votre générosité.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Étapes de don
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              "Étape 1 : Montant",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: [
                                RadioListTile(
                                  title: const Text("10€"),
                                  value: "10€",
                                  groupValue: selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value.toString();
                                    });
                                  },
                                ),
                                RadioListTile(
                                  title: const Text("50€"),
                                  value: "50€",
                                  groupValue: selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value.toString();
                                    });
                                  },
                                ),
                                RadioListTile(
                                  title: const Text("100€"),
                                  value: "100€",
                                  groupValue: selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value.toString();
                                    });
                                  },
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      value: "Montant libre",
                                      groupValue: selectedOption,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedOption = value.toString();
                                        });
                                      },
                                    ),
                                    const Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: "Montant libre",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // Navigation ou action pour "Étape suivante"
                              },
                              child: const Text("Suivant >"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // Barre de Navigation
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
        currentIndex: 5, // Indice correspondant à "Salon privé"
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/');
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
              Navigator.pushNamed(context, '/Salonprive');
              break;
            case 5:
            // Déjà sur "Salon privé", pas de navigation
              break;
          }
        },
      ),
    );
  }
}
