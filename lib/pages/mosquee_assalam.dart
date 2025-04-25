import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hijri/hijri_calendar.dart';

class MosqueeAssalam extends StatefulWidget {
  const MosqueeAssalam({super.key});

  @override
  State<MosqueeAssalam> createState() => _MosqueeAssalamState();
}

class _MosqueeAssalamState extends State<MosqueeAssalam> {
  final LatLng mosqueLocation = const LatLng(48.8566, 2.3522); // Paris, France
  int _currentIndex = 1; // Index pour la page Mosquée (ajustez selon votre besoin)

  final Map<String, String> prayerTimes = {
    "Fajr": "05:30",
    "Dhuhr": "13:00",
    "Asr": "16:30",
    "Maghrib": "18:45",
    "Isha": "20:00",
  };

  final List<String> upcomingEvents = [
    "Projet Madrassa au Sénégal - 15 Novembre 2025",
    "Conférence sur l'islam - 20 Novembre 2025",
    "Collecte de dons pour les nécessiteux - 25 Novembre 2025",
  ];

  String getHijriDate() {
    final hijriDate = HijriCalendar.now();
    return "${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}";
  }

  void _navigateToInscriptionForm(BuildContext context) {
    Navigator.pushNamed(context, '/formulaireinscription');
  }

  void _openRegistrationLink() async {
    const url = "https://www.hadith.defarsci.fr/inscription";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir le lien")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mosquée As Salam"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description de la mosquée
            const Text(
              "Description de la mosquée",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "La mosquée As Salam est un lieu de culte et d'apprentissage situé au cœur de la ville. "
                  "Elle propose des cours pour les enfants de 6 à 14 ans, ainsi que des activités communautaires.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Lien d'inscription
            Center(
              child: ElevatedButton(
                onPressed: () => _navigateToInscriptionForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF51B37F),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  "Inscription aux cours sur place (6-14 ans)",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Carte
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
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
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Horaires de prières
            const Text(
              "Horaires de prières",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...prayerTimes.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "${entry.key}: ${entry.value}",
                style: const TextStyle(fontSize: 16),
              ),
            )),
            const SizedBox(height: 20),

            // Date Hijri
            const Text(
              "Date du calendrier musulman",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Aujourd'hui: ${getHijriDate()}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Événements
            const Text(
              "Prochains événements",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...upcomingEvents.map((event) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "• $event",
                style: const TextStyle(fontSize: 16),
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF51B37F),
        unselectedItemColor: Colors.grey,
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
            // Reste sur la page actuelle (Mosquée)
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/khotba', (route) => false);
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
}