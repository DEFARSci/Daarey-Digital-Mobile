import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  List<dynamic> faqData = [];
  bool isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchFAQ();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('auth_token') != null;
    });
  }

  Future<void> _fetchFAQ() async {
    try {
      final response = await http
          .get(Uri.parse("https://www.hadith.defarsci.fr/api/faq"))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            faqData = decodedResponse['data'] ??
                decodedResponse['faq'] ??
                decodedResponse['questions'] ??
                decodedResponse;
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
        _showErrorSnackbar("Erreur de chargement : ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      _showErrorSnackbar("Erreur de connexion");
      debugPrint("Erreur FAQ: $e");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
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

  Widget _buildFAQContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (faqData.isEmpty) {
      return const Center(child: Text("Aucune question disponible pour le moment"));
    }

    return ListView.builder(
      itemCount: faqData.length,
      itemBuilder: (context, index) {
        final item = faqData[index];
        final question = item['question'] ?? item['titre'] ?? item['text'] ?? "Question sans titre";
        final answer = item['answer'] ?? item['reponse'] ?? item['content'] ?? "Réponse non disponible";

        return ExpansionTile(
          title: Text(
            question,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: marron),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                answer,
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14, color: marron.withOpacity(0.8)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("FAQ"),
        centerTitle: true,
        backgroundColor: beigeClair,
        foregroundColor: marron,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {},
          // ),
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: _buildFAQContent(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: beigeClair,
        selectedItemColor: marron,
        unselectedItemColor: marron.withOpacity(0.6),
        currentIndex: 3,
        onTap: (index) async {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/');
              break;
            case 1:
              Navigator.pushNamed(context, '/cours');
              break;
            case 2:
              Navigator.pushNamed(context, '/contributions');
              break;
            case 3:
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
          const BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: "Contribution"),
          const BottomNavigationBarItem(icon: Icon(Icons.help), label: "FAQ"),
          BottomNavigationBarItem(
              icon: Icon(_isLoggedIn ? Icons.lock_open : Icons.lock), label: "Salon privé"),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Faire un don"),
        ],
      ),
    );
  }
}
