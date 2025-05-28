import 'package:flutter/material.dart';
import 'favoritas_page.dart';
import 'historial_page.dart';
import 'configuracion_page.dart';
import 'soporte_page.dart';
import '../login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Mi Perfil"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
              children: [
                Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/profile_pic.png'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Juan Pérez",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text("juanperez@email.com"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildOption(Icons.favorite, "Películas Favoritas", context: context),
                _buildOption(Icons.history, "Historial", context: context),
                _buildOption(Icons.settings, "Configuración", context: context),
                _buildOption(Icons.support_agent, "Soporte", context: context),
                _buildOption(Icons.logout, "Cerrar sesión", isLogout: true, context: context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildOption(IconData icon, String title, {bool isLogout = false, required BuildContext context}) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.blueAccent),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (isLogout) {
            _showLogoutDialog(context);
          } else {
            switch (title) {
              case "Películas Favoritas":
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritasPage()));
                break;
              case "Historial":
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistorialPage()));
                break;
              case "Configuración":
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfiguracionPage()));
                break;
              case "Soporte":
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SoportePage()));
                break;
            }
          }
        },
      ),
    );
  }

  static void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Seguro que deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
