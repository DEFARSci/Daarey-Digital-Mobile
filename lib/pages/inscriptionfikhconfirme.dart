import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Inscriptionfikhconfirme extends StatefulWidget {
  const Inscriptionfikhconfirme({super.key});

  @override
  State<Inscriptionfikhconfirme> createState() => _InscriptionfikhconfirmeState();
}

class _InscriptionfikhconfirmeState extends State<Inscriptionfikhconfirme> {
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _dateCoursController = TextEditingController();
  String? _selectedGenre = "Male";
  List<String> selectedHours = [];

  Future<void> _submitForm() async {
    // Vérification que tous les champs sont remplis
    if (_nameController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _dateNaissanceController.text.isEmpty ||
        _telephoneController.text.isEmpty ||
        _dateCoursController.text.isEmpty ||
        selectedHours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    // URL de l'API
    var url = Uri.parse("https://www.hadith.defarsci.fr/api/fiqh-inscription/confirmé");

    // Données à envoyer
    Map<String, dynamic> data = {
      "first_name": _prenomController.text,
      "last_name": _nameController.text,
      "date_naissance": _dateNaissanceController.text,
      "genre": _selectedGenre == "Male" ? "Masculin" : "Féminin", // Convertir en français
      "phone": _telephoneController.text,
      "date_cours": _dateCoursController.text,
      "heure_cours": selectedHours.join(", "), // Convertir la liste en chaîne
    };

    // Log des données envoyées
    print("Données envoyées: ${jsonEncode(data)}");

    try {
      // Envoi de la requête POST
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data), // Encode les données en JSON
      );

      // Log de la réponse
      print("Statut HTTP: ${response.statusCode}");
      print("Réponse du serveur: ${response.body}");

      var responseData = jsonDecode(response.body);

      // Gestion de la réponse
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inscription réussie !")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur: ${responseData["message"]}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${response.body}")),
        );
      }
    } catch (e) {
      // Gestion des erreurs de connexion
      print("Erreur de connexion: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec de connexion: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("Inscription Cours Fikh Confirmé"),
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
              // Genre
              Row(
                children: [
                  const Text("Genre: ", style: TextStyle(color: marron)),
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

              // Nom
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 10),

              // Prénom
              TextField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 10),

              // Date de naissance
              TextField(
                controller: _dateNaissanceController,
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
                          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                        });
                      }
                    },
                  ),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 10),

              // Numéro de téléphone
              TextField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: "N° de téléphone",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 20),

              // Date du cours
              TextField(
                controller: _dateCoursController,
                decoration: InputDecoration(
                  labelText: "Date du cours",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _dateCoursController.text =
                          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                        });
                      }
                    },
                  ),
                  labelStyle: TextStyle(color: marron),
                ),
              ),
              const SizedBox(height: 20),

              // Plages horaires
              const Text(
                "Sélectionnez les horaires :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: marron),
              ),
              Wrap(
                children: [
                  buildCheckbox("9h-10h"),
                  buildCheckbox("10h-11h"),
                  buildCheckbox("11h-12h"),
                  buildCheckbox("14h-15h"),
                  buildCheckbox("15h-16h"),
                  buildCheckbox("16h-17h"),
                  buildCheckbox("19h-20h"),
                  buildCheckbox("20h-21h"),
                  buildCheckbox("21h-22h"),
                ],
              ),
              const SizedBox(height: 20),

              // Bouton de réservation
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: beigeClair, foregroundColor: marron),
                  onPressed: _submitForm, // Appel de la méthode _submitForm
                  // style: ElevatedButton.styleFrom(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 40, vertical: 15),
                  // ),
                  child: const Text("Réserver"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCheckbox(String time) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: selectedHours.contains(time),
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  selectedHours.add(time);
                } else {
                  selectedHours.remove(time);
                }
              });
            },
          ),
          Text(time, style: TextStyle(color: marron)),
        ],
      ),
    );
  }
}