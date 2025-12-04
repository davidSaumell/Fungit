import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ThemeProvider.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(double.infinity, 120),
                painter: CurvedShadowPainter(),
              ),

              ClipPath(
                clipper: CurvedHeaderClipper(),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFFD91515),
                  child: SafeArea(
                    bottom: false,
                    child: Center(
                      child: const Text(
                        'Configuración',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Idioma'),
                  subtitle: Text(themeProv.locale.languageCode),
                  trailing: DropdownButton<Locale>(
                    value: themeProv.locale,
                    items: const [
                      DropdownMenuItem(value: Locale('es'), child: Text('Castellano')),
                      DropdownMenuItem(value: Locale('en'), child: Text('Inglés')),
                      DropdownMenuItem(value: Locale('ca'), child: Text('Català')),
                    ],
                    onChanged: (v) {
                      if (v != null) themeProv.setLocale(v);
                    },
                  ),
                ),

                ListTile(
                  title: const Text('Tema'),
                  subtitle: Text(
                    themeProv.themeMode == ThemeMode.light ? 'Claro' : 'Oscuro',
                  ),
                  trailing: SwitchStyled(
                    value: themeProv.themeMode == ThemeMode.dark,
                    onChanged: (_) => themeProv.toggleTheme(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD91515),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Cerrar sesión',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CurvedShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPath = Path();

    shadowPath.lineTo(0, size.height - 40);

    shadowPath.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height - 40,
    );

    shadowPath.lineTo(size.width, 0);
    shadowPath.close();

    canvas.drawShadow(
      shadowPath,
      Colors.black.withOpacity(0.4),
      12.0,
      true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SwitchStyled extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const SwitchStyled({required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 60,
        height: 30,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: value ? Colors.green : Colors.grey,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 80),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
