import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

class SalleUn extends StatefulWidget {
  const SalleUn({super.key});

  @override
  State<SalleUn> createState() => _SalleUnState();
}

class _SalleUnState extends State<SalleUn> {
  final JitsiMeet jitsiMeet = JitsiMeet();
  bool _isLoading = false;
  bool _meetingStarted = false;

  static const Color beigeClair = Color(0xFFF3EEE1);
  static const Color beigeMoyen = Color(0xFFE1DED5);
  static const Color marron = Color(0xFF5D4C3B);

  @override
  void initState() {
    super.initState();
    // _setupEventListeners(); <-- Supprimé car .events n'existe pas
  }

  Future<void> _joinMeeting() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Demander les permissions
      final status = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      if (status[Permission.camera]!.isDenied ||
          status[Permission.microphone]!.isDenied) {
        throw Exception('Permissions requises non accordées');
      }

      final options = JitsiMeetConferenceOptions(
        room: "DaaraDigitale${DateTime.now().millisecondsSinceEpoch}",
        serverURL: "https://meet.jit.si",
        userInfo: JitsiMeetUserInfo(
          displayName: "Participant",
          email: "participant@daaradigitale.com",
        ),
        featureFlags: {
          "welcomepage.enabled": false,
          "chat.enabled": true,
          "invite.enabled": false,
        },
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": false,
          "subject": "Cours Daara Digitale",
        },
      );

      await jitsiMeet.join(options);

      // Met à jour l'état local
      if (mounted) {
        setState(() {
          _meetingStarted = true;
          _isLoading = false;
        });
      }
    } catch (error) {
      debugPrint("Erreur Jitsi: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${error.toString()}")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    jitsiMeet.hangUp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salle de Cours'),
        backgroundColor: marron,
        foregroundColor: Colors.white,
      ),
      backgroundColor: beigeClair,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_camera_back,
              size: 100,
              color: marron,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: marron,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              onPressed: _isLoading ? null : _joinMeeting,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Rejoindre le Cours', style: TextStyle(fontSize: 18)),
            ),
            if (_meetingStarted)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text('Vous êtes dans la salle de cours',
                    style: TextStyle(color: Colors.green)),
              ),
          ],
        ),
      ),
    );
  }
}
