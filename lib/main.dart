import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ThemeProvider.dart';
// TODO add user verification screens
// import 'screens/Splash.dart';
// import 'screens/LogIn.dart';
// import 'screens/Singup.dart';
import 'screens/HomeScaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FungitApp());
}

class FungitApp extends StatelessWidget {
  const FungitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fungit',
          theme: themeProv.lightTheme,
          darkTheme: themeProv.darkTheme,
          themeMode: themeProv.themeMode,
          // TODO Add locations --> translate the text 
          // localizationsDelegates: const [
          //   GlobalMaterialLocalizations.delegate,
          //   GlobalWidgetsLocalizations.delegate,
          //   GlobalCupertinoLocalizations.delegate,
          // ],
          // supportedLocales: const [Locale('es'), Locale('en'), Locale('ca')],
          initialRoute: '/home',
          routes: {
            // TODO add user verification screens
            // '/splash': (_) => const SplashScreen(),
            // '/login': (_) => const LogInScreen(),
            // '/signup': (_) => const SignInScreen(),
            '/home': (_) => const HomeScaffold(),
          },
        ),
      ),
    );
  }
}
