import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hijri/hijri_calendar.dart';
// **Nouvel import pour la date grégorienne**
import 'package:intl/intl.dart';

import 'actualite_details_page.dart';
import 'event_details.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> with WidgetsBindingObserver {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron     = Color(0xFF5D4C3B);

  late VideoPlayerController _videoController;
  late Future<void>           _initializeVideoPlayerFuture;
  late Future<List<dynamic>>  _actualites;
  late Future<List<dynamic>>  _events;
  late Future<Map<String,String>> _prayerTimesFuture;
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
      _actualites          = _fetchActualites();
      _events              = _fetchEvents();
      _prayerTimesFuture   = _fetchPrayerTimes();
    });
  }

  Future<List<dynamic>> _fetchActualites() async {
    final resp = await http.get(Uri.parse('https://www.hadith.defarsci.fr/api/actualites'));
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return [decoded];
      if (decoded is List) return decoded;
    }
    return [];
  }

  Future<List<dynamic>> _fetchEvents() async {
    final resp = await http.get(Uri.parse('https://www.hadith.defarsci.fr/api/events'));
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is List) return decoded;
    }
    return [];
  }

  Future<Map<String, String>> _fetchPrayerTimes() async {
    const lat = 48.8566, lon = 2.3522;
    final url = Uri.parse('https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lon&method=2');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data  = jsonDecode(resp.body);
      final times = data['data']['timings'];
      return {
        "Fajr":    times['Fajr'],
        "Dhuhr":   times['Dhuhr'],
        "Asr":     times['Asr'],
        "Maghrib": times['Maghrib'],
        "Isha":    times['Isha'],
      };
    }
    throw Exception("Erreur chargement prières ${resp.statusCode}");
  }

  String _getHijriDate() {
    final h = HijriCalendar.now();
    return "${h.hDay} ${h.longMonthName} ${h.hYear}";
  }

  @override
  void dispose() {
    _videoController.pause();
    _videoController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _videoController.pause();
    }
  }

  Widget _buildVideoSection() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.done) {
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
                      _videoController.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () => setState(() {
                      _videoController.value.isPlaying
                          ? _videoController.pause()
                          : _videoController.play();
                    }),
                  ),
                ),
              ],
            ),
          );
        }
        return Center(child: CircularProgressIndicator(color: marron));
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: marron
          )
      ),
    );
  }

  Widget _buildActualiteItem(dynamic a) {
    return Card(
      color: beigeClair,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActualiteDetailsPage(actualite: a)),
        ),
        child: ListTile(
          leading: a['video_url'] != null
              ? Icon(Icons.play_circle_fill, size: 40, color: marron)
              : Icon(Icons.article, size: 40, color: marron),
          title: Text(a['title'] ?? "Titre inconnu",
              style: TextStyle(fontWeight: FontWeight.bold, color: marron)
          ),
          subtitle: Text(
            (a['content'] ?? '').length > 80
                ? "${a['content'].substring(0,80)}…"
                : (a['content'] ?? "Pas de description"),
            style: TextStyle(color: marron.withOpacity(0.8)),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildEventItem(dynamic e) {
    return Card(
      color: beigeClair,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailsPage(event: e)),
        ),
        child: ListTile(
          leading: e['image_url'] != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "https://www.hadith.defarsci.fr/images/${e['image_url']}",
              width: 60, height: 60, fit: BoxFit.cover,
            ),
          )
              : Icon(Icons.event, size: 40, color: marron),
          title: Text(e['title'] ?? "Titre inconnu",
              style: TextStyle(fontWeight: FontWeight.bold, color: marron)
          ),
          subtitle: Text(e['content'] ?? "Sans description",
            style: TextStyle(color: marron.withOpacity(0.8)),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(Icons.chevron_right, color: marron),
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
    return CarouselSlider(
      options: CarouselOptions(height: 200, autoPlay: true, enlargeCenterPage: true),
      items: images.map((img) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
        ),
      )).toList(),
    );
  }

  Future<void> _navigateToSalon() async {
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
        backgroundColor: beigeClair,
        foregroundColor: marron,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildVideoSection(),
              FutureBuilder<Map<String,String>>(
                future: _prayerTimesFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snap.hasError || !snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("Impossible de charger les prières"),
                    );
                  }
                  final times = snap.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("Horaires de prières aujourd’hui",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: marron
                            )
                        ),
                        const SizedBox(height: 8),
                        ...times.entries.map((e) => Text(
                          "${e.key} : ${e.value}",
                          style: TextStyle(fontSize: 16, color: marron),
                        )),
                        const SizedBox(height: 16),

                        // **Date Hijri**
                        Text("Date du calendrier musulman",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: marron
                            )
                        ),
                        const SizedBox(height: 4),
                        Text(_getHijriDate(),
                          style: TextStyle(fontSize: 16, color: marron),
                        ),
                        const SizedBox(height: 16),

                        // **Date grégorienne**
                        Text("Date du calendrier grégorien",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: marron
                            )
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMMM yyyy').format(DateTime.now()),
                          style: TextStyle(fontSize: 16, color: marron),
                        ),

                        const Divider(thickness: 1, height: 16),
                      ],
                    ),
                  );
                },
              ),

              _buildSectionTitle("Nos actualités"),
              FutureBuilder<List<dynamic>>(
                future: _actualites,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    );
                  }
                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("Aucune actualité disponible"),
                    );
                  }
                  return Column(children: list.map(_buildActualiteItem).toList());
                },
              ),

              _buildSectionTitle("Événements à venir"),
              FutureBuilder<List<dynamic>>(
                future: _events,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    );
                  }
                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("Aucun événement à venir"),
                    );
                  }
                  return Column(children: list.map(_buildEventItem).toList());
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
        onTap: (idx) async {
          switch (idx) {
            case 0: break;
            case 1: Navigator.pushNamed(context, '/cours'); break;
            case 2: Navigator.pushNamed(context, '/contributions'); break;
            case 3: Navigator.pushNamed(context, '/faq'); break;
            case 4: await _navigateToSalon(); break;
            case 5: Navigator.pushNamed(context, '/don'); break;
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
