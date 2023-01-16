import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:wallet/widgets/create_nft_widget.dart';
import 'package:wallet/widgets/nftTile.dart';
import 'package:web3dart/web3dart.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/token.dart';
import '../../utilities/firestore.dart';

class TransferScreen extends StatefulWidget {
  @override
  _TransferState createState() => _TransferState();
}

class _TransferState extends State<TransferScreen> {
  late Client httpClient;
  late Web3Client ethereumClient;

  final ownerController = TextEditingController();
  final codeController = TextEditingController();

  String _recipientAddress = "";
  String _senderAddress = "";
  bool _validEmail = false;
  bool _invalidTransaction = true;

  String privAddress = "";
  var credentials;
  bool? created;
  bool minter = false;

  String address = '';
  String ethereumClientUrl = dotenv.env['NETWORK_ADDRESS']!;
  String contractAddress = dotenv.env['CONTRACT_ADDRESS']!;
  String contractName = dotenv.env['CONTRACT_NAME']!;
  String balance = "0.0";
  bool loading = false;
  List<Uri> NFTUriList = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    ownerController.dispose();

    super.dispose();
  }

  _getAdress(String email) async {
    dynamic dta = await getUserDetails();
    _senderAddress = dta['publicKey'];
    String d = await getKeyFromEmail(email);
    _recipientAddress = d;
  }

  Future<bool> _checkEmail(String email) async {
    _validEmail = await checkForUserByEmail(email);
    if (_validEmail) {
      _getAdress(email);
    }
    return _validEmail;
  }

  _details() async {
    dynamic data = await getUserDetails();
    data['wallet_created'] == true
        ? setState(() {
            privAddress = data['privateKey'];
            address = data['publicKey'];
            minter = data['minter'];
            var temp = EthPrivateKey.fromHex("0x$privAddress");
            credentials = temp.address;
            created = data['wallet_created'];
            _getBalance();
          })
        : print("Data is NULL!");
  }

  _transfer(int amount) async {
    final cred = EthPrivateKey.fromHex("0x$privAddress");
    try {
      _validEmail && double.parse(balance) > amount
          ? await ethereumClient.sendTransaction(
              cred,
              Transaction(
                to: EthereumAddress.fromHex(_recipientAddress),
                value: EtherAmount.fromUnitAndValue(EtherUnit.ether, amount),
              ),
              fetchChainIdFromNetworkId: true,
              chainId: null,
            )
          : print("invalid transaction");
    } catch (e, stackTrace) {
      print(e.toString());
    }
    _getBalance();
  }

  Future<void> _getBalance() async {
    balance =
        (await ethereumClient.getBalance(EthereumAddress.fromHex(address)))
            .getValueInUnit(EtherUnit.ether)
            .toString();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethereumClient = Web3Client(ethereumClientUrl, httpClient);
    _details();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "Balance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Text(
              balance.toString(),
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 5),
            Text("Datos de transferencia."),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 200,
                child: TextFormField(
                  controller: ownerController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      labelText: 'Correo al cual enviar.'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? 'Ingresa un correo valido.'
                          : null,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _checkEmail(ownerController.text.trim())
                      ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Billetera encontrada.'),
                        ))
                      : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Este correo no tiene una billetera asociada.')));
                },
                child: Text("Validar"),
              ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
                width: 200,
                child: TextFormField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.next,
                  decoration:
                      const InputDecoration(labelText: 'Cantidad a enviar'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value != null ? 'Ingrese un valor' : null,
                )),
          ]),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () async {
                _transfer(int.parse(codeController.text.trim()));
                _getBalance();
                setState(() {
                  _getBalance();
                });
                _getBalance();
              },
              child: Text("Enviar"),
            ),
          )
        ],
      ),
    );
  }
}
