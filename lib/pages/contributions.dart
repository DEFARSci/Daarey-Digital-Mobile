import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Contributions extends StatefulWidget {
  const Contributions({super.key});

  @override
  State<Contributions> createState() => _ContributionsState();
}

class _ContributionsState extends State<Contributions>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? currentAudioPath;
  List hadiths = [];
  List dogmes = [];
  List bienseance = [];
  List oussoul = [];
  bool _isLoggedIn = false;

  final String staticAudioUrl = 'https://www.hadith.defarsci.fr/audios/1737634407.mp3';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 5, vsync: this);
    _checkLoginStatus();
    _fetchAllData();

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          isPlaying = (state == PlayerState.playing);
        });
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('auth_token') != null;
    });
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchHadiths(),
      _fetchDogmes(),
      _fetchBienseance(),
      _fetchOussoul(),
    ]);
  }

  Future<void> _fetchHadiths() async {
    try {
      final response = await http.get(Uri.parse('https://www.hadith.defarsci.fr/api/hadiths')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          hadiths = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement hadiths: $e");
    }
  }

  Future<void> _fetchDogmes() async {
    try {
      final response = await http.get(Uri.parse('https://www.hadith.defarsci.fr/api/dogmes')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          dogmes = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement dogmes: $e");
    }
  }

  Future<void> _fetchBienseance() async {
    try {
      final response = await http.get(Uri.parse('https://www.hadith.defarsci.fr/api/bienseance')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          bienseance = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement bienséance: $e");
    }
  }

  Future<void> _fetchOussoul() async {
    try {
      final response = await http.get(Uri.parse('https://www.hadith.defarsci.fr/api/oussoul')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          oussoul = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement oussoul: $e");
    }
  }

  Future<void> _toggleAudio(String audioPath) async {
    try {
      if (!isPlaying || currentAudioPath != audioPath) {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioPath));
        if (mounted) {
          setState(() {
            isPlaying = true;
            currentAudioPath = audioPath;
          });
        }
      } else {
        await _audioPlayer.pause();
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur de lecture audio")),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _audioPlayer.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToPrivateSection(BuildContext context) async {
    if (_isLoggedIn) {
      Navigator.pushNamed(context, '/salon');
    } else {
      final result = await Navigator.pushNamed(context, '/login');
      if (result == true && mounted) {
        await _checkLoginStatus();
      }
    }
  }

  Widget _buildList(List items, String type) {
    if (items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: beigeClair,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(item['titre'] ?? '$type sans titre', style: TextStyle(color: marron, fontWeight: FontWeight.bold)),
            subtitle: Text(item['description'] ?? 'Pas de description', style: TextStyle(color: marron.withOpacity(0.7))),
          ),
        );
      },
    );
  }

  Widget _buildHadithList() {
    if (hadiths.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: hadiths.length,
      itemBuilder: (context, index) {
        final hadith = hadiths[index];
        return Card(
          color: beigeClair,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hadith['titre'] ?? 'Sans titre',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: marron)),
                const SizedBox(height: 6),
                Text(hadith['contenu'] ?? 'Pas de contenu', style: TextStyle(color: marron)),
                if (hadith["audio"] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          currentAudioPath == hadith["audio"] && isPlaying ? Icons.pause : Icons.play_arrow,
                          color: marron,
                        ),
                        onPressed: () => _toggleAudio(hadith["audio"]),
                      ),
                      Text(
                        currentAudioPath == hadith["audio"] && isPlaying ? "Lecture en cours..." : "Écouter l'audio",
                        style: TextStyle(color: marron),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaticBiography() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Biographie du Prophète Muhammad (ﷺ)",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: marron,
            ),
          ),
          const SizedBox(height: 16),
          _buildSection("Naissance", "Il est né en 570 à La Mecque. Orphelin très tôt, il fut élevé par son grand-père puis son oncle."),
          _buildSection("Jeunesse et Mariage", "Connu pour son honnêteté, il fut surnommé 'Al-Amine'. Il épousa Khadija, une riche commerçante."),
          _buildSection("Révélation", "À 40 ans, l'ange Gabriel lui révéla le Coran. Il commença sa mission prophétique malgré l'opposition."),
          _buildSection("Hégire", "En 622, il migra à Médine. C'est l'événement marquant le début du calendrier islamique."),
          _buildSection("Conquête de La Mecque", "En 630, il revint victorieux à La Mecque et y proclama l'unicité d'Allah."),
          _buildSection("Dernier Sermon", "Il insista sur l'égalité, la justice, la piété et l'héritage du message divin."),
          _buildSection("Décès", "Il mourut en 632 à Médine, après avoir achevé sa mission et guidé l'humanité vers la lumière."),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: marron,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("Contributions"),
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: marron,
          labelColor: marron,
          unselectedLabelColor: marron.withOpacity(0.6),
          tabs: const [
            Tab(text: "Aqida"),
            Tab(text: "Hadiths"),
            Tab(text: "Bienséance"),
            Tab(text: "Oussoul"),
            Tab(text: "Biographie"),
          ],
        ),
      ),
      body: Column(
        children: [
          Card(
            color: beigeClair,
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: marron),
                onPressed: () => _toggleAudio(staticAudioUrl),
              ),
              title: Text("Écouter l'audio principal", style: TextStyle(color: marron)),
              subtitle: Text(isPlaying ? "Lecture en cours..." : "Appuyez pour écouter", style: TextStyle(color: marron.withOpacity(0.8))),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(dogmes, "Dogme"),
                _buildHadithList(),
                _buildList(bienseance, "Bienséance"),
                _buildList(oussoul, "Oussoul"),
                _buildStaticBiography(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: beigeClair,
        selectedItemColor: marron,
        unselectedItemColor: marron.withOpacity(0.6),
        currentIndex: 2,
        onTap: (index) async {
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
              await _navigateToPrivateSection(context);
              break;
            case 5:
              Navigator.pushNamed(context, '/don');
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          const BottomNavigationBarItem(icon: Icon(Icons.book), label: "Cours"),
          const BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: "Contributions"),
          const BottomNavigationBarItem(icon: Icon(Icons.help), label: "FAQ"),
          BottomNavigationBarItem(icon: Icon(_isLoggedIn ? Icons.lock_open : Icons.lock), label: "Salon privé"),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Faire un don"),
        ],
      ),
    );
  }
}
