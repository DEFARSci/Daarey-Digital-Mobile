import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Contributions extends StatefulWidget {
  const Contributions({super.key});

  @override
  State<Contributions> createState() => _ContributionsState();
}

class _ContributionsState extends State<Contributions>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? currentAudioPath;

  List<Map<String, dynamic>> hadiths = [];
  List<Map<String, dynamic>> dogmes = [];
  List<Map<String, dynamic>> comportements = [];
  List<Map<String, dynamic>> oussouls = [];

  bool _isLoggedIn = false;
  int _currentTabIndex = 0;

  final String staticAudioUrl = 'https://www.hadith.defarsci.fr/audios/1737634407.mp3';

  // search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 5, vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(() => _currentTabIndex = _tabController.index);
        }
        _fetchAllData();
      });

    _checkLoginStatus();
    _fetchAllData();

    _audioPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => isPlaying = (s == PlayerState.playing));
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isLoggedIn = prefs.getString('auth_token') != null);
  }

  Future<void> _fetchAllData() => Future.wait([
    _fetchHadiths(),
    _fetchDogmes(),
    _fetchComportements(),
    _fetchOussouls(),
  ]);

  Future<void> _fetchHadiths() async {
    try {
      final r = await http
          .get(Uri.parse('https://www.hadith.defarsci.fr/api/hadiths'))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(r.body);
        setState(() {
          hadiths = jsonList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchDogmes() async {
    try {
      final r = await http
          .get(Uri.parse('https://www.hadith.defarsci.fr/api/dogmes'))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(r.body);
        setState(() {
          dogmes = jsonList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchComportements() async {
    try {
      final r = await http
          .get(Uri.parse('https://www.hadith.defarsci.fr/api/comportements'))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) {
        final dataList = (json.decode(r.body)['data'] as List<dynamic>);
        setState(() {
          comportements = dataList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchOussouls() async {
    try {
      final r = await http
          .get(Uri.parse('https://www.hadith.defarsci.fr/api/oussouls'))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) {
        final dataList = (json.decode(r.body)['data'] as List<dynamic>);
        setState(() {
          oussouls = dataList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    await _audioPlayer.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }

  Future<void> _toggleAudio(String url) async {
    if (!isPlaying || currentAudioPath != url) {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        isPlaying = true;
        currentAudioPath = url;
      });
    } else {
      await _audioPlayer.pause();
      setState(() => isPlaying = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("Contributions"),
        centerTitle: true,
        backgroundColor: beigeClair,
        foregroundColor: marron,
        actions: [
          if (_isLoggedIn)
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: marron,
          labelColor: marron,
          unselectedLabelColor: marron.withOpacity(0.6),
          tabs: const [
            Tab(text: "Aqida"),
            Tab(text: "Hadiths"),
            Tab(text: "Bienséance"),
            Tab(text: "Oussouls"),
            Tab(text: "Biographie"),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_currentTabIndex == 1)
            Card(
              color: beigeClair,
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                      color: marron),
                  onPressed: () => _toggleAudio(staticAudioUrl),
                ),
                title: Text("Écouter l'audio principal",
                    style: TextStyle(color: marron)),
                subtitle: Text(
                  isPlaying ? "Lecture en cours..." : "Appuyez pour écouter",
                  style: TextStyle(color: marron.withOpacity(0.8)),
                ),
              ),
            ),

          if (_currentTabIndex != 4)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher…",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (q) =>
                    setState(() => _searchQuery = q.trim().toLowerCase()),
              ),
            ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_filterList(dogmes), "Dogme"),
                _buildHadithList(),
                _buildList(_filterList(comportements), "Bienséance"),
                _buildList(_filterList(oussouls), "Oussoul"),
                _buildDetailedBiography(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: beigeClair,
        selectedItemColor: marron,
        unselectedItemColor: marron.withOpacity(0.6),
        currentIndex: 2,
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushNamed(context, '/');
              break;
            case 1:
              Navigator.pushNamed(context, '/cours');
              break;
            case 2:
              break;
            case 3:
              Navigator.pushNamed(context, '/faq');
              break;
            case 4:
              Navigator.pushNamed(context, '/salon');
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          const BottomNavigationBarItem(icon: Icon(Icons.book), label: "Cours"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism), label: "Contributions"),
          const BottomNavigationBarItem(icon: Icon(Icons.help), label: "FAQ"),
          BottomNavigationBarItem(
            icon: Icon(_isLoggedIn ? Icons.lock_open : Icons.lock),
            label: "Salon privé",
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterList(List<Map<String, dynamic>> items) {
    if (_searchQuery.isEmpty) return items;
    return items.where((item) {
      final text = [
        item['title']?.toString() ?? "",
        item['content']?.toString() ?? "",
        item['description']?.toString() ?? "",
        item['definition']?.toString() ?? "",
        item['nom']?.toString() ?? ""
      ].join(" ").toLowerCase();
      return text.contains(_searchQuery);
    }).toList();
  }

  Widget _buildList(List<Map<String, dynamic>> items, String type) {
    if (items.isEmpty) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (c, i) {
        final item = items[i];
        late String titre, desc;
        if (type == "Dogme") {
          titre = item['title'] ?? "";
          desc = item['content'] ?? "";
        } else if (type == "Bienséance") {
          titre = item['title'] ?? "";
          desc = item['description'] ?? "";
        } else if (type == "Oussoul") {
          titre = item['nom'] ?? "";
          desc = item['definition'] ?? "";
        } else {
          titre = item['title'] ?? item['nom'] ?? "";
          desc = item['description'] ?? item['definition'] ?? "";
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: beigeClair,
          child: ListTile(
            title: Text(titre,
                style: TextStyle(color: marron, fontWeight: FontWeight.bold)),
            subtitle: Text(desc, style: TextStyle(color: marron.withOpacity(0.7))),
          ),
        );
      },
    );
  }

  Widget _buildHadithList() {
    final filtered = _searchQuery.isEmpty
        ? hadiths
        : hadiths.where((h) {
      final all = "${h['title'] ?? ''} ${h['content'] ?? ''}".toLowerCase();
      return all.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (c, i) {
        final h = filtered[i];
        return Card(
          color: beigeClair,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h['title'] ?? '',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, color: marron)),
                const SizedBox(height: 6),
                Text(h['content'] ?? '', style: TextStyle(color: marron)),
                if (h['audio_url'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          currentAudioPath == h['audio_url'] && isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: marron,
                        ),
                        onPressed: () => _toggleAudio(h['audio_url']),
                      ),
                      Text(
                        currentAudioPath == h['audio_url'] && isPlaying
                            ? "Lecture en cours..."
                            : "Écouter l'audio",
                        style: TextStyle(color: marron),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget pour afficher la biographie détaillée (inchangé)
  Widget _buildDetailedBiography() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth >= 600;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chronologie
              Container(
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: beigeClair,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Chronologie",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: marron,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildChronologyItem("570", "Naissance à La Mecque"),
                    _buildChronologyItem("576", "Orphelin – pris en charge par son grand-père Abd al-Muttalib"),
                    _buildChronologyItem("578", "Décès du grand-père – élevé par son oncle Abu Talib"),
                    _buildChronologyItem("595", "Mariage avec Khadija"),
                    _buildChronologyItem("610", "Première révélation dans la grotte de Hira"),
                    _buildChronologyItem("613", "Début de la prédication publique"),
                    _buildChronologyItem("619", "Année de la tristesse – décès de Khadija et Abu Talib"),
                    _buildChronologyItem("620", "Voyage nocturne (Isra et Mi’raj)"),
                    _buildChronologyItem("622", "Hégire (migration vers Médine)"),
                    _buildChronologyItem("624", "Bataille de Badr"),
                    _buildChronologyItem("625", "Bataille d’Uhud"),
                    _buildChronologyItem("627", "Bataille du Fossé"),
                    _buildChronologyItem("628", "Traité de Hudaybiyya"),
                    _buildChronologyItem("630", "Conquête de La Mecque"),
                    _buildChronologyItem("632", "Pèlerinage d’adieu et décès à Médine"),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Biographie détaillée
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Biographie du Prophète Muhammad (ﷺ)",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: marron,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      "Naissance et enfance",
                      "Muhammad ibn Abdullah (ﷺ) est né à La Mecque, en Arabie, en l’an 570 après J.-C., année connue comme “l’Année de l’Éléphant”. Il est né au sein de la tribu des Quraysh, une tribu respectée qui gardait la Kaaba. Son père, Abdullah, mourut avant sa naissance, et sa mère, Amina, décéda lorsqu’il avait six ans. Orphelin, il fut d’abord élevé par son grand-père Abd al-Muttalib, puis par son oncle Abu Talib.\n\n"
                          "Dès son jeune âge, Muhammad (ﷺ) était connu pour son honnêteté, sa fiabilité et son intégrité, ce qui lui valut le surnom d’“Al-Amine” (le digne de confiance). Il travaillait comme berger dans sa jeunesse, puis devint un marchand respecté.",
                    ),
                    _buildSection(
                      "Mariage avec Khadija",
                      "À l’âge de 25 ans, Muhammad (ﷺ) fut employé par Khadija, une riche veuve et commerçante respectée, pour conduire ses caravanes commerciales. Impressionnée par son caractère et son honnêteté, Khadija proposa le mariage à Muhammad (ﷺ). Malgré leur différence d’âge (elle avait 40 ans), leur union fut heureuse et dura 25 ans, jusqu’au décès de Khadija. Pendant cette période, ils eurent plusieurs enfants, dont Fatima, la seule qui survécut et eut une descendance.\n\n"
                          "“Par Allah, Il ne vous humiliera jamais. Vous maintenez les liens de parenté, vous supportez les faibles, vous aidez les nécessiteux, vous honorez vos invités et vous secourez les affligés par les calamités.”\n\n"
                          "— Khadija à Muhammad (ﷺ) après sa première révélation",
                    ),
                    _buildSection(
                      "La révélation",
                      "Muhammad (ﷺ) avait l’habitude de se retirer dans la grotte de Hira sur le mont An-Nur près de La Mecque pour méditer. C’est là qu’à l’âge de 40 ans, en 610, l’ange Gabriel lui apparut et lui transmit les premiers versets du Coran, marquant le début de sa mission prophétique. Effrayé par cette expérience, il retourna auprès de Khadija qui le réconforta et fut la première à embrasser l’Islam.\n\n"
                          "Pendant les trois premières années, Muhammad (ﷺ) prêcha l’Islam en secret à ses proches. Puis il reçut l’ordre divin de proclamer publiquement son message. Face à l’hostilité croissante des Mecquois, qui voyaient dans l’Islam une menace pour leur mode de vie et leurs intérêts économiques, les musulmans subirent persécutions et boycott.",
                    ),
                    _buildSection(
                      "L’Hégire et l’établissement à Médine",
                      "En 622, face aux persécutions croissantes à La Mecque, Muhammad (ﷺ) et ses compagnons émigrèrent à Yathrib (plus tard renommée Médine), un événement connu sous le nom d’Hégire, qui marque le début du calendrier islamique. À Médine, Muhammad (ﷺ) établit la première communauté musulmane organisée et jeta les bases d’un État islamique.\n\n"
                          "Il unifia les tribus de Médine, établit une constitution (la Charte de Médine) garantissant les droits des musulmans et des non-musulmans, et commença à former une société basée sur les principes de justice, d’égalité et de fraternité.",
                    ),
                    _buildSection(
                      "Les dernières années et l’héritage",
                      "En 630, après plusieurs années de conflits avec les Mecquois, Muhammad (ﷺ) retourna à La Mecque avec une armée de 10 000 hommes. La ville se rendit sans combat, et il pardonna à ses anciens persécuteurs, montrant une clémence remarquable. Il purifia la Kaaba des idoles et la consacra à l’adoration d’Allah seul.\n\n"
                          "En 632, Muhammad (ﷺ) accomplit son pèlerinage d’adieu et prononça son dernier sermon, rappelant les principes fondamentaux de l’Islam et l’égalité de tous les êtres humains. Peu après son retour à Médine, il tomba malade et décéda dans les bras de son épouse Aisha. Il fut enterré dans sa chambre, à l’emplacement actuel de la Mosquée du Prophète à Médine.\n\n"
                          "“Ô hommes ! Votre Seigneur est unique et votre ancêtre est unique. Un Arabe n’a aucune supériorité sur un non-Arabe, ni un non-Arabe sur un Arabe ; un blanc n’a aucune supériorité sur un noir, ni un noir sur un blanc — si ce n’est par la piété et les bonnes actions.”\n\n"
                          "— Extrait du Sermon d’Adieu",
                    ),
                    _buildSection(
                      "Caractère et enseignements",
                      "Muhammad (ﷺ) était connu pour sa simplicité, sa modestie et sa compassion. Malgré sa position de chef d’État et de guide spirituel, il vivait modestement, partageait les tâches ménagères, raccommodait ses vêtements et participait aux travaux collectifs. Il était accessible à tous, accordant une attention particulière aux faibles et aux marginalisés.\n\n"
                          "Ses enseignements ont transformé l’Arabie et, par la suite, une grande partie du monde. Il a prêché l’unicité de Dieu (tawhid), l’égalité des êtres humains, la justice sociale, la compassion envers toutes les créatures et l’importance du savoir. Son message, consigné dans le Coran et les Hadiths, continue d’inspirer et de guider plus de 1,8 milliard de musulmans à travers le monde.",
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chronologie pour écran étroit
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: beigeClair,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Chronologie",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: marron,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildChronologyItem("570", "Naissance à La Mecque"),
                    _buildChronologyItem("576", "Orphelin – pris en charge par son grand-père Abd al-Muttalib"),
                    _buildChronologyItem("578", "Décès du grand-père – élevé par son oncle Abu Talib"),
                    _buildChronologyItem("595", "Mariage avec Khadija"),
                    _buildChronologyItem("610", "Première révélation dans la grotte de Hira"),
                    _buildChronologyItem("613", "Début de la prédication publique"),
                    _buildChronologyItem("619", "Année de la tristesse – décès de Khadija et Abu Talib"),
                    _buildChronologyItem("620", "Voyage nocturne (Isra et Mi’raj)"),
                    _buildChronologyItem("622", "Hégire (migration vers Médine)"),
                    _buildChronologyItem("624", "Bataille de Badr"),
                    _buildChronologyItem("625", "Bataille d’Uhud"),
                    _buildChronologyItem("627", "Bataille du Fossé"),
                    _buildChronologyItem("628", "Traité de Hudaybiyya"),
                    _buildChronologyItem("630", "Conquête de La Mecque"),
                    _buildChronologyItem("632", "Pèlerinage d’adieu et décès à Médine"),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Biographie du Prophète Muhammad (ﷺ)",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: marron,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                "Naissance et enfance",
                "Muhammad ibn Abdullah (ﷺ) est né à La Mecque, en Arabie, en l’an 570 après J.-C., année connue comme “l’Année de l’Éléphant”. Il est né au sein de la tribu des Quraysh, une tribu respectée qui gardait la Kaaba. Son père, Abdullah, mourut avant sa naissance, et sa mère, Amina, décéda lorsqu’il avait six ans. Orphelin, il fut d’abord élevé par son grand-père Abd al-Muttalib, puis par son oncle Abu Talib.\n\n"
                    "Dès son jeune âge, Muhammad (ﷺ) était connu pour son honnêteté, sa fiabilité et son intégrité, ce qui lui valut le surnom d’“Al-Amine” (le digne de confiance). Il travaillait comme berger dans sa jeunesse, puis devint un marchand respecté.",
              ),
              _buildSection(
                "Mariage avec Khadija",
                "À l’âge de 25 ans, Muhammad (ﷺ) fut employé par Khadija, une riche veuve et commerçante respectée, pour conduire ses caravanes commerciales. Impressionnée par son caractère et son honnêteté, Khadija proposa le mariage à Muhammad (ﷺ). Malgré leur différence d’âge (elle avait 40 ans), leur union fut heureuse et dura 25 ans, jusqu’au décès de Khadija. Pendant cette période, ils eurent plusieurs enfants, dont Fatima, la seule qui survécut et eut une descendance.\n\n"
                    "“Par Allah, Il ne vous humiliera jamais. Vous maintenez les liens de parenté, vous supportez les faibles, vous aidez les nécessiteux, vous honorez vos invités et vous secourez les affligés par les calamités.”\n\n"
                    "— Khadija à Muhammad (ﷺ) après sa première révélation",
              ),
              _buildSection(
                "La révélation",
                "Muhammad (ﷺ) avait l’habitude de se retirer dans la grotte de Hira sur le mont An-Nur près de La Mecque pour méditer. C’est là qu’à l’âge de 40 ans, en 610, l’ange Gabriel lui apparut et lui transmit les premiers versets du Coran, marquant le début de sa mission prophétique. Effrayé par cette expérience, il retourna auprès de Khadija qui le réconforta et fut la première à embrasser l’Islam.\n\n"
                    "Pendant les trois premières années, Muhammad (ﷺ) prêcha l’Islam en secret à ses proches. Puis il reçut l’ordre divin de proclamer publiquement son message. Face à l’hostilité croissante des Mecquois, qui voyaient dans l’Islam une menace pour leur mode de vie et leurs intérêts économiques, les musulmans subirent persécutions et boycott.",
              ),
              _buildSection(
                "L’Hégire et l’établissement à Médine",
                "En 622, face aux persécutions croissantes à La Mecque, Muhammad (ﷺ) et ses compagnons émigrèrent à Yathrib (plus tard renommée Médine), un événement connu sous le nom d’Hégire, qui marque le début du calendrier islamique. À Médine, Muhammad (ﷺ) établit la première communauté musulmane organisée et jeta les bases d’un État islamique.\n\n"
                    "Il unifia les tribus de Médine, établit une constitution (la Charte de Médine) garantissant les droits des musulmans et des non-musulmans, et commença à former une société basée sur les principes de justice, d’égalité et de fraternité.",
              ),
              _buildSection(
                "Les dernières années et l’héritage",
                "En 630, après plusieurs années de conflits avec les Mecquois, Muhammad (ﷺ) retourna à La Mecque avec une armée de 10 000 hommes. La ville se rendit sans combat, et il pardonna à ses anciens persécuteurs, montrant une clémence remarquable. Il purifia la Kaaba des idoles et la consacra à l’adoration d’Allah seul.\n\n"
                    "En 632, Muhammad (ﷺ) accomplit son pèlerinage d’adieu et prononça son dernier sermon, rappelant les principes fondamentaux de l’Islam et l’égalité de tous les êtres humains. Peu après son retour à Médine, il tomba malade et décéda dans les bras de son épouse Aisha. Il fut enterré dans sa chambre, à l’emplacement actuel de la Mosquée du Prophète à Médine.\n\n"
                    "“Ô hommes ! Votre Seigneur est unique et votre ancêtre est unique. Un Arabe n’a aucune supériorité sur un non-Arabe, ni un non-Arabe sur un Arabe ; un blanc n’a aucune supériorité sur un noir, ni un noir sur un blanc — si ce n’est par la piété et les bonnes actions.”\n\n"
                    "— Extrait du Sermon d’Adieu",
              ),
              _buildSection(
                "Caractère et enseignements",
                "Muhammad (ﷺ) était connu pour sa simplicité, sa modestie et sa compassion. Malgré sa position de chef d’État et de guide spirituel, il vivait modestement, partageait les tâches ménagères, raccommodait ses vêtements et participait aux travaux collectifs. Il était accessible à tous, accordant une attention particulière aux faibles et aux marginalisés.\n\n"
                    "Ses enseignements ont transformé l’Arabie et, par la suite, une grande partie du monde. Il a prêché l’unicité de Dieu (tawhid), l’égalité des êtres humains, la justice sociale, la compassion envers toutes les créatures et l’importance du savoir. Son message, consigné dans le Coran et les Hadiths, continue d’inspirer et de guider plus de 1,8 milliard de musulmans à travers le monde.",
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// Helper pour chaque item de chronologie
  Widget _buildChronologyItem(String year, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Petit rond marron
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: marron,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$year – ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: marron,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: TextStyle(
                      color: marron.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: marron,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: marron.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
