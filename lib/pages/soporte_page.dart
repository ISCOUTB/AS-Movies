import 'package:flutter/material.dart';

class SoportePage extends StatelessWidget {
  const SoportePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Soporte")),
      body: const Center(child: Text("Aquí podrás contactar con soporte técnico.")),
    );
  }
}
