import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:wallet/screens/unused/nft_screen.dart';
import 'package:wallet/screens/settings/header_screen.dart';
import 'package:wallet/screens/settings/settings_screen.dart';
import 'package:wallet/screens/NFT/wallet_screen.dart';

import 'nft_creation_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});
  static const String title = 'Settings';

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          child: WalletScreen(title: ""),
        ),
      );
}
