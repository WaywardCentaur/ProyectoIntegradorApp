import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/screens/NFT/student_screen.dart';
import 'package:wallet/screens/NFT/minter_screen.dart';
import 'package:wallet/screens/settings/settings_screen.dart';
import 'package:wallet/screens/unused/nft_screen.dart';
import 'package:wallet/utilities/wallet_creation.dart';

import '../../utilities/firestore.dart';
import '../NFT/admin_screen.dart';
import '../NFT/director_screen.dart';

class HomeScreen extends StatefulWidget {
  int index = 0;
  final screens = [
    const Center(child: Text('Page 1', style: TextStyle(fontSize: 32))),
    const Center(child: Text('Page 2', style: TextStyle(fontSize: 32))),
  ];
  @override
  State<StatefulWidget> createState() => _HomeScreeState();
}

class _HomeScreeState extends State<HomeScreen> {
  int index = 0;
  bool minter = false;
  bool admin = false;
  bool director = false;

  final screens = [
    const StudentScreen(),
    SettingsPage(),
  ];

  final screens2 = [
    const MinterScreen(),
    SettingsPage(),
  ];

  final screens3 = [
    const DirectorScreen(),
    SettingsPage(),
  ];

  final screens4 = [
    const AdminScreen(),
    SettingsPage(),
  ];

  _details() async {
    dynamic data = await getUserDetails();
    data != null
        ? setState(() {
            minter = data['minter'];
            admin = data['admin'];
            director = data['director'];
          })
        : print("Data is NULL!");
  }

  @override
  void initState() {
    _details();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: admin
            ? screens4[index]
            : director
                ? screens3[index]
                : minter
                    ? screens2[index]
                    : screens[index],
        bottomNavigationBar: buildNavigationBar(),
      );

  Widget buildNavigationBar() => NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.redAccent,
          indicatorColor: Colors.blue.shade100,
        ),
        child: NavigationBar(
          height: 60,
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          // animationDuration: Duration(seconds: 3),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wallet_giftcard_outlined),
              selectedIcon: Icon(Icons.photo_album),
              label: 'Billetera',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle),
              label: 'Cuenta',
            ),
          ],
        ),
      );
}

// Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Signed In as',
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               user.email!,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size.fromHeight(50),
//               ),
//               icon: const Icon(Icons.arrow_back, size: 32),
//               label: const Text(
//                 'Sign Out',
//                 style: TextStyle(fontSize: 24),
//               ),
//               onPressed: () => FirebaseAuth.instance.signOut(),
//             ),
//           ],
//         ),
//       ),
