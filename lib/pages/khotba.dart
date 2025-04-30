import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class Khotba extends StatefulWidget {
  const Khotba({Key? key}) : super(key: key);

  @override
  State<Khotba> createState() => _KhotbaState();
}

class _KhotbaState extends State<Khotba> {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  bool isPlaying = false;
  int _currentIndex = 2; // Index pour la page Khoutba

  final List<Map<String, dynamic>> khoutbas = [
    {
      'id': 'virtue-of-remembrance',
      'title': 'La vertu du dhikr',
      'titleAr': 'فضل الذكر',
      'date': '10 Shawwal 1445',
      'imam': 'Cheikh Abdallah',
      'text': '''
إِنَّ الْحَمْدَ لِلَّهِ ,نَحْمَدُهُ ,وَنَسْتَعِينُهُ وَنَسْتَغْفِرُهُ , وَنَعُوذُ بِاللهِ مِنْ شُرُورِ أَنْفُسِنَا وَمِنْ سَيِّئَاتِ أَعْمَالِنَا ,مَنْ يَهْدِهِ اللهُ فَلَا مُضِلَّ لَهُ , وَمَنْ يُضْلِلْ فَلَا هَادِيَ لَهُ , وَأَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ    

Louanges à Allah. Nous Le louons, implorons Son secours et implorons Son pardon...
[Votre texte complet...]
''',
      'video': '9XaS5WjJ4zY',
      'category': 'Spiritualité',
      'views': 1245,
      'duration': '25 min',
    },
  ];

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio(String text) async {
    if (isPlaying) {
      await audioPlayer.stop();
      setState(() => isPlaying = false);
    } else {
      _showAudioDialog(context, text);
      setState(() => isPlaying = true);
    }
  }

  void _showAudioDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: beigeClair,
        title: Text(
          'Lecture audio',
          style: TextStyle(color: marron),
        ),
        content: SingleChildScrollView(
          child: Text(
            text,
            style: TextStyle(color: marron),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.stop : Icons.play_arrow,
              color: marron,
            ),
            onPressed: () => _toggleAudio(text),
          ),
          TextButton(
            child: Text(
              'Fermer',
              style: TextStyle(color: marron),
            ),
            onPressed: () {
              audioPlayer.stop();
              Navigator.pop(context);
              setState(() => isPlaying = false);
            },
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
        title: const Text('Khoutbas du Vendredi'),
        centerTitle: true,
        backgroundColor: beigeClair,
        foregroundColor: marron,
      ),
      body: ListView.builder(
        itemCount: khoutbas.length,
        itemBuilder: (context, index) {
          final khoutba = khoutbas[index];
          return Card(
            margin: const EdgeInsets.all(8),
            color: beigeClair,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    khoutba['title'],
                    style: TextStyle(color: marron, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    khoutba['titleAr'],
                    style: TextStyle(color: marron.withOpacity(0.7)),
                  ),
                  trailing: Text(
                    khoutba['date'],
                    style: TextStyle(color: marron),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    khoutba['text'].split('\n').take(4).join('\n'),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: marron),
                  ),
                ),
                ButtonBar(
                  children: [
                    IconButton(
                      icon: Icon(Icons.article, color: marron),
                      onPressed: () => _showFullText(context, khoutba['text']),
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.stop : Icons.audiotrack,
                        color: marron,
                      ),
                      onPressed: () => _toggleAudio(khoutba['text']),
                    ),
                    IconButton(
                      icon: Icon(Icons.videocam, color: marron),
                      onPressed: () => _playVideo(context, khoutba),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: beigeClair,
        selectedItemColor: marron,
        unselectedItemColor: marron.withOpacity(0.6),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/mosquee', (route) => false);
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/mosquee', (route) => false);
              break;
            case 2:
            // Reste sur la page actuelle (Khoutba)
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

  void _showFullText(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: beigeClair,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.9,
        child: SingleChildScrollView(
          child: Text(
            text,
            style: TextStyle(color: marron),
          ),
        ),
      ),
    );
  }

  void _playVideo(BuildContext context, Map<String, dynamic> khoutba) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(khoutba['title']),
            backgroundColor: beigeClair,
            foregroundColor: marron,
          ),
          backgroundColor: beigeMoyen,
          body: YoutubePlayer(
            controller: YoutubePlayerController(
              initialVideoId: khoutba['video'],
              flags: const YoutubePlayerFlags(
                autoPlay: true,
                mute: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}