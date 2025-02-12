import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Cours extends StatefulWidget {
  const Cours({super.key});

  @override
  State<Cours> createState() => _CoursState();
}

class _CoursState extends State<Cours> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/videos/fatiha.mp4', // Chemin de la vidéo locale
    );
    _initializeVideoPlayerFuture = _videoController.initialize();
    _videoController.setLooping(true);
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cours"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Vidéo
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
                              _videoController.value.isPlaying
                                  ? _videoController.pause()
                                  : _videoController.play();
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
            // Section Titre et Description
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Présentation des cours proposés",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Une vidéo présentative des différents types de cours proposés et comment y assister.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Section 1 : Image et Actions
            _buildCourseSection(
              context: context,
              imagePath: 'assets/images/coran.jpg',
              title: "Cours Coran",
              button1Text: "S'inscrire cours Débutant",
              button2Text: "S'inscrire cours Confirmé",
            ),

            const SizedBox(height: 16),

            // Section 2 : Deuxième Image et Actions
            _buildCourseSection(
              context: context,
              imagePath: 'assets/images/coran.jpg',
              title: "Cours Fiqh",
              button1Text: "S'inscrire cours Débutant",
              button2Text: "S'inscrire cours Confirmé",
            ),

            const SizedBox(height: 40), // Espacement avant le bouton d'accès

            // Nouveau bouton ajouté en bas de la page
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.green, // Couleur verte pour correspondre à l'image
                  backgroundColor: Color(0xFF51b37f),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/salleCours');
                },
                child: const Text(
                  "Accéder aux salles de cours",
                  style: TextStyle(fontSize: 16, color: Colors.white, ),
                ),
              ),
            ),
          ],
        ),
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
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/');
              break;
            case 1:
              break; // Page actuelle
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

  // Fonction pour créer une section réutilisable
  Widget _buildCourseSection({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String button1Text,
    required String button2Text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Redirection vers la page InscriptionCoran pour le bouton 1
              Navigator.pushNamed(context, '/InscriptionCoran');
            },
            child: Text(
              button1Text,
              style: const TextStyle(fontSize: 16, color: Color(0xFF51b37f),),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Redirection vers la page InscriptionCoran pour le bouton 2
              Navigator.pushNamed(context, '/InscriptionCoran');
            },
            child: Text(
              button2Text,
              style: const TextStyle(fontSize: 16,
                  color: Color(0xFF51b37f),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
//#51B37F
//backgroundColor: const Color(0xFF85addb),
//color: const Color(0xFF85addb),