import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categorías"),
      ),
      body: Center(
        child: Text("Selecciona una categoría"),
      ),
    );
  }
}