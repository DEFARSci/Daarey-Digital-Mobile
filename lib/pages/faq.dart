import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  int _currentThemeIndex = 0;

  final List<String> themes = [
    'Coran',
    'Sounah',
    'Prières',
    'l\'Islam',
    'le couple',
    'le travail',
    '...'
  ];

  List<dynamic> faqData = []; // Liste pour stocker les questions/réponses
  bool isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    fetchFAQ();
  }

  Future<void> fetchFAQ() async {
    try {
      final response = await http.get(Uri.parse("https://www.hadith.defarsci.fr/api/faq"));
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true) {
          setState(() {
            faqData = decodedResponse['data']; // On récupère seulement la liste de questions
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print("Erreur: Réponse API invalide");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("Erreur HTTP: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Erreur lors du chargement de la FAQ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic),
          ),
        ],
      ),

      body: Column(
        children: [
          // Themes
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: themes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentThemeIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _currentThemeIndex == index ? Color(0xFF51B37F) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        themes[index],
                        style: TextStyle(
                          color: _currentThemeIndex == index ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // Contenu de la FAQ
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Indicateur de chargement
              : Expanded(
            child: ListView.builder(
              itemCount: faqData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question
                      Text(
                        faqData[index]['question'] ?? "Question inconnue",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Réponse
                      Text(
                        faqData[index]['answer'] ?? "Réponse non disponible",
                        textAlign: TextAlign.justify,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(),
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
        selectedItemColor: Color(0xFF51B37F), // Couleur de l'élément sélectionné
        unselectedItemColor: Colors.grey, // Couleur des éléments non sélectionnés
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Cours"),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: "Hadith et Dogme"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "FAQ"),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: "Salon privé"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Faire un don"),
        ],
        currentIndex: 3,
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
              break; // Page actuelle
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
