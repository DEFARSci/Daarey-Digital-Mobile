import 'package:flutter/material.dart';

class Salonprive extends StatefulWidget {
  const Salonprive({super.key});

  @override
  State<Salonprive> createState() => _SalonpriveState();
}

class _SalonpriveState extends State<Salonprive> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salon privé"),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            // Section Titre
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "Bienvenue dans l'ESPACE PRIVE",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 100),

            // Formulaire d'accès
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Identifiant",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Mot de passe",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 37),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Logique de connexion
                        },
                        child: const Text("Connexion"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register'); // Naviguer vers la page Register
                        },
                        child: const Text("S'inscrire"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // Barre de navigation
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
        currentIndex: 4, // Indice correspondant à "Salon privé"
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
              Navigator.pushNamed(context, '/faq');
              break;
            case 4:
            // Déjà sur "Salon privé", pas de navigation
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
