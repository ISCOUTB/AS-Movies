import 'package:flutter/material.dart';
import '../login.dart'; // Importa la pantalla de login

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección del perfil de usuario
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.black87,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_pic.png'), // Imagen de perfil
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Nombre de Usuario",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "usuario@email.com",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Opciones del perfil
            _buildProfileOption(Icons.favorite, "Películas Favoritas", context),
            _buildProfileOption(Icons.history, "Historial de Visualización", context),
            _buildProfileOption(Icons.settings, "Configuración", context),
            _buildProfileOption(Icons.support_agent, "Soporte", context),
            _buildProfileOption(Icons.help_outline, "Ayuda", context),
            _buildProfileOption(Icons.logout, "Cerrar Sesión", context, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, BuildContext context, {bool isLogout = false}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.blueAccent),
        title: Text(title, style: TextStyle(fontSize: 18)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (isLogout) {
            _showLogoutDialog(context);
          } else {
            // Navegar a otra página (pendiente de implementación)
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cerrar Sesión"),
        content: Text("¿Estás seguro de que deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              Navigator.pushReplacement( // Redirige a la pantalla de login
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Text("Cerrar Sesión", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
