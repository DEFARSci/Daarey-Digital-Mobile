import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MosqueeAssalam extends StatefulWidget {
  const MosqueeAssalam({super.key});

  @override
  State<MosqueeAssalam> createState() => _MosqueeAssalamState();
}

class _MosqueeAssalamState extends State<MosqueeAssalam> {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron     = Color(0xFF5D4C3B);

  final LatLng mosqueLocation = const LatLng(48.8566, 2.3522); // Paris
  int _currentIndex = 1;

  final List<String> upcomingEvents = [
    "Projet Madrassa au Sénégal - 15 Novembre 2025",
    "Conférence sur l'islam - 20 Novembre 2025",
    "Collecte de dons pour les nécessiteux - 25 Novembre 2025",
  ];

  void _navigateToInscriptionForm(BuildContext context) {
    Navigator.pushNamed(context, '/formulaireinscription');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("Mosquée As Salam"),
        centerTitle: true,
        backgroundColor: beigeClair,
        foregroundColor: marron,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              "Description de la mosquée",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: marron,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "La mosquée As Salam est un lieu de culte et d'apprentissage situé au cœur de la ville. "
                  "Elle propose des cours pour les enfants de 6 à 14 ans, ainsi que des activités communautaires.",
              style: TextStyle(fontSize: 16, color: marron.withOpacity(0.7)),
            ),
            const SizedBox(height: 20),

            // Bouton inscription
            Center(
              child: ElevatedButton(
                onPressed: () => _navigateToInscriptionForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: beigeClair,
                  foregroundColor: marron,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  "Inscription aux cours sur place (6-14 ans)",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Carte
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: marron.withOpacity(0.3)),
              ),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: mosqueLocation,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: mosqueLocation,
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.location_pin,
                          color: marron,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Prochains événements
            Text(
              "Prochains événements",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: marron,
              ),
            ),
            const SizedBox(height: 8),
            ...upcomingEvents.map((event) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "• $event",
                style: TextStyle(fontSize: 16, color: marron),
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: beigeClair,
        selectedItemColor: marron,
        unselectedItemColor: marron.withOpacity(0.6),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/cours'); // Changement ici
              break;
            case 1:
            // reste sur Mosquée
              break;
            case 2:
              Navigator.pushNamed(context, '/khutbah'); // Changement ici
              break;
            case 3:
              Navigator.pushNamed(context, '/projet_madrassa'); // Changement ici
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.mosque), label: "Mosquée"),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Khoutba"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Projet Madrassa"),
        ],
      ),
    );
  }
}
