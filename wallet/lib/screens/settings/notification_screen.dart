import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:wallet/widgets/icon_widget.dart';

class NotificationsScreen extends StatelessWidget {
  static const keyActivity = 'key-activity';

  @override
  Widget build(BuildContext context) => SimpleSettingsTile(
        title: 'Notificaciones',
        leading: IconWidget(
          icon: Icons.notifications,
          color: Colors.redAccent,
        ),
        child: SettingsScreen(
          title: 'Notificaciones',
          children: <Widget>[
            buildActivity(context),
          ],
        ),
      );

  Widget buildActivity(BuildContext context) => SwitchSettingsTile(
        settingKey: keyActivity,
        leading: IconWidget(icon: Icons.person, color: Colors.orange),
        title: 'Activar Notificaciones',
        titleTextStyle: Theme.of(context).textTheme.bodyText2,
      );
}
