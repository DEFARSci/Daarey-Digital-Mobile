import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();

  @override
  void dispose() {
    // Libérer les contrôleurs
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Toutes les validations sont OK
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Inscription réussie"),
          content: Text(
              "Prénom: ${_prenomController.text}\nNom: ${_nomController.text}\nEmail: ${_emailController.text}\nAdresse: ${_adresseController.text}\nTéléphone: ${_telephoneController.text}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Ferme la boîte de dialogue
                Navigator.pop(context); // Retourne à la page précédente (Salonprive)
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inscription"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer votre prénom.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer votre nom.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer votre email.";
                  }
                  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                      .hasMatch(value)) {
                    return "Veuillez entrer un email valide.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: "Adresse",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer votre adresse.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: "Téléphone",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer votre numéro de téléphone.";
                  }
                  if (!RegExp(r"^\d+$").hasMatch(value)) {
                    return "Veuillez entrer un numéro de téléphone valide.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
