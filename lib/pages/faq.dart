import 'package:flutter/material.dart';

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 5 onglets
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
        // bottom: TabBar(
        //   controller: _tabController,
        //   tabs: const [
        //     Tab(text: "Accueil"),
        //     Tab(text: "Cours"),
        //     Tab(text: "Hadiths et Dogmes"),
        //     Tab(text: "FAQ"),
        //     Tab(text: "Salon privé"),
        //   ],
        // ),
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
                      color: _currentThemeIndex == index
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        themes[index],
                        style: TextStyle(
                          color: _currentThemeIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          // Premier Expanded
          Expanded(
            child: PageView.builder(
              itemCount: 5, // Nombre de questions (exemple)
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Aligner à gauche
                    children: [
                      // Texte de la question/réponse
                      Text(
                        "Lorem Ipsum is simply dummy text of the printing "
                            "and typesetting industry. Lorem Ipsum has been the "
                            "industry's standard dummy text ever since the 1500s, "
                            "when an unknown printer took a galley...",
                        textAlign: TextAlign.justify,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16), // Espacement entre texte et boutons
                      // Boutons (Reculer, Lire, Avancer)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.fast_rewind),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Espacement réduit entre les deux Expanded
          const SizedBox(height: 8), // Hauteur ajustée ici
          // Deuxième Expanded
          Expanded(
            child: PageView.builder(
              itemCount: 5, // Nombre de questions (exemple)
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Aligner à gauche
                    children: [
                      // Texte de la question/réponse
                      Text(
                        "Lorem Ipsum is simply dummy text of the printing "
                            "and typesetting industry. Lorem Ipsum has been the "
                            "industry's standard dummy text ever since the 1500s, "
                            "when an unknown printer took a galley...",
                        textAlign: TextAlign.justify,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16), // Espacement entre texte et boutons
                      // Boutons (Reculer, Lire, Avancer)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.fast_rewind),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ],
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
