import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  int? currentlyPlayingIndex;

  int _currentIndex = 2;

  List<dynamic> khutbahList = [];
  List<dynamic> filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initTts();
    _fetchKhutbahs();
    _searchController.addListener(_filterKhutbahs);
  }

  Future<void> _fetchKhutbahs() async {
    try {
      final response = await http.get(Uri.parse("https://www.hadith.defarsci.fr/api/khoutbas"));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List data = jsonData['data'];
        setState(() {
          khutbahList = data;
          filteredList = data;
        });
      } else {
        throw Exception("Erreur de chargement des khoutbas");
      }
    } catch (e) {
      debugPrint("Erreur API: $e");
    }
  }

  void _filterKhutbahs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredList = khutbahList.where((khutbah) {
        return khutbah['titre'].toString().toLowerCase().contains(query) ||
            khutbah['contenu'].toString().toLowerCase().contains(query);
      }).toList();
    });
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
              pw.Header(level: 0, text: khutbah['titre'] ?? ''),
              pw.SizedBox(height: 20),
              pw.Text("Date: ${khutbah['date'] ?? ''}"),
              pw.Divider(),
              pw.Header(level: 2, text: 'Contenu'),
              pw.Text(_htmlToPlainText(khutbah['contenu'] ?? '')),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/${khutbah['titre']}.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  String _htmlToPlainText(String? htmlString) {
    if (htmlString == null) return '';
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlString.replaceAll(regex, '').replaceAll('&nbsp;', ' ').trim();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un sermon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: beigeClair,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final khutbah = filteredList[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: beigeClair,
                  child: ExpansionTile(
                    title: Text(
                      khutbah['titre'] ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold, color: marron),
                    ),
                    subtitle: Text(
                      khutbah['date'] ?? '',
                      style: TextStyle(color: marron.withOpacity(0.6)),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildTextSection(
                              title: 'Contenu',
                              text: _htmlToPlainText(khutbah['contenu'] ?? ''),
                              language: 'fr',
                              isActive: currentlyPlayingIndex == index && isPlaying,
                              onPlay: () {
                                setState(() {
                                  currentlyPlayingIndex = index;
                                  isPlaying = true;
                                });
                                _speak(_htmlToPlainText(khutbah['contenu'] ?? ''), 'fr');
                              },
                              onStop: _stop,
                            ),
                            const SizedBox(height: 20),
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
                                    onPressed: () {},
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
          ),
        ],
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
              Navigator.pushNamedAndRemoveUntil(context, '/cours', (route) => false);
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(context, '/mosquee', (route) => false);
              break;
            case 2:
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(context, '/projet_madrassa', (route) => false);
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
          style: TextStyle(color: marron, fontSize: language == 'ar' ? 18 : 16),
          textDirection: language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        ),
      ],
    );
  }
}
