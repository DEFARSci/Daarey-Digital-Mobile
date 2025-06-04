import 'package:daara_digitale/pages/accueil.dart';
import 'package:daara_digitale/pages/contributions.dart';
import 'package:daara_digitale/pages/cours.dart';
import 'package:daara_digitale/pages/fairedon.dart';
import 'package:daara_digitale/pages/faq.dart';
import 'package:daara_digitale/pages/formulaire_inscription.dart';
import 'package:daara_digitale/pages/hadithsdogmes.dart';
import 'package:daara_digitale/pages/inscriptioncoran.dart';
import 'package:daara_digitale/pages/inscriptioncoranconfirme.dart';
import 'package:daara_digitale/pages/inscriptionfikh.dart';
import 'package:daara_digitale/pages/inscriptionfikhconfirme.dart';
import 'package:daara_digitale/pages/khotba.dart';
import 'package:daara_digitale/pages/khutbah.dart';
import 'package:daara_digitale/pages/login.dart';
import 'package:daara_digitale/pages/mosquee_assalam.dart';
import 'package:daara_digitale/pages/projet_madrassa.dart';
import 'package:daara_digitale/pages/register.dart';
import 'package:daara_digitale/pages/salle_cours.dart';
import 'package:daara_digitale/pages/salonprive.dart';
import 'package:flutter/material.dart';
import 'package:daara_digitale/pages/mosquee_assalam.dart';
import 'package:daara_digitale/pages/khutbah.dart';


import 'pages/biographie.dart';

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
        '/': (context) => const Accueil(),
        '/cours': (context) => const Cours(),
        '/hadith': (context) =>  Hadithsdogmes(),
        '/contributions': (context) =>  Contributions(),
        '/faq': (context) => const Faq(),
        '/salon': (context) => const Salonprive(),
        '/don': (context) => const Fairedon(),
        '/InscriptionCoran': (context) => const InscriptionCoran(),
        '/Inscriptioncoranconfirme': (context) => const Inscriptioncoranconfirme(),
        '/Inscriptionfikh': (context) => const Inscriptionfikh(), // Correction ici
        '/Inscriptionfikhconfirme': (context) => const Inscriptionfikhconfirme(), // Correction ici
        '/salleCours': (context) => const SalleCours(),
        '/mosquee': (context) => const MosqueeAssalam(),
        // '/Salonprive': (context) => const Salonprive(),
        '/Fairedon': (context) => const Fairedon(),
        '/register': (context) => const Register(),
        '/login': (context) => const Login(),
        '/formulaireinscription': (context) => const FormulaireInscription(),
        // '/khotba': (context) =>  Khotba(),
        '/khutbah': (context) =>  Khutbah(),
        '/projet_madrassa': (context) => const ProjetMadrassa(),
        '/biographie': (context) => const DaarayDigitalApp(),
      },
    );
  }
}