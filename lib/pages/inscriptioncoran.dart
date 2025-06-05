import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InscriptionCoran extends StatefulWidget {
  const InscriptionCoran({super.key});

  @override
  State<InscriptionCoran> createState() => _InscriptionCoranState();
}

class _InscriptionCoranState extends State<InscriptionCoran> {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  // Contrôleurs pour les champs de texte
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  String? _selectedGenre = "Masculin";

  // Liste des créneaux récupérés (avec "id", "heure" et "date")
  List<Map<String, dynamic>> _timeSlots = [];
  // Pour garder en mémoire les créneaux cochés (leurs IDs)
  List<int> _selectedSlotIds = [];

  bool _isLoadingSlots = true;

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots();
  }

  /// Récupère les créneaux horaires depuis l’API :
  /// GET https://www.hadith.defarsci.fr/api/cours/debutant/coran
  /// On extrait pour chaque cours : id, heure, et date_complete (ou la clé JSON si date_complete absente)
  Future<void> _fetchTimeSlots() async {
    setState(() {
      _isLoadingSlots = true;
    });

    try {
      final uri = Uri.parse("https://www.hadith.defarsci.fr/api/cours/debutant/coran");
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Liste temporaire dans laquelle on stocke { "id", "heure", "date" }
        final List<Map<String, dynamic>> slotsAvecDate = [];

        if (decoded is Map<String, dynamic>) {
          // Parcourir chaque entrée : la clé est le texte de la date (ex: "vendredi 27 juin 2025")
          decoded.forEach((keyDate, value) {
            if (value is Map<String, dynamic> && value.containsKey("cours")) {
              // date_complete si présente, sinon on prend la clé elle-même
              final String dateComplete = (value["date_complete"] as String?) ?? keyDate;
              final coursList = value["cours"];
              if (coursList is List) {
                for (var coursItem in coursList) {
                  slotsAvecDate.add({
                    "id":   coursItem["id"] as int,
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
            content: Text("Erreur ${response.statusCode} lors de la récupération des créneaux"),
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

  /// Soumet le formulaire vers l’endpoint exact (tout en minuscules) :
  /// POST https://www.hadith.defarsci.fr/api/cours/coraninscriptions
  Future<void> _submitForm() async {
    // 1) Validation que tous les champs sont remplis
    if (_nameController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _dateNaissanceController.text.isEmpty ||
        _telephoneController.text.isEmpty ||
        _selectedSlotIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs et choisir un créneau")),
      );
      return;
    }

    // 2) Récupérer l'ID du premier créneau sélectionné
    final selectedCourseId = _selectedSlotIds.first;

    // 3) Construire l’URL EXACTE (tout en minuscules) pour éviter le 404
    final url = Uri.parse("https://www.hadith.defarsci.fr/api/coranInscriptions");

    // 4) Construire le JSON à envoyer (les clés doivent correspondre à ce que le backend attend)
    final Map<String, dynamic> data = {
      "first_name":     _prenomController.text.trim(),
      "last_name":      _nameController.text.trim(),
      "date_naissance": _dateNaissanceController.text.trim(),
      "genre":          _selectedGenre == "Masculin" ? "Homme" : "Femme",
      "phone":          _telephoneController.text.trim(),
      "email":          _emailController.text.trim(),
      "cours_id":       selectedCourseId,
    };

    // 5) Logs pour débogage : URL + données envoyées
    print("→ POST $url");
    print("Données envoyées : ${jsonEncode(data)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      // 6) Logs retour : statut HTTP + body brut
      print("← Statut HTTP : ${response.statusCode}");
      print("← Body brut : ${response.body}");

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
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacementNamed(context, '/cours');
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
        SnackBar(content: Text("Problème réseau : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("Inscription Cours Coran"),
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
                  hintText: "Votre prénom",
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
                  hintText: "Votre nom",
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
                  hintText: "votre@email.com",
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
                        initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
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
                  hintText: "+33...",
                ),
              ),
              const SizedBox(height: 20),

              // --------------- Titre “Choisir date et heure” ---------------
              const Text(
                "Choisir date et heure :",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: marron,
                ),
              ),
              const SizedBox(height: 8),

              // --------------- Affichage des créneaux avec date et heure ---------------
              if (_isLoadingSlots) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (_timeSlots.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Aucun créneau disponible",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ] else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timeSlots.map((slot) {
                    final slotId = slot['id'] as int;
                    final date   = slot['date'] as String;   // ex : "vendredi 27 juin 2025"
                    final heure  = slot['heure'] as String;  // ex : "09h"
                    final isChecked = _selectedSlotIds.contains(slotId);

                    return FilterChip(
                      label: Text("$date – $heure"),
                      selected: isChecked,
                      selectedColor: marron.withOpacity(0.2),
                      checkmarkColor: marron,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSlotIds.add(slotId);
                          } else {
                            _selectedSlotIds.remove(slotId);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 30),

              // --------------- Bouton “S'inscrire” ---------------
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: beigeClair,
                    foregroundColor: marron,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: _submitForm,
                  child: const Text("S'inscrire"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
