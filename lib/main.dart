import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/app_routes.dart';
import 'pages/home_page.dart';
import 'pages/discover_page.dart';
import 'pages/categories_page.dart';
import 'pages/search_page.dart';
import 'pages/profile_page.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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

  final List<String> _titles = [
    'Inicio',
    'Descubrir',
    'Categorías',
    'Buscador',
    'Perfil',
  ];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.explore_rounded,
    Icons.category_rounded,
    Icons.search_rounded,
    Icons.person_rounded,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE0E0E0), // Blanco metálico apagado
                Color(0xFFBDBDBD), // Gris claro para dar profundidad
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 60,
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(_titles.length, (index) {
                        final isSelected = _selectedIndex == index;
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.18) : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.18),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => _onItemTapped(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  AnimatedSwitcher(
                                    duration: Duration(milliseconds: 350),
                                    child: Icon(
                                      _icons[index],
                                      key: ValueKey(isSelected),
                                      color: isSelected ? Color(0xFF232526) : Colors.grey[700],
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedDefaultTextStyle(
                                    duration: Duration(milliseconds: 350),
                                    style: GoogleFonts.poppins(
                                      color: isSelected ? Color(0xFF232526) : Colors.grey[700],
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 18,
                                      letterSpacing: 0.5,
                                    ),
                                    child: Text(_titles[index]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: _pages[_selectedIndex],
      ),
      backgroundColor: Color(0xFF232526),
    );
  }
}
