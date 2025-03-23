import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/home_page.dart';
import 'pages/discover_page.dart';
import 'pages/categories_page.dart';
import 'pages/search_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';

void main() async {
  await dotenv.load(fileName: ".env"); // Carga las variables de entorno
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    DiscoverPage(),
    CategoriesPage(),
    SearchPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              // Logo como botón que no hace nada
              IconButton(
                icon: Image.asset(
                  'assets/images/logo.png', // Ruta del logo
                  height: 100, // Altura del logo
                ),
                onPressed: () {
                  // No hace nada
                },
              ),
              // Espacio para empujar los botones a la derecha
              Spacer(),
              // Barra de navegación con nombres de páginas
              TabBar(
                onTap: _onItemTapped, // Cambia la página al seleccionar una pestaña
                isScrollable: true, // Permite desplazamiento si hay muchos botones
                tabs: const [
                  Tab(text: "Home"), // Nombre de la página
                  Tab(text: "Descubrir"), // Nombre de la página
                  Tab(text: "Categorías"), // Nombre de la página
                  Tab(text: "Buscador"), // Nombre de la página
                  Tab(text: "Perfil"), // Nombre de la página
                ],
                labelColor: Colors.black, // Color de las pestañas seleccionadas
                unselectedLabelColor: Colors.grey, // Color de las pestañas no seleccionadas
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: _pages, // Las páginas corresponden a las pestañas
        ),
      ),
    );
  }
}