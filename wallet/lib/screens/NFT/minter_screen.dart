import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:wallet/screens/NFT/nft_creation_screen.dart';
import 'package:wallet/screens/settings/header_screen.dart';
import 'package:wallet/screens/settings/settings_screen.dart';
import 'package:wallet/screens/NFT/wallet_screen.dart';

class MinterScreen extends StatefulWidget {
  const MinterScreen({super.key});
  static const String title = 'Settings';

  @override
  _MinterScreenState createState() => _MinterScreenState();
}

class _MinterScreenState extends State<MinterScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  tabs: [
                    Tab(text: 'Billetera'),
                    Tab(text: 'Crear'),
                  ],
                ),
                title: Text(''),
              ),
              body: TabBarView(
                children: [WalletScreen(title: ""), NFTCreationScreen()],
              ),
            )),
      );
}
