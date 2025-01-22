import 'package:flutter/material.dart';

class Inscriptionfikh extends StatefulWidget {
  const Inscriptionfikh({super.key});

  @override
  State<Inscriptionfikh> createState() => _InscriptionfikhState();
}

class _InscriptionfikhState extends State<Inscriptionfikh> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dateNaissanceController =
  TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  String? _selectedDate;
  String? _selectedGenre = "Male";
  List<String> selectedHours = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inscription Cours Fikh"),
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
                  const Text("Genre: "),
                  Radio<String>(
                    value: "Male",
                    groupValue: _selectedGenre,
                    onChanged: (value) {
                      setState(() {
                        _selectedGenre = value;
                      });
                    },
                  ),
                  const Text("Male"),
                  Radio<String>(
                    value: "Female",
                    groupValue: _selectedGenre,
                    onChanged: (value) {
                      setState(() {
                        _selectedGenre = value;
                      });
                    },
                  ),
                  const Text("Female"),
                ],
              ),
              const SizedBox(height: 10),

              // Nom
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Prénom
              TextField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(),
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
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Numéro de téléphone
              TextField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: "N° de téléphone",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Sélectionnez une date
              const Text(
                "Sélectionnez une date :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedDate,
                isExpanded: true,
                items: List.generate(31, (index) {
                  return DropdownMenuItem<String>(
                    value: (index + 1).toString(),
                    child: Text("Jour ${(index + 1)}"),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedDate = value;
                  });
                },
                hint: const Text("Sélectionnez une date"),
              ),
              const SizedBox(height: 20),

              // Plages horaires
              const Text(
                "Sélectionnez les horaires :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  onPressed: () {
                    // Logique pour soumettre les données
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
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
          Text(time),
        ],
      ),
    );
  }
}
