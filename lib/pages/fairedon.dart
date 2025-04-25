import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Fairedon extends StatefulWidget {
  const Fairedon({Key? key}) : super(key: key);

  @override
  State<Fairedon> createState() => _FairedonState();
}

class _FairedonState extends State<Fairedon> with WidgetsBindingObserver {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  int _currentIndex = 5;
  String selectedOption = "10€";
  bool _isLoggedIn = false;
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('auth_token') != null;
    });
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset('assets/videos/fatiha.mp4');
    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
      _videoController.setLooping(true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _videoController.pause();
    } else if (state == AppLifecycleState.resumed && _videoController.value.isInitialized) {
      _videoController.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController.dispose();
    _customAmountController.dispose();
    super.dispose();
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

  Widget _buildVideoSection() {
    return SizedBox(
      height: 200,
      child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
                IconButton(
                  iconSize: 50,
                  icon: Icon(
                    _videoController.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _videoController.value.isPlaying
                          ? _videoController.pause()
                          : _videoController.play();
                    });
                  },
                ),
              ],
            );
          }
          return Center(child: CircularProgressIndicator(color: marron));
        },
      ),
    );
  }

  Widget _buildDonationOptions() {
    return Card(
      color: beigeClair,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Choisissez un montant",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: marron,
              ),
            ),
            const SizedBox(height: 16),
            ...['10€', '50€', '100€'].map((amount) {
              return RadioListTile(
                title: Text(amount, style: TextStyle(color: marron)),
                value: amount,
                groupValue: selectedOption,
                activeColor: marron,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value.toString();
                    _customAmountController.clear();
                  });
                },
              );
            }).toList(),
            RadioListTile(
              title: Row(
                children: [
                  Text("Autre montant: ", style: TextStyle(color: marron)),
                  Expanded(
                    child: TextField(
                      controller: _customAmountController,
                      style: TextStyle(color: marron),
                      decoration: InputDecoration(
                        hintText: "Entrez un montant",
                        hintStyle: TextStyle(color: marron.withOpacity(0.6)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: marron),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: marron),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            selectedOption = "custom";
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              value: "custom",
              groupValue: selectedOption,
              activeColor: marron,
              onChanged: (value) {
                setState(() {
                  selectedOption = value.toString();
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: marron,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                final amount = selectedOption == "custom"
                    ? _customAmountController.text
                    : selectedOption;
                _processDonation(amount);
              },
              child: Text(
                "Poursuivre le paiement",
                style: TextStyle(fontSize: 16, color: beigeClair),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processDonation(String amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: beigeClair,
        title: Text("Confirmation", style: TextStyle(color: marron)),
        content: Text(
          "Vous allez faire un don de $amount. Continuer?",
          style: TextStyle(color: marron),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: TextStyle(color: marron)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: marron),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Merci pour votre don de $amount !"),
                  backgroundColor: marron,
                ),
              );
            },
            child: Text("Confirmer", style: TextStyle(color: beigeClair)),
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
        title: const Text("Faire un Don"),
        backgroundColor: beigeClair,
        foregroundColor: marron,
        centerTitle: true,
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildVideoSection(),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Votre soutien nous permet de continuer notre mission",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: marron,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Chaque contribution, quelle que soit sa taille, fait une réelle différence pour notre communauté.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: marron),
              ),
            ),
            _buildDonationOptions(),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: beigeClair,
        selectedItemColor: marron,
        unselectedItemColor: marron.withOpacity(0.6),
        currentIndex: _currentIndex,
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
              Navigator.pushNamed(context, '/faq');
              break;
            case 4:
              await _navigateToPrivateSection(context);
              break;
            case 5:
              break; // Page actuelle
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Accueil",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Cours",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: "Contribution",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: "FAQ",
          ),
          BottomNavigationBarItem(
            icon: Icon(_isLoggedIn ? Icons.lock_open : Icons.lock),
            label: "Salon privé",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Faire un don",
          ),
        ],
      ),
    );
  }
}