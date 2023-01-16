import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:wallet/screens/settings/account_screen.dart';
import 'package:wallet/screens/settings/header_screen.dart';
import 'package:wallet/screens/settings/notification_screen.dart';
import 'package:wallet/screens/settings/wallet_settings_screen.dart';

import 'package:wallet/widgets/icon_widget.dart';

import '../../utilities/firestore.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String image =
      "https://www.wipo.int/export/sites/www/wipo_magazine/images/en/2018/2018_01_art_7_1_400.jpg";
  String name = "user";

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  details() async {
    dynamic data = await getUserDetails();
    data['wallet_created'] == true
        ? setState(() {
            name = data['user_name'];
            image = data['image'];
            print(image);
          })
        : print("Data is NULL!");
  }

  @override
  void initState() {
    details();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              HeaderScreen(name: name, image: image),
              SettingsGroup(
                title: 'GENERAL',
                children: <Widget>[
                  AccountScreen(),
                  NotificationsScreen(),
                  WalletSScreen(),
                  buildLogout(),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );

  Widget buildLogout() => SimpleSettingsTile(
        title: 'Logout',
        subtitle: '',
        leading: const IconWidget(icon: Icons.logout, color: Colors.blueAccent),
        onTap: () => FirebaseAuth.instance.signOut(),
      );
}
