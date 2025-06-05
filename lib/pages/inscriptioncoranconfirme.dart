import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Inscriptioncoranconfirme extends StatefulWidget {
  const Inscriptioncoranconfirme({super.key});

  @override
  State<Inscriptioncoranconfirme> createState() => _InscriptioncoranconfirmeState();
}

class _InscriptioncoranconfirmeState extends State<Inscriptioncoranconfirme> {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();

  // Contrôleur pour l’Email
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  String? _selectedGenre = "Masculin";

  // Liste des créneaux récupérés, chacun avec { "id", "heure", "date" }
  List<Map<String, dynamic>> _timeSlots = [];
  bool _isLoadingSlots = false;

  // ID du créneau choisi dans le dropdown
  int? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots();
  }

  /// Récupère les créneaux horaires depuis l’API “confirme/coran” :
  /// GET https://www.hadith.defarsci.fr/api/cours/confirme/coran
  /// Pour chaque entrée, la clé est la date (ex: "vendredi 27 juin 2025") et
  /// la valeur contient un champ "cours" (liste). On extrait {id, heure, date}.
  Future<void> _fetchTimeSlots() async {
    setState(() {
      _isLoadingSlots = true;
    });

    try {
      final uri = Uri.parse("https://www.hadith.defarsci.fr/api/cours/confirme/coran");
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Liste temporaire pour stocker { "id", "heure", "date" }
        final List<Map<String, dynamic>> slotsAvecDate = [];

        if (decoded is Map<String, dynamic>) {
          decoded.forEach((keyDate, value) {
            if (value is Map<String, dynamic> && value.containsKey("cours")) {
              // Prendre date_complete si présent, sinon la clé JSON
              final String dateComplete = (value["date_complete"] as String?) ?? keyDate;
              final coursList = value["cours"];
              if (coursList is List) {
                for (var coursItem in coursList) {
                  slotsAvecDate.add({
                    "id": coursItem["id"] as int,
                    "heure": coursItem["heure"] as String,
                    "date": dateComplete,
                  });
                }
              }
            }
          });
        }

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

  Future<void> _submitForm() async {
    // Validation : Tous les champs + sélection d’un créneau
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

    // Construire l’URL EXACTE (casse incluse) pour l’Inscription Coran Confirmé
    final url = Uri.parse("https://www.hadith.defarsci.fr/api/coranInscriptions");

    final Map<String, dynamic> data = {
      "first_name":     _prenomController.text.trim(),
      "last_name":      _nameController.text.trim(),
      "date_naissance": _dateNaissanceController.text.trim(),
      "genre":          _selectedGenre, // "Masculin" ou "Féminin"
      "phone":          _telephoneController.text.trim(),
      "email":          _emailController.text.trim(),
      "cours_id":       _selectedSlotId, // ID du créneau sélectionné
    };

    // Debug : URL et payload
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData;
        try {
          responseData = json.decode(response.body);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Réponse non-JSON : $e")),
          );
          return;
        }

        if (responseData["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inscription réussie !")),
          );
          // Redirection éventuelle, par ex :
          // Navigator.pushReplacementNamed(context, '/coursConfirmes');
        } else {
          final msgServeur = responseData["message"] ?? "Erreur inconnue.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur : $msgServeur")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur HTTP : ${response.statusCode}")),
        );
      }
    } catch (e) {
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
        title: const Text("Inscription Cours Coran Confirmé"),
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
              // --------------- Genre ---------------
              Row(
                children: [
                  const Text("Genre : ", style: TextStyle(color: marron)),
                  Radio<String>(
                    value: "Masculin",
                    groupValue: _selectedGenre,
                    onChanged: (value) => setState(() => _selectedGenre = value),
                    activeColor: marron,
                  ),
                  const Text("Masculin", style: TextStyle(color: marron)),
                  Radio<String>(
                    value: "Féminin",
                    groupValue: _selectedGenre,
                    onChanged: (value) => setState(() => _selectedGenre = value),
                    activeColor: marron,
                  ),
                  const Text("Féminin", style: TextStyle(color: marron)),
                ],
              ),
              const SizedBox(height: 10),

              // --------------- Prénom ---------------
              TextField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 10),

              // --------------- Nom ---------------
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 10),

              // --------------- Email ---------------
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

              // --------------- Date de naissance ---------------
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

              // --------------- Téléphone ---------------
              TextField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "N° de téléphone",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 20),

              // --------------- Sélection du créneau ---------------
              const Text(
                "Sélectionnez un créneau :",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: marron,
                ),
              ),
              const SizedBox(height: 8),

              // Loader pendant la récupération
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
              // Sinon, on affiche un Dropdown avec “date – heure”
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

              // --------------- Bouton “Réserver” ---------------
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
