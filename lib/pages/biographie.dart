import 'package:flutter/material.dart';

void main() {
  runApp(const DaarayDigitalApp());
}

class DaarayDigitalApp extends StatelessWidget {
  const DaarayDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daaray-Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF8A7245),
        scaffoldBackgroundColor: const Color(0xFFF9F5EF),
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A7245),
          primary: const Color(0xFF8A7245),
          secondary: const Color(0xFFF3E6D2),
        ),
        useMaterial3: true,
      ),
      home: const ProphetBiographyPage(),
    );
  }
}

class ProphetBiographyPage extends StatelessWidget {
  const ProphetBiographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daaray-Digital', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: const BiographyContent(),
    );
  }
}

class BiographyContent extends StatelessWidget {
  const BiographyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Breadcrumb(),
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BiographyHeader(),
                const SizedBox(height: 16),
                const TimelineSection(),
                const MainContent(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            color: Theme.of(context).primaryColor,
            child: const Text(
              '© 2025 Daaray-Digital. Tous droits réservés.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        children: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {},
            child: Text(
              'Accueil',
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14),
            ),
          ),
          Text(' › ', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14)),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {},
            child: Text(
              'Contributions',
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14),
            ),
          ),
          Text(' › ', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14)),
          Text(
            'Biographie du Prophète',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class BiographyHeader extends StatelessWidget {
  const BiographyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 2.0,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Biographie du Prophète Muhammad (ﷺ)',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Le dernier messager d\'Allah et le sceau des prophètes',
            style: TextStyle(
              color: const Color(0xFF5E4E2E),
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TimelineSection extends StatelessWidget {
  const TimelineSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Chronologie',
              style: TextStyle(
                color: const Color(0xFF5E4E2E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildTimelineItems(context),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineItems(BuildContext context) {
    final List<Map<String, String>> timelineItems = [
      {'year': '570', 'event': 'Naissance à La Mecque'},
      {'year': '576', 'event': 'Orphelin, pris en charge par son grand-père Abd al-Muttalib'},
      {'year': '578', 'event': 'Décès du grand-père, élevé par son oncle Abu Talib'},
      {'year': '595', 'event': 'Mariage avec Khadija'},
      {'year': '610', 'event': 'Première révélation dans la grotte de Hira'},
      {'year': '613', 'event': 'Début de la prédication publique'},
      {'year': '619', 'event': 'Année de la tristesse (décès de Khadija et Abu Talib)'},
      {'year': '620', 'event': 'Voyage nocturne (Isra et Mi\'raj)'},
      {'year': '622', 'event': 'Hégire (migration vers Médine)'},
      {'year': '624', 'event': 'Bataille de Badr'},
      {'year': '625', 'event': 'Bataille d\'Uhud'},
      {'year': '627', 'event': 'Bataille du Fossé'},
      {'year': '628', 'event': 'Traité de Hudaybiyya'},
      {'year': '630', 'event': 'Conquête de La Mecque'},
      {'year': '632', 'event': 'Pèlerinage d\'adieu et décès à Médine'},
    ];

    return timelineItems.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 5, right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['year']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5E4E2E),
                    ),
                  ),
                  Text(item['event']!),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            context,
            'Naissance et enfance',
            'Muhammad ibn Abdullah (ﷺ) est né à La Mecque, en Arabie, en l\'an 570 après J.-C., année connue comme "l\'Année de l\'Éléphant". Il est né au sein de la tribu des Quraysh, une tribu respectée qui gardait la Kaaba. Son père, Abdullah, mourut avant sa naissance, et sa mère, Amina, décéda lorsqu\'il avait six ans. Orphelin, il fut d\'abord élevé par son grand-père Abd al-Muttalib, puis par son oncle Abu Talib.\n\nDès son jeune âge, Muhammad (ﷺ) était connu pour son honnêteté, sa fiabilité et son intégrité, ce qui lui valut le surnom d\'"Al-Amine" (le digne de confiance). Il travaillait comme berger dans sa jeunesse, puis devint un marchand respecté.',
          ),
          _buildSection(
            context,
            'Mariage avec Khadija',
            'À l\'âge de 25 ans, Muhammad (ﷺ) fut employé par Khadija, une riche veuve et commerçante respectée, pour conduire ses caravanes commerciales. Impressionnée par son caractère et son honnêteté, Khadija proposa le mariage à Muhammad (ﷺ). Malgré leur différence d\'âge (elle avait 40 ans), leur union fut heureuse et dura 25 ans, jusqu\'au décès de Khadija. Pendant cette période, ils eurent plusieurs enfants, dont Fatima, la seule qui survécut et eut une descendance.',
          ),
          _buildQuote(
            context,
            'Par Allah, Il ne vous humiliera jamais. Vous maintenez les liens de parenté, vous supportez les faibles, vous aidez les nécessiteux, vous honorez vos invités et vous secourez les affligés par les calamités.',
            'Khadija à Muhammad (ﷺ) après sa première révélation',
          ),
          _buildSection(
            context,
            'La révélation',
            'Muhammad (ﷺ) avait l\'habitude de se retirer dans la grotte de Hira sur le mont An-Nur près de La Mecque pour méditer. C\'est là qu\'à l\'âge de 40 ans, en 610, l\'ange Gabriel lui apparut et lui transmit les premiers versets du Coran, marquant le début de sa mission prophétique. Effrayé par cette expérience, il retourna auprès de Khadija qui le réconforta et fut la première à embrasser l\'Islam.\n\nPendant les trois premières années, Muhammad (ﷺ) prêcha l\'Islam en secret à ses proches. Puis il reçut l\'ordre divin de proclamer publiquement son message. Face à l\'hostilité croissante des Mecquois, qui voyaient dans l\'Islam une menace pour leur mode de vie et leurs intérêts économiques, les musulmans subirent persécutions et boycott.',
          ),
          _buildSection(
            context,
            'L\'Hégire et l\'établissement à Médine',
            'En 622, face aux persécutions croissantes à La Mecque, Muhammad (ﷺ) et ses compagnons émigrèrent à Yathrib (plus tard renommée Médine), un événement connu sous le nom d\'Hégire, qui marque le début du calendrier islamique. À Médine, Muhammad (ﷺ) établit la première communauté musulmane organisée et jeta les bases d\'un État islamique.\n\nIl unifia les tribus de Médine, établit une constitution (la Charte de Médine) garantissant les droits des musulmans et des non-musulmans, et commença à former une société basée sur les principes de justice, d\'égalité et de fraternité.',
          ),
          _buildSection(
            context,
            'Les dernières années et l\'héritage',
            'En 630, après plusieurs années de conflits avec les Mecquois, Muhammad (ﷺ) retourna à La Mecque avec une armée de 10 000 hommes. La ville se rendit sans combat, et il pardonna à ses anciens persécuteurs, montrant une clémence remarquable. Il purifia la Kaaba des idoles et la consacra à l\'adoration d\'Allah seul.\n\nEn 632, Muhammad (ﷺ) accomplit son pèlerinage d\'adieu et prononça son dernier sermon, rappelant les principes fondamentaux de l\'Islam et l\'égalité de tous les êtres humains. Peu après son retour à Médine, il tomba malade et décéda dans les bras de son épouse Aisha. Il fut enterré dans sa chambre, à l\'emplacement actuel de la Mosquée du Prophète à Médine.',
          ),
          _buildQuote(
            context,
            'Ô hommes ! Votre Seigneur est unique et votre ancêtre est unique. Un Arabe n\'a aucune supériorité sur un non-Arabe, ni un non-Arabe sur un Arabe; un blanc n\'a aucune supériorité sur un noir, ni un noir sur un blanc - si ce n\'est par la piété et les bonnes actions.',
            'Extrait du Sermon d\'Adieu',
          ),
          _buildSection(
            context,
            'Caractère et enseignements',
            'Muhammad (ﷺ) était connu pour sa simplicité, sa modestie et sa compassion. Malgré sa position de chef d\'État et de guide spirituel, il vivait modestement, partageait les tâches ménagères, raccommodait ses vêtements et participait aux travaux collectifs. Il était accessible à tous, accordant une attention particulière aux faibles et aux marginalisés.\n\nSes enseignements ont transformé l\'Arabie et, par la suite, une grande partie du monde. Il a prêché l\'unicité de Dieu (tawhid), l\'égalité des êtres humains, la justice sociale, la compassion envers toutes les créatures et l\'importance du savoir. Son message, consigné dans le Coran et les Hadiths, continue d\'inspirer et de guider plus de 1,8 milliard de musulmans à travers le monde.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 1,
          color: Theme.of(context).colorScheme.secondary,
          margin: const EdgeInsets.only(bottom: 12),
        ),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuote(BuildContext context, String quote, String source) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            quote,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— $source',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}