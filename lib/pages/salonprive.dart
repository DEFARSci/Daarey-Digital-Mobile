import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Salonprive extends StatefulWidget {
  const Salonprive({super.key});

  @override
  State<Salonprive> createState() => _SalonpriveState();
}

class _SalonpriveState extends State<Salonprive> {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  List<dynamic> forums = [];
  List<dynamic> threads = [];
  List<dynamic> posts = [];
  int? selectedForumId;
  int? selectedThreadId;
  String currentUserName = 'Utilisateur';
  int currentUserId = 0;
  bool isLoading = false;

  // ─── Recherche ─────────────────────────────────────────────────────
  List<dynamic> _filteredForums = [];
  List<dynamic> _filteredThreads = [];
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _threadTitleController = TextEditingController();
  final TextEditingController _postContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (selectedForumId == null) {
        _filteredForums = forums.where((f) {
          final name = (f['name'] ?? '').toString().toLowerCase();
          return name.contains(query);
        }).toList();
      } else if (selectedThreadId == null) {
        _filteredThreads = threads.where((t) {
          final title = (t['title'] ?? '').toString().toLowerCase();
          return title.contains(query);
        }).toList();
      }
      // si on affiche les posts, on ne filtre pas
    });
  }
  // ────────────────────────────────────────────────────────────────────

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserName = prefs.getString("user_name") ?? "Utilisateur";
      currentUserId = prefs.getInt("user_id") ?? 0;
    });
    await _fetchForums();
  }

  Future<void> _fetchForums() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('https://www.hadith.defarsci.fr/api/forums'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          forums = data['data'] ?? [];
          _filteredForums = forums;
          threads = [];
          _filteredThreads = [];
          posts = [];
          selectedForumId = null;
          selectedThreadId = null;
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      _showErrorSnackbar('Erreur de connexion');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchThreads(int forumId) async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('https://www.hadith.defarsci.fr/api/threads?forum_id=$forumId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          selectedForumId = forumId;
          threads = data['data'] ?? [];
          _filteredThreads = threads;
          posts = [];
          selectedThreadId = null;
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      _showErrorSnackbar('Erreur de chargement');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchPosts(int threadId) async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('https://www.hadith.defarsci.fr/api/posts?thread_id=$threadId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          selectedThreadId = threadId;
          posts = data['data'] ?? [];
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      _showErrorSnackbar('Erreur de chargement');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createThread(String title) async {
    if (title.isEmpty || selectedForumId == null) return;
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.post(
        Uri.parse('https://www.hadith.defarsci.fr/api/threads'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'forum_id': selectedForumId,
          'user_id': currentUserId,
          'title': title,
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        _threadTitleController.clear();
        await _fetchThreads(selectedForumId!);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showErrorSnackbar('Erreur de création');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur de connexion');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createPost() async {
    if (_postContentController.text.isEmpty || selectedThreadId == null) return;
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.post(
        Uri.parse('https://www.hadith.defarsci.fr/api/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'thread_id': selectedThreadId,
          'user_id': currentUserId,
          'content': _postContentController.text,
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        _postContentController.clear();
        await _fetchPosts(selectedThreadId!);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showErrorSnackbar('Erreur de création');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur de connexion');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showCreateThreadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: beigeClair,
          title: Text("Nouvelle discussion", style: TextStyle(color: marron)),
          content: TextField(
            controller: _threadTitleController,
            decoration: InputDecoration(
              labelText: "Titre du sujet",
              labelStyle: TextStyle(color: marron),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: marron),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: marron),
              ),
            ),
            maxLength: 100,
            style: TextStyle(color: marron),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler", style: TextStyle(color: marron)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: beigeClair),
              onPressed: () {
                final title = _threadTitleController.text.trim();
                if (title.isNotEmpty) {
                  _createThread(title);
                  Navigator.pop(context);
                }
              },
              child: Text("Créer", style: TextStyle(color: marron)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Widget _buildForumsList() {
    return ListView.builder(
      itemCount: _filteredForums.length,
      itemBuilder: (context, index) {
        final forum = _filteredForums[index];
        return Card(
          color: beigeClair,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(forum['name'] ?? 'Forum sans nom', style: TextStyle(color: marron)),
            subtitle: Text(forum['description'] ?? '', style: TextStyle(color: marron.withOpacity(0.8))),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: marron),
            onTap: () => _fetchThreads(forum['id']),
          ),
        );
      },
    );
  }

  Widget _buildThreadsList() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => setState(() {
            selectedForumId = null;
            _searchController.clear();
          }),
          style: ElevatedButton.styleFrom(backgroundColor: beigeClair),
          child: Text("Retour aux forums", style: TextStyle(color: marron)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _filteredThreads.isEmpty
              ? Center(child: Text("Aucune discussion", style: TextStyle(color: marron)))
              : ListView.builder(
            itemCount: _filteredThreads.length,
            itemBuilder: (context, index) {
              final thread = _filteredThreads[index];
              return Card(
                color: beigeClair,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(thread['title'] ?? 'Sans titre', style: TextStyle(color: marron)),
                  subtitle: Text(
                    "Dernier message: ${thread['updated_at'] ?? 'Inconnu'}",
                    style: TextStyle(fontSize: 12, color: marron.withOpacity(0.8)),
                  ),
                  trailing: Icon(Icons.message, size: 16, color: marron),
                  onTap: () => _fetchPosts(thread['id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostsList() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => setState(() {
            selectedThreadId = null;
            _searchController.clear();
          }),
          style: ElevatedButton.styleFrom(backgroundColor: beigeClair),
          child: Text("Retour aux discussions", style: TextStyle(color: marron)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: posts.isEmpty
              ? Center(child: Text("Aucun message", style: TextStyle(color: marron)))
              : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                color: beigeClair,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: marron,
                            child: Icon(Icons.person, color: beigeClair),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post['user']?['name'] ?? currentUserName,
                            style: TextStyle(fontWeight: FontWeight.bold, color: marron),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(post['content'] ?? '', style: TextStyle(color: marron)),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          post['created_at'] ?? '',
                          style: TextStyle(fontSize: 12, color: marron.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _postContentController,
                  maxLines: 3,
                  style: TextStyle(color: marron),
                  decoration: InputDecoration(
                    labelText: "Écrire un message...",
                    labelStyle: TextStyle(color: marron),
                    border: OutlineInputBorder(borderSide: BorderSide(color: marron)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: marron)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: marron),
                      onPressed: _createPost,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("Salon Privé"),
        backgroundColor: beigeClair,
        foregroundColor: marron,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: marron))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── Champ de recherche ─────────────────────────
            if (selectedThreadId == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: selectedForumId == null
                        ? 'Rechercher un forum…'
                        : 'Rechercher une discussion…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: beigeClair,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            // ────────────────────────────────────────────────
            Expanded(
              child: selectedForumId == null
                  ? _buildForumsList()
                  : selectedThreadId == null
                  ? _buildThreadsList()
                  : _buildPostsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: selectedForumId != null && selectedThreadId == null
          ? FloatingActionButton(
        onPressed: _showCreateThreadDialog,
        backgroundColor: marron,
        child: Icon(Icons.add, color: beigeClair),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: beigeClair,
        selectedItemColor: marron,
        unselectedItemColor: marron.withOpacity(0.6),
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
            case 5:
              Navigator.pushNamed(context, '/don');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Cours"),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: "Contribution"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "FAQ"),
          BottomNavigationBarItem(icon: Icon(Icons.lock_open), label: "Salon"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Don"),
        ],
      ),
    );
  }
}
