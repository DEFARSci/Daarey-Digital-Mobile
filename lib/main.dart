import 'package:daara_digitale/pages/accueil.dart';
import 'package:daara_digitale/pages/cours.dart';
import 'package:daara_digitale/pages/fairedon.dart';
import 'package:daara_digitale/pages/faq.dart';
import 'package:daara_digitale/pages/hadithsdogmes.dart';
import 'package:daara_digitale/pages/inscriptioncoran.dart';
import 'package:daara_digitale/pages/register.dart';
import 'package:daara_digitale/pages/salle_cours.dart';
import 'package:daara_digitale/pages/salonprive.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application Mobile',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) =>  Accueil(),
        '/cours': (context) => const Cours(),
        '/hadith': (context) =>  Hadithsdogmes(),
        '/faq': (context) => const Faq(),
        '/salon': (context) => const Salonprive(),
        '/don': (context) => const Fairedon(),
        '/InscriptionCoran': (context) => InscriptionCoran(),
        '/salleCours': (context) => const SalleCours(),
        '/Salonprive': (context) => const Salonprive(),
        '/Fairedon': (context) => const Fairedon(),
        '/register': (context) => const Register(),
      },
    );
  }
}