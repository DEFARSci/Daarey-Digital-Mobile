import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cours extends StatefulWidget {
  const Cours({super.key});

  @override
  State<Cours> createState() => _CoursState();
}

class _CoursState extends State<Cours> with WidgetsBindingObserver {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoController = VideoPlayerController.asset('assets/videos/fatiha.mp4');
    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
      _videoController.setLooping(true);
    });
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('auth_token') != null;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      setState(() => _isLoggedIn = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController.dispose();
    super.dispose();
  }

  Widget _buildCourseSection({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String button1Text,
    required String button2Text,
    required String route1,
    required String route2,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: marron,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: beigeClair,
              foregroundColor: marron,
              minimumSize: const Size(double.infinity, 40),
            ),
            onPressed: () => Navigator.pushNamed(context, route1),
            child: Text(button1Text),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: beigeClair,
              foregroundColor: marron,
              minimumSize: const Size(double.infinity, 40),
            ),
            onPressed: () => Navigator.pushNamed(context, route2),
            child: Text(button2Text),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _navigateToPrivateSection(BuildContext context, String route) async {
    if (_isLoggedIn) {
      Navigator.pushNamed(context, route);
    } else {
      final result = await Navigator.pushNamed(context, '/login');
      if (result == true && mounted) {
        await _checkLoginStatus();
      }
    }
  }
  Future<void> _navigateToSection(BuildContext context, String route) async {
    // Liste des routes publiques qui ne nécessitent pas de connexion
    final publicRoutes = ['/mosquee', '/', '/cours', '/contributions', '/faq', '/don'];

    if (publicRoutes.contains(route)) {
      // Accès direct pour les routes publiques
      Navigator.pushNamed(context, route);
    } else if (_isLoggedIn) {
      // Accès autorisé pour les utilisateurs connectés
      Navigator.pushNamed(context, route);
    } else {
      // Redirection vers le login pour les routes privées
      final result = await Navigator.pushNamed(context, '/login');
      if (result == true && mounted) {
        await _checkLoginStatus();
        // Re-tente la navigation après connexion
        if (_isLoggedIn) {
          Navigator.pushNamed(context, route);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("Cours"),
        centerTitle: true,
        backgroundColor: beigeClair,
        foregroundColor: marron,
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vidéo
            SizedBox(
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
                  }
                  return Center(child: CircularProgressIndicator(color: marron));
                },
              ),
            ),

            // Titre + description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Présentation des cours proposés",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: marron,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Une vidéo présentative des différents types de cours proposés et comment y assister.",
                    style: TextStyle(fontSize: 16, color: marron.withOpacity(0.7)),
                  ),
                ],
              ),
            ),

            // Sections cours
            _buildCourseSection(
              context: context,
              imagePath: 'assets/images/coran.jpg',
              title: "Cours Coran",
              button1Text: "S'inscrire cours Débutant",
              button2Text: "S'inscrire cours Confirmé",
              route1: '/InscriptionCoran',
              route2: '/Inscriptioncoranconfirme',
            ),

            _buildCourseSection(
              context: context,
              imagePath: 'assets/images/coran.jpg',
              title: "Cours Fiqh",
              button1Text: "S'inscrire cours Débutant",
              button2Text: "S'inscrire cours Confirmé",
              route1: '/Inscriptionfikh',
              route2: '/Inscriptionfikhconfirme',
            ),

            // Boutons d'accès
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: beigeClair,
                  //     foregroundColor: marron,
                  //     minimumSize: const Size(double.infinity, 50),
                  //   ),
                  //   onPressed: () => _navigateToPrivateSection(context, '/salleCours'),
                  //   child: const Text("Accéder aux salles de cours", style: TextStyle(fontSize: 16)),
                  // ),
                  // const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: beigeClair,
                      foregroundColor: marron,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/mosquee'),
                    child: const Text("Accéder à la mosquée AS SALAM", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: beigeClair,
        selectedItemColor: marron,
        unselectedItemColor: marron.withOpacity(0.6),
        currentIndex: 1,
        onTap: (index) async {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/');
              break;
            case 1:
              break;
            case 2:
              Navigator.pushNamed(context, '/contributions');
              break;
            case 3:
              Navigator.pushNamed(context, '/faq');
              break;
            case 4:
              await _navigateToPrivateSection(context, '/salon');
              break;
            case 5:
              Navigator.pushNamed(context, '/don');
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          const BottomNavigationBarItem(icon: Icon(Icons.book), label: "Cours"),
          const BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: "Contribution"),
          const BottomNavigationBarItem(icon: Icon(Icons.help), label: "FAQ"),
          BottomNavigationBarItem(
            icon: Icon(_isLoggedIn ? Icons.lock_open : Icons.lock),
            label: "Salon privé",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Faire un don"),
        ],
      ),
    );
  }
}
