import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Inscriptionfikh extends StatefulWidget {
  const Inscriptionfikh({super.key});

  @override
  State<Inscriptionfikh> createState() => _InscriptionfikhState();
}

class _InscriptionfikhState extends State<Inscriptionfikh> {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  String? _selectedGenre = "Male";

  // Liste des créneaux récupérés, chaque entrée contient { "id", "heure", "date" }
  List<Map<String, dynamic>> _timeSlots = [];
  bool _isLoadingSlots = false;
  int? _selectedSlotId; // ID du créneau choisi

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots();
  }

  /// Récupère les créneaux “débutant/fiqh” depuis l’API :
  /// GET https://www.hadith.defarsci.fr/api/cours/debutant/fiqh
  /// Chaque clé du JSON est une date (texte) et chaque valeur contient un champ "cours" (une liste).
  /// Pour chaque cours, on extrait id, heure et date_complete (ou la clé si date_complete manquante).
  Future<void> _fetchTimeSlots() async {
    setState(() {
      _isLoadingSlots = true;
    });

    try {
      final uri = Uri.parse("https://www.hadith.defarsci.fr/api/cours/debutant/fiqh");
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Liste temporaire pour stocker { "id", "heure", "date" }
        final List<Map<String, dynamic>> slotsAvecDate = [];

        if (decoded is Map<String, dynamic>) {
          // Parcourir chaque entrée ; clé = date (texte), valeur contient "cours" (liste)
          decoded.forEach((keyDate, value) {
            if (value is Map<String, dynamic> && value.containsKey("cours")) {
              // date_complete si présent, sinon on prend la clé textuelle
              final String dateComplete = (value["date_complete"] as String?) ?? keyDate;
              final coursList = value["cours"];
              if (coursList is List) {
                for (var coursItem in coursList) {
                  slotsAvecDate.add({
                    "id":    coursItem["id"] as int,
                    "heure": coursItem["heure"] as String,
                    "date":  dateComplete,
                  });
                }
              }
            }
          });
        }
        // Si besoin, gérer d’autres formats ici…

        setState(() {
          _timeSlots = slotsAvecDate;
          _isLoadingSlots = false;
        });
      } else {
        setState(() {
          _isLoadingSlots = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text("Erreur ${response.statusCode} lors de la récupération des créneaux"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingSlots = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec de récupération des créneaux : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Envoie le formulaire au endpoint d’inscription “fiqhInscriptions”
  Future<void> _submitForm() async {
    // Vérification que tous les champs sont remplis
    if (_nameController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _dateNaissanceController.text.isEmpty ||
        _telephoneController.text.isEmpty ||
        _selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs et choisir un créneau")),
      );
      return;
    }

    // URL du backend (vérifiez la route exacte côté serveur)
    final url = Uri.parse("https://www.hadith.defarsci.fr/api/fiqhInscriptions");

    final Map<String, dynamic> data = {
      "first_name":     _prenomController.text.trim(),
      "last_name":      _nameController.text.trim(),
      "date_naissance": _dateNaissanceController.text.trim(),
      "genre":          _selectedGenre,
      "phone":          _telephoneController.text.trim(),
      "email":          _emailController.text.trim(),
      "cours_id":       _selectedSlotId,
    };

    // Logs pour debug
    print("URL: $url");
    print("Données envoyées: ${jsonEncode(data)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("Statut HTTP: ${response.statusCode}");
      print("Réponse du serveur: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inscription réussie !")),
          );
          // Si nécessaire, rediriger :
          // Navigator.pushReplacementNamed(context, '/coursFikhConfirmes');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur : ${responseData["message"]}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${response.body}")),
        );
      }
    } catch (e) {
      print("Erreur de connexion: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec de connexion : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("Inscription Cours Fikh Débutant"),
        backgroundColor: beigeClair,
        foregroundColor: marron,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Sélection du genre ----------------
              Row(
                children: [
                  const Text("Genre : ", style: TextStyle(color: marron)),
                  Radio<String>(
                    value: "Male",
                    groupValue: _selectedGenre,
                    onChanged: (value) {
                      setState(() {
                        _selectedGenre = value;
                      });
                    },
                    activeColor: marron,
                  ),
                  const Text("Male", style: TextStyle(color: marron)),
                  Radio<String>(
                    value: "Female",
                    groupValue: _selectedGenre,
                    onChanged: (value) {
                      setState(() {
                        _selectedGenre = value;
                      });
                    },
                    activeColor: marron,
                  ),
                  const Text("Female", style: TextStyle(color: marron)),
                ],
              ),
              const SizedBox(height: 10),

              // ---------------- Champ Nom ----------------
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 10),

              // ---------------- Champ Prénom ----------------
              TextField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 10),

              // ---------------- Champ Email ----------------
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 10),

              // ---------------- Champ Date de naissance ----------------
              TextField(
                controller: _dateNaissanceController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date de naissance",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _dateNaissanceController.text =
                          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                  labelStyle: const TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 10),

              // ---------------- Champ Téléphone ----------------
              TextField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: "N° de téléphone",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- Titre “Sélectionnez un créneau” ----------------
              const Text(
                "Sélectionnez un créneau :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: marron),
              ),
              const SizedBox(height: 8),

              // Affichage du loader pendant la récupération
              if (_isLoadingSlots)
                const Center(child: CircularProgressIndicator())
              // Si pas de créneau après chargement
              else if (!_isLoadingSlots && _timeSlots.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Aucun créneau disponible",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              // Sinon, on affiche le Dropdown avec “date – heure”
              else
                DropdownButtonFormField<int>(
                  value: _selectedSlotId,
                  decoration: InputDecoration(
                    labelText: "Choisir le créneau",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _timeSlots.map((slot) {
                    return DropdownMenuItem<int>(
                      value: slot["id"] as int,
                      child: Text("${slot["date"]} – ${slot["heure"]}"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSlotId = val;
                    });
                  },
                ),

              const SizedBox(height: 24),

              // ---------------- Bouton “Réserver” ----------------
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: beigeClair,
                    foregroundColor: marron,
                  ),
                  onPressed: _submitForm,
                  child: const Text("Réserver"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
