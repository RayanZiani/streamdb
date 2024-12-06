import 'package:flutter/material.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final TextEditingController _playlistNameController = TextEditingController();

  void _showCustomModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Créer une Playlist'),
          content: TextField(
            controller: _playlistNameController,
            decoration: InputDecoration(
              hintText: 'Nom de la playlist',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                String playlistName = _playlistNameController.text;

                print('Nom de la playlist : $playlistName');

                Navigator.of(context).pop();
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Libérer le contrôleur quand il n'est plus utilisé
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: const Center(
        child: Text(
          'Paramètres à venir',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          onPressed: () => _showCustomModal(context),
          backgroundColor: Colors.white24,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
