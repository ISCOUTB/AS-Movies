import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buscador"),
      ),
      body: Center(
        child: Text("Busca tus películas favoritas"),
      ),
    );
  }
}