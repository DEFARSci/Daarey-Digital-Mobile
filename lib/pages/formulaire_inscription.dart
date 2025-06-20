import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:daara_digitale/services/nominatim_service.dart';

class FormulaireInscription extends StatefulWidget {
  const FormulaireInscription({super.key});

  @override
  State<FormulaireInscription> createState() => _FormulaireInscriptionState();
}

class _FormulaireInscriptionState extends State<FormulaireInscription> {
  // Couleurs
  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  final _formKey = GlobalKey<FormState>();

  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _lieuNaissanceController = TextEditingController();
  final _adresseController = TextEditingController();

  final _tuteurPrenomController = TextEditingController();
  final _tuteurNomController = TextEditingController();
  final _tuteurProfessionController = TextEditingController();
  final _tuteurTelephoneController = TextEditingController();
  final _tuteurAdresseController = TextEditingController();
  final _tuteurEmailController = TextEditingController();

  String _selectedGenre = 'Masculin';
  String _selectedPaiement = 'sur site';

  final List<String> genres = ['Masculin', 'Féminin'];
  final List<String> modesPaiement = ['sur site', 'en ligne'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dateNaissanceController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse("https://www.hadith.defarsci.fr/api/cour-sur-site/inscription");
      final body = jsonEncode({
        "prenom": _prenomController.text.trim(),
        "nom": _nomController.text.trim(),
        "genre": _selectedGenre,
        "telephone": _telephoneController.text.trim(),
        "date_naissance": _dateNaissanceController.text.trim(),
        "lieu_naissance": _lieuNaissanceController.text.trim(),
        "adresse": _adresseController.text.trim(),
        "tuteur_prenom": _tuteurPrenomController.text.trim(),
        "tuteur_nom": _tuteurNomController.text.trim(),
        "tuteur_profession": _tuteurProfessionController.text.trim(),
        "tuteur_telephone": _tuteurTelephoneController.text.trim(),
        "tuteur_adresse": _tuteurAdresseController.text.trim(),
        "tuteur_email": _tuteurEmailController.text.trim(),
        "mode_paiement": _selectedPaiement,
      });

      try {
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: body,
        );

        final data = jsonDecode(response.body);
        final statusCode = response.statusCode;

        if ((statusCode == 200 || statusCode == 201) && data["status"] == "success") {
          final String? paymentUrl = data["payment_url"];
          final String paiementChoisi = _selectedPaiement;

          // Réinitialiser les champs
          _formKey.currentState!.reset();
          _prenomController.clear();
          _nomController.clear();
          _telephoneController.clear();
          _dateNaissanceController.clear();
          _lieuNaissanceController.clear();
          _adresseController.clear();
          _tuteurPrenomController.clear();
          _tuteurNomController.clear();
          _tuteurProfessionController.clear();
          _tuteurTelephoneController.clear();
          _tuteurAdresseController.clear();
          _tuteurEmailController.clear();

          setState(() {
            _selectedGenre = 'Masculin';
            _selectedPaiement = 'sur site';
          });

          if (paiementChoisi == "en ligne" && paymentUrl != null && paymentUrl.isNotEmpty) {
            await launchUrlString(paymentUrl, mode: LaunchMode.externalApplication);
            Future.delayed(const Duration(seconds: 10), () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            });
          } else {
            _showDialog("Inscription réussie", data["message"] ?? "Inscription terminée.");
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            });
          }
        } else {
          _showDialog("Erreur", data["message"] ?? "Une erreur est survenue.");
        }
      } catch (e) {
        _showDialog("Erreur", "Une erreur s'est produite: $e");
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeMoyen,
      appBar: AppBar(
        title: const Text("Inscription"),
        centerTitle: true,
        backgroundColor: beigeClair,
        foregroundColor: marron,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _buildTextField(_prenomController, "Prénom *"),
            _buildTextField(_nomController, "Nom *"),
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              items: genres.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _selectedGenre = v!),
              decoration: InputDecoration(
                labelText: "Genre *",
                labelStyle: TextStyle(color: marron),
                filled: true,
                fillColor: beigeClair,
                border: OutlineInputBorder(borderSide: BorderSide(color: marron.withOpacity(0.3))),
              ),
            ),
            _buildTextField(_telephoneController, "Téléphone *", keyboardType: TextInputType.phone),
            TextFormField(
              controller: _dateNaissanceController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date de naissance *",
                labelStyle: TextStyle(color: marron),
                filled: true,
                fillColor: beigeClair,
                suffixIcon: Icon(Icons.calendar_today, color: marron),
                border: OutlineInputBorder(borderSide: BorderSide(color: marron.withOpacity(0.3))),
              ),
              onTap: () => _selectDate(context),
              validator: (v) => v == null || v.isEmpty ? "Ce champ est requis" : null,
            ),
            _buildTextField(_lieuNaissanceController, "Lieu de naissance *"),

            // Adresse avec autocomplétion
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TypeAheadField<String>(
                controller: _adresseController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: "Adresse *",
                      labelStyle: TextStyle(color: marron),
                      filled: true,
                      fillColor: beigeClair,
                      border: OutlineInputBorder(borderSide: BorderSide(color: marron.withOpacity(0.3))),
                      suffixIcon: const Icon(Icons.search, color: Colors.grey),
                    ),
                  );
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 3) return [];
                  return await NominatimService.fetchAddresses(pattern);
                },
                itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
                onSelected: (suggestion) => _adresseController.text = suggestion,
              ),
            ),

            const SizedBox(height: 20),
            Text("Informations du tuteur",
                style: TextStyle(fontWeight: FontWeight.bold, color: marron, fontSize: 18)),
            _buildTextField(_tuteurPrenomController, "Prénom *"),
            _buildTextField(_tuteurNomController, "Nom *"),
            // _buildTextField(_tuteurProfessionController, "Profession"),
            _buildTextField(_tuteurTelephoneController, "Téléphone *", keyboardType: TextInputType.phone),

            // Adresse du tuteur avec autocomplétion
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8),
            //   child: TypeAheadField<String>(
            //     controller: _tuteurAdresseController,
            //     builder: (context, controller, focusNode) {
            //       return TextField(
            //         controller: controller,
            //         focusNode: focusNode,
            //         decoration: InputDecoration(
            //           labelText: "Adresse du tuteur *",
            //           labelStyle: TextStyle(color: marron),
            //           filled: true,
            //           fillColor: beigeClair,
            //           border: OutlineInputBorder(borderSide: BorderSide(color: marron.withOpacity(0.3))),
            //           suffixIcon: const Icon(Icons.search, color: Colors.grey),
            //         ),
            //       );
            //     },
            //     suggestionsCallback: (pattern) async {
            //       if (pattern.length < 3) return [];
            //       return await NominatimService.fetchAddresses(pattern);
            //     },
            //     itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
            //     onSelected: (suggestion) => _tuteurAdresseController.text = suggestion,
            //   ),
            // ),

            _buildTextField(_tuteurEmailController, "Email *", keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPaiement,
              items: modesPaiement.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => setState(() => _selectedPaiement = v!),
              decoration: InputDecoration(
                labelText: "Mode de paiement",
                labelStyle: TextStyle(color: marron),
                filled: true,
                fillColor: beigeClair,
                border: OutlineInputBorder(borderSide: BorderSide(color: marron.withOpacity(0.3))),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: marron,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Soumettre l'inscription", style: TextStyle(fontSize: 18)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: marron),
          filled: true,
          fillColor: beigeClair,
          border: OutlineInputBorder(borderSide: BorderSide(color: marron.withOpacity(0.3))),
        ),
        validator: (value) {
          if (label.contains('*') && (value == null || value.trim().isEmpty)) {
            return "Ce champ est requis";
          }
          return null;
        },
      ),
    );
  }
}