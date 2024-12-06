import 'package:flutter/material.dart';

class CasinoScreen extends StatefulWidget {
  const CasinoScreen({Key? key}) : super(key: key);

  @override
  State<CasinoScreen> createState() => _CasinoScreenState();
}

class _CasinoScreenState extends State<CasinoScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: Text(
          'A venir',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
