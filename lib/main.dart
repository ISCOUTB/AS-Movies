import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/home_page.dart';
import 'pages/discover_page.dart';
import 'pages/categories_page.dart';
import 'pages/search_page.dart';
import 'pages/profile_page.dart';
import 'login.dart';

void main() async {
  await dotenv.load(fileName: ".env"); // Carga las variables de entorno
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // Se inicia en la pantalla de login
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ignore: unused_field
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
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
                icon: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ),
                onPressed: () {},
              ),
              const Spacer(),
              TabBar(
                onTap: _onItemTapped,
                isScrollable: true,
                tabs: const [
                  Tab(text: "Home"),
                  Tab(text: "Descubrir"),
                  Tab(text: "Categorías"),
                  Tab(text: "Buscador"),
                  Tab(text: "Perfil"),
                ],
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: _pages,
        ),
      ),
    );
  }
}
