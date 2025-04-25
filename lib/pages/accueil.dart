import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> with WidgetsBindingObserver {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  late Future<List<dynamic>> _actualites;
  late Future<List<dynamic>> _events;
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
    _loadData();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('auth_token') != null;
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _actualites = _fetchActualites();
      _events = _fetchEvents();
    });
  }

  Future<List<dynamic>> _fetchActualites() async {
    final response = await http.get(Uri.parse('https://www.hadith.defarsci.fr/api/actualites'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<List<dynamic>> _fetchEvents() async {
    final response = await http.get(Uri.parse('https://www.hadith.defarsci.fr/api/events'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Widget _buildVideoSection() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_videoController),
                VideoProgressIndicator(_videoController, allowScrubbing: true),
                Center(
                  child: IconButton(
                    icon: Icon(
                      _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
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
                ),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator(color: marron));
        }
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: marron,
        ),
      ),
    );
  }

  Widget _buildActualiteItem(dynamic actualite) {
    return Card(
      color: beigeClair,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: actualite['image'] != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            actualite['image'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.article, size: 40, color: beigeClair),
          ),
        )
            : Icon(Icons.article, size: 40, color: beigeClair),
        title: Text(
          actualite['titre'] ?? "Titre inconnu",
          style: TextStyle(fontWeight: FontWeight.bold, color: beigeClair),
        ),
        subtitle: Text(
          actualite['description'] ?? "Sans description",
          style: TextStyle(color: beigeClair.withOpacity(0.8)),
        ),
      ),
    );
  }

  Widget _buildEventItem(dynamic event) {
    return Card(
      color: beigeClair,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: event['image_url'] != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            "https://www.hadith.defarsci.fr/images/${event['image_url']}",
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.event, size: 40, color: beigeClair),
          ),
        )
            : Icon(Icons.event, size: 40, color: marron),
        title: Text(
          event['title'] ?? "Titre inconnu",
          style: TextStyle(fontWeight: FontWeight.bold, color: marron),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['content'] ?? "Sans description",
              style: TextStyle(color: marron.withOpacity(0.8)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (event['date'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Le ${event['date']}",
                  style: TextStyle(fontSize: 12, color: marron.withOpacity(0.6)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = [
      'assets/images/photo.jpg',
      'assets/images/photo1.jpg',
      'assets/images/photo2.jpg',
      'assets/images/coran.jpg',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 200,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.8,
        ),
        items: images.map((imagePath) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: marron.withOpacity(0.3), width: 2),
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
    );
  }

  Future<void> _navigateToSalon(BuildContext context) async {
    if (_isLoggedIn) {
      Navigator.pushNamed(context, '/salon');
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("Accueil"),
        centerTitle: true,
        backgroundColor: beigeClair,
        foregroundColor: marron,
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                setState(() => _isLoggedIn = false);
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        color: marron,
        backgroundColor: beigeClair,
        onRefresh: () async {
          _loadData();
          await _checkLoginStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVideoSection(),
              _buildSectionTitle("Nos actualités"),
              FutureBuilder<List<dynamic>>(
                future: _actualites,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: marron));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text("Aucune actualité disponible", style: TextStyle(color: marron)),
                    );
                  }
                  return Column(
                    children: snapshot.data!.map((item) => _buildActualiteItem(item)).toList(),
                  );
                },
              ),
              _buildSectionTitle("Événements à venir"),
              FutureBuilder<List<dynamic>>(
                future: _events,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: marron));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text("Aucun événement à venir", style: TextStyle(color: marron)),
                    );
                  }
                  return Column(
                    children: snapshot.data!.map((item) => _buildEventItem(item)).toList(),
                  );
                },
              ),
              _buildImageCarousel(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: beigeClair,
        selectedItemColor: marron,
        unselectedItemColor: marron.withOpacity(0.6),
        currentIndex: 0,
        onTap: (index) async {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/cours');
              break;
            case 2:
              Navigator.pushNamed(context, '/contributions');
              break;
            case 3:
              Navigator.pushNamed(context, '/faq');
              break;
            case 4:
              await _navigateToSalon(context);
              break;
            case 5:
              Navigator.pushNamed(context, '/don');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Cours"),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: "Contribution"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "FAQ"),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: "Salon privé"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Faire un don"),
        ],
      ),
    );
  }
}
