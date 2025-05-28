import 'package:flutter/material.dart';

class FavoritasPage extends StatefulWidget {
  const FavoritasPage({super.key});

  @override
  State<FavoritasPage> createState() => _FavoritasPageState();
}

class _FavoritasPageState extends State<FavoritasPage> {
  final List<String> _peliculasFavoritas = [];
  final TextEditingController _controller = TextEditingController();

  void _agregarPelicula() {
    final texto = _controller.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        _peliculasFavoritas.add(texto);
        _controller.clear();
      });
    }
  }

  void _eliminarPelicula(int index) {
    setState(() {
      _peliculasFavoritas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Películas Favoritas"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de texto para agregar películas
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Nombre de la película",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _agregarPelicula,
                  child: const Text("Agregar"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Tu lista de favoritas:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Lista de películas favoritas
            Expanded(
              child: _peliculasFavoritas.isEmpty
                  ? const Center(child: Text("Aún no has agregado películas."))
                  : ListView.builder(
                      itemCount: _peliculasFavoritas.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(_peliculasFavoritas[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarPelicula(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
