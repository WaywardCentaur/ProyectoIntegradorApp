import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:wallet/widgets/icon_widget.dart';
import 'package:wallet/utilities/wallet_creation.dart';
import 'package:wallet/utilities/firestore.dart';

class WalletSScreen extends StatefulWidget {
  @override
  _WalletSScreenState createState() => _WalletSScreenState();
}

class _WalletSScreenState extends State<WalletSScreen> {
  int selected = 0;
  String? pubAddress;
  String? privAddress;
  String? username;
  bool? minter;

  @override
  void initState() {
    super.initState();
    details();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  details() async {
    dynamic data = await getUserDetails();
    data != null
        ? setState(() {
            privAddress = data['privateKey'];
            pubAddress = data['publicKey'];
            username = data['user_name'];
            print(pubAddress);
            minter = false;
            bool created = data['wallet_created'];
            created == true ? selected = 1 : selected = 0;
          })
        : setState(() {
            selected = 0;
          });
  }

  create() async {
    WalletAddress service = WalletAddress();
    final mnemonic = service.generateMnemonic();
    final privateKey = await service.getPrivateKey(mnemonic);
    final publicKey = await service.getPublicKey(privateKey);
    privAddress = privateKey;
    pubAddress = publicKey.toString();
    addUserDetails(privateKey, publicKey);
    setState(() {
      selected = 1;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => SimpleSettingsTile(
        title: 'Billetera',
        leading: IconWidget(
          icon: Icons.wallet,
          color: Colors.redAccent,
        ),
        child: SettingsScreen(
          title: 'Billetera',
          children: <Widget>[
            selected == 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(20),
                        child: const Text("Añadir Billetera"),
                      ),
                      Container(
                          margin: const EdgeInsets.all(20),
                          child: ElevatedButton(
                            child: const Icon(Icons.add),
                            onPressed: create,
                          ))
                    ],
                  )
                : Column(
                    children: [
                      Center(
                          child: Container(
                        margin: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: const Text(
                          "Datos de tu Billetera",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                          ),
                        ),
                      )),
                      const Center(
                        child: Text(
                          "Direccion Publica: ",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        width: 250,
                        child: Text(
                          "${pubAddress}",
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Divider(),
                      const Center(
                        child: Text(
                          "Direccion Privada:",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Container(
                        width: 250,
                        child: Text(
                          "${privAddress}",
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Container(
                        width: 250,
                        child: Text(
                          "No compartas esta direccion Privada con nadie.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
          ],
        ),
      );
}
