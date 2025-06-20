import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ActualiteDetailsPage extends StatefulWidget {
  final Map<String, dynamic> actualite;
  const ActualiteDetailsPage({super.key, required this.actualite});

  @override
  State<ActualiteDetailsPage> createState() => _ActualiteDetailsPageState();
}

class _ActualiteDetailsPageState extends State<ActualiteDetailsPage> {
  YoutubePlayerController? _ytController;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    final url = widget.actualite['video_url'] as String? ?? '';
    _videoId = YoutubePlayer.convertUrlToId(url);

    if (_videoId != null && _videoId!.isNotEmpty) {
      _ytController = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title   = widget.actualite['title']      as String? ?? '';
    final content = widget.actualite['content']    as String? ?? '';
    final rawDate = widget.actualite['created_at'] as String?;
    final dateTxt = rawDate != null
        ? DateFormat('dd MMMM yyyy – HH:mm').format(DateTime.parse(rawDate))
        : '';
    // Choisissez le lien à ouvrir en fallback
    final fallbackLink = widget.actualite['link'] as String? ?? widget.actualite['video_url'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Si on a un véritable ID YouTube, on affiche le player
          if (_ytController != null) ...[
            YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true),
            const SizedBox(height: 16),
          ],

          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if (dateTxt.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Publié le $dateTxt', style: const TextStyle(color: Colors.grey)),
          ],
          const SizedBox(height: 16),
          Text(content, style: const TextStyle(fontSize: 18)),

          const SizedBox(height: 24),
          // ** Fallback : lien cliquable **
          if (fallbackLink.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.play_circle_outline),
              label: const Text("Regarder la vidéo / source"),
              onPressed: () async {
                final uri = Uri.parse(fallbackLink);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.inAppWebView);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Impossible d'ouvrir le lien")),
                  );
                }
              },
            ),
        ]),
      ),
    );
  }
}
