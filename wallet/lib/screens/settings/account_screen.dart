import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import 'package:wallet/widgets/icon_widget.dart';

class AccountScreen extends StatelessWidget {
  static const keyLanguage = 'key-language';
  static const keyLocation = 'key-location';
  static const keyPassword = 'key-password';

  @override
  Widget build(BuildContext context) => SimpleSettingsTile(
        title: 'Configuracion de cuenta',
        leading: IconWidget(icon: Icons.person, color: Colors.green),
        child: SettingsScreen(
          title: 'Configuracion de cuenta',
          children: <Widget>[
            buildPassword(),
            buildAccountInfo(context),
          ],
        ),
      );

  Widget buildPassword() => TextInputSettingsTile(
        settingKey: keyPassword,
        title: 'Password',
        obscureText: true,
        validator: (password) => password != null && password.length >= 6
            ? null
            : 'Enter 6 characters',
      );

  Widget buildAccountInfo(BuildContext context) => SimpleSettingsTile(
        title: 'Account Info',
        subtitle: '',
        leading: IconWidget(icon: Icons.text_snippet, color: Colors.purple),
        onTap: () {},
      );
}
