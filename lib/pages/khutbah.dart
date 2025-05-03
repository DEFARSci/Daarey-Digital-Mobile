import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Khutbah extends StatefulWidget {
  const Khutbah({super.key});

  @override
  State<Khutbah> createState() => _KhutbahState();
}

class _KhutbahState extends State<Khutbah> {
  // Couleurs
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  // Contrôleur TTS
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  int? currentlyPlayingIndex;

  int _currentIndex = 2; // Index pour la page Khutbah

  // Liste des khutbahs
  final List<Map<String, dynamic>> khutbahList = [
    {
      'title': 'L\'importance de la patience',
      'titleAr': 'أهمية الصبر',
      'date': '10 Ramadan 1445',
      'category': 'Vie spirituelle',
      'textFr': """
**Introduction :**
Au nom d'Allah, le Tout Miséricordieux, le Très Miséricordieux.

La patience (As-Sabr) est une vertu centrale en Islam. Allah dit dans le Coran : 
"Ô vous qui croyez ! Cherchez secours dans la patience et la Salât, car Allah est avec ceux qui sont patients." (Sourate Al-Baqarah, 2:153)

**Développement :**
1. La patience face aux épreuves
2. La patience dans l'obéissance à Allah
3. La patience pour s'éloigner des péchés

**Conclusion :**
Le Prophète (ﷺ) a dit : "Quiconque s'efforce d'être patient, Allah lui donnera la patience." (Bukhari)
""",
      'textAr': """
**المقدمة :**
بسم الله الرحمن الرحيم

الصبر من أعظم الفضائل في الإسلام. قال تعالى: 
"يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ" (البقرة: 153)

**المحتوى :**
١. الصبر على الابتلاءات
٢. الصبر على طاعة الله
٣. الصبر عن المعاصي

**الخاتمة :**
قال النبي ﷺ: "ومن يتصبر يصبره الله" (البخاري)
""",
    },
    {
      'title': 'Les mérites du Ramadan',
      'titleAr': 'فضائل رمضان',
      'date': '1 Ramadan 1445',
      'category': 'Ramadan',
      'textFr': """
**Introduction :**
Le mois de Ramadan est un mois béni où les portes du Paradis sont ouvertes...
""",
      'textAr': """
**المقدمة :**
شهر رمضان شهر مبارك تُفتح فيه أبواب الجنة...
""",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setSpeechRate(0.5);
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
        currentlyPlayingIndex = null;
      });
    });
  }

  Future<void> _speak(String text, String language) async {
    await flutterTts.setLanguage(language == 'ar' ? "ar-SA" : "fr-FR");
    await flutterTts.speak(text);
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() {
      isPlaying = false;
      currentlyPlayingIndex = null;
    });
  }

  Future<void> _generateAndSavePdf(Map<String, dynamic> khutbah) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: khutbah['title']),
              pw.Header(level: 1, text: khutbah['titleAr']),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${khutbah['date']}'),
              pw.Divider(),
              pw.Header(level: 2, text: 'Français'),
              pw.Text(khutbah['textFr']),
              pw.SizedBox(height: 20),
              pw.Header(level: 2, text: 'العربية'),
              pw.Text(khutbah['textAr'], textDirection: pw.TextDirection.rtl),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/${khutbah['title']}.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text('Sermons & Khutbahs'),
        centerTitle: true,
        backgroundColor: beigeClair,
        foregroundColor: marron,
      ),
      body: ListView.builder(
        itemCount: khutbahList.length,
        itemBuilder: (context, index) {
          final khutbah = khutbahList[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            color: beigeClair,
            child: ExpansionTile(
              title: Text(
                khutbah['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: marron,
                ),
              ),
              subtitle: Text(
                khutbah['date'],
                style: TextStyle(color: marron.withOpacity(0.6)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Section Français avec bouton audio
                      _buildTextSection(
                        title: 'Français',
                        text: khutbah['textFr'],
                        language: 'fr',
                        isActive: currentlyPlayingIndex == index && isPlaying,
                        onPlay: () {
                          setState(() {
                            currentlyPlayingIndex = index;
                            isPlaying = true;
                          });
                          _speak(khutbah['textFr'], 'fr');
                        },
                        onStop: _stop,
                      ),

                      const SizedBox(height: 20),

                      // Section Arabe avec bouton audio
                      _buildTextSection(
                        title: 'العربية',
                        text: khutbah['textAr'],
                        language: 'ar',
                        isActive: currentlyPlayingIndex == index && isPlaying,
                        onPlay: () {
                          setState(() {
                            currentlyPlayingIndex = index;
                            isPlaying = true;
                          });
                          _speak(khutbah['textAr'], 'ar');
                        },
                        onStop: _stop,
                      ),

                      const SizedBox(height: 20),

                      // Boutons d'action
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.download),
                              label: const Text('Télécharger PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: marron,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _generateAndSavePdf(khutbah),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.share),
                              label: const Text('Partager'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: marron.withOpacity(0.8),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                // Fonctionnalité de partage
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                  context, '/', (route) => false);
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/mosquee', (route) => false);
              break;
            case 2:
            // Reste sur la page actuelle (Khutbah)
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

  Widget _buildTextSection({
    required String title,
    required String text,
    required String language,
    required bool isActive,
    required VoidCallback onPlay,
    required VoidCallback onStop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: marron)),
            const Spacer(),
            IconButton(
              icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
              color: marron,
              onPressed: isActive ? onStop : onPlay,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            color: marron,
            fontSize: language == 'ar' ? 18 : 16,
          ),
          textDirection: language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        ),
      ],
    );
  }
}