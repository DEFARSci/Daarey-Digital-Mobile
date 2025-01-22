import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
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
        title: const Text("Accueil"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Vidéo avec contrôles
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

            // Section Titre et Description
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nos actualités",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                        "Praesent vitae eros eget tellus tristique bibendum.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Section Événements
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ne ratez pas nos prochains événements",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Concours de récital de Coran à Pikine. "
                        "Les inscriptions sont ouvertes sur le lien.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Carrousel d'images
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

      // Barre de Navigation
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
