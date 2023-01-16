import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import 'package:wallet/widgets/icon_widget.dart';

class HeaderScreen extends StatelessWidget {
  static const keyDarkMode = 'key-dark-mode';
  final String name;
  final String image;
  const HeaderScreen({Key? key, required this.name, required this.image});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          buildHeader(),
          const SizedBox(height: 32),
          buildUser(context),
          buildDarkMode(),
        ],
      );

  Widget buildDarkMode() => SwitchSettingsTile(
        settingKey: keyDarkMode,
        leading: IconWidget(
          icon: Icons.dark_mode,
          color: Color(0xFF642ef3),
        ),
        title: 'Dark Mode',
        onChange: (_) {},
      );

  Widget buildHeader() => Center(
        child: Text(
          'Settings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
      );

  Widget buildUser(BuildContext context) => InkWell(
        onTap: () {
          print(image);
        },
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              Spacer(),
              Icon(Icons.chevron_right_sharp),
            ],
          ),
        ),
      );
}
