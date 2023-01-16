import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:wallet/screens/NFT/nft_creation_screen.dart';
import 'package:wallet/screens/NFT/transfer_screen.dart';
import 'package:wallet/screens/settings/header_screen.dart';
import 'package:wallet/screens/settings/settings_screen.dart';
import 'package:wallet/screens/NFT/wallet_screen.dart';

class DirectorScreen extends StatefulWidget {
  const DirectorScreen({super.key});
  static const String title = 'Settings';

  @override
  _DirectorScreenState createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  tabs: [
                    Tab(text: 'Billetera'),
                    Tab(text: 'Crear'),
                    Tab(text: 'Transferir'),
                  ],
                ),
                title: Text(''),
              ),
              body: TabBarView(
                children: [
                  WalletScreen(title: ""),
                  NFTCreationScreen(),
                  TransferScreen()
                ],
              ),
            )),
      );
}
