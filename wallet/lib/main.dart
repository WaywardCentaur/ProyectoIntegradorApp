import 'package:flutter_settings_screens/flutter_settings_screens.dart';
// import 'package:magic_sdk/magic_sdk.dart';
import 'package:wallet/screens/auth/auth_screen.dart';
import 'package:wallet/screens/auth/verify_email_screen.dart';
import 'package:wallet/screens/settings/header_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Settings.init(cacheProvider: SharePreferenceCache());
  await dotenv.load(fileName: "assets/.env");
  // Magic.instance = Magic.custom("pk_live_7B4D3D72E7DA1973", rpcUrl: "http://192.168.50.158:3334", chainId: 4200420042);

  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  static const String title = 'Firebase Auth';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ValueChangeObserver<bool>(
        cacheKey: HeaderScreen.keyDarkMode,
        defaultValue: true,
        builder: (_, isDarkMode, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Home",
          theme: isDarkMode
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                      primary: Colors.red[900], secondary: Colors.white),
                )
              : ThemeData.light().copyWith(
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                      primary: Colors.redAccent, secondary: Colors.black),
                ),
          home: const MainScreen(),
        ),
      );
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return VerifyEmailScreen();
            } else {
              return const AuthScreen();
            }
          },
        ),
      );
}
