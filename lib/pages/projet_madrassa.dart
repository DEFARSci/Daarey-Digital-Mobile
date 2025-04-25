import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjetMadrassa extends StatefulWidget {
  const ProjetMadrassa({super.key});

  @override
  State<ProjetMadrassa> createState() => _ProjetMadrassaState();
}

class _ProjetMadrassaState extends State<ProjetMadrassa> {
  final double targetAmount = 100000.0;
  double collectedAmount = 42500.0; // Montant déjà collecté (exemple)

  final String pdfPlanUrl = 'https://example.com/plan_madrassa.pdf';
  final String donationUrl = 'https://example.com/dons-madrassa';

  Future<void> _launchPdf() async {
    if (await canLaunchUrl(Uri.parse(pdfPlanUrl))) {
      await launchUrl(Uri.parse(pdfPlanUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le PDF')),
      );
    }
  }

  Future<void> _launchDonation() async {
    if (await canLaunchUrl(Uri.parse(donationUrl))) {
      await launchUrl(Uri.parse(donationUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir la page de dons')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (collectedAmount / targetAmount) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projet Madrassa Sénégal'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image d'en-tête
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/madrassa.jpg', // Remplacez par votre image
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Description du projet
            const Text(
              'Description du projet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Le projet Madrassa au Sénégal vise à construire une école islamique moderne dans la région de Dakar. '
                  'Ce centre éducatif accueillera 300 élèves et offrira un programme équilibré entre enseignement religieux '
                  'et matières académiques standards. Le complexe comprendra des salles de classe, une bibliothèque, '
                  'un espace de prière et des installations sportives.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Plan de l'école
            const Text(
              'Plan du projet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Voir les plans PDF'),
              onPressed: _launchPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Objectif de collecte
            const Text(
              'Objectif de financement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${collectedAmount.toStringAsFixed(0)}€ / ${targetAmount.toStringAsFixed(0)}€',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercentage / 100,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercentage >= 100 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progressPercentage.toStringAsFixed(1)}% de l\'objectif atteint',
              style: TextStyle(
                color: progressPercentage >= 100 ? Colors.green : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Bouton de don
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.favorite),
                label: const Text('Faire un don spécifique au projet'),
                onPressed: _launchDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF51B37F),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Galerie photo (optionnel)
            const Text(
              'Avancement des travaux',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildProgressImage('assets/construction1.jpg'),
                  _buildProgressImage('assets/construction2.jpg'),
                  _buildProgressImage('assets/construction3.jpg'),
                ],
              ),
            ),
          ],
        ),
      ),
      // Barre de navigation identique aux autres pages
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF51B37F),
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // Index pour Projet Madrassa
        onTap: (index) {
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
              Navigator.pushNamedAndRemoveUntil(
                  context, '/khotba', (route) => false);
              break;
            case 3:
            // Déjà sur la page Projet Madrassa
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

  Widget _buildProgressImage(String assetPath) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          assetPath,
          width: 160,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}