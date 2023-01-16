import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:pointycastle/digests/keccak.dart';
import 'package:wallet/widgets/create_nft_widget.dart';
import 'package:wallet/widgets/nftTile.dart';
import 'package:web3dart/web3dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/pointycastle.dart';
import '../../models/token.dart';
import '../../utilities/firestore.dart';

class RolAssignScreen extends StatefulWidget {
  @override
  _RolAssignState createState() => _RolAssignState();
}

class _RolAssignState extends State<RolAssignScreen> {
  late Client httpClient;
  late Web3Client ethereumClient;

  String dropdownvalue = 'Emisor';
  final titleController = TextEditingController();

  // List of items in our dropdown menu
  var items = ['Emisor', 'Director de Area', 'Usuario'];

  final ownerController = TextEditingController();

  String directorRol = 'director';
  String minterRol = 'minter';
  String _rolDescr = '';

  String minterRolHex =
      "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";

  String privAddress = "";
  var credentials;
  bool? created;
  bool minter = false;
  bool admin = false;

  final digest = KeccakDigest(256);

  String address = '';
  String ethereumClientUrl = dotenv.env['NETWORK_ADDRESS']!;
  String contractAddress = dotenv.env['CONTRACT_ADDRESS']!;
  String contractName = dotenv.env['CONTRACT_NAME']!;
  String balance = "0.0";
  bool loading = false;
  List<Uri> NFTUriList = [];
  bool _validEmail = false;
  String _recipientAddress = '';

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    ownerController.dispose();

    super.dispose();
  }

  _getAdress(String email) async {
    admin = await getAdminFromEmail(email);
    String d = await getKeyFromEmail(email);
    _recipientAddress = d;
    String dd = await getRolFromEmail(email);
    _rolDescr = dd;
    setState(() {
      _rolDescr = dd;
    });
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
          })
        : print("Data is NULL!");
  }

  Future<String> _contractFunction(
      String functionName, List<dynamic> args) async {
    DeployedContract contract = await _getContract();
    ContractFunction function = contract.function(functionName);
    var result = await ethereumClient.sendTransaction(
      EthPrivateKey.fromHex("0x$privAddress"),
      Transaction.callContract(
          contract: contract, function: function, parameters: args),
      fetchChainIdFromNetworkId: true,
      chainId: null,
    );

    return result;
  }

  Future<DeployedContract> _getContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");

    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );

    return contract;
  }

  Future<void> _setRole(String receiverAddress, String rol) async {
    final minterHash = digest.process(ascii.encode('MINTER_ROLE'));
    String result = '';
    switch (rol) {
      case 'Director de Area':
        updAdminRole(false, receiverAddress);
        updMinterRole(true, receiverAddress);
        updDirectorRole(true, receiverAddress);
        result = await _contractFunction("grantRole",
            [minterHash, EthereumAddress.fromHex(receiverAddress)]);
        addRole(titleController.text.trim(), _recipientAddress);

        break;

      case 'Emisor':
        updMinterRole(true, receiverAddress);
        updAdminRole(false, receiverAddress);
        updDirectorRole(false, receiverAddress);
        result = await _contractFunction("grantRole",
            [minterHash, EthereumAddress.fromHex(receiverAddress)]);
        addRole(titleController.text.trim(), _recipientAddress);
        break;
      case 'Usuario':
        updAdminRole(false, receiverAddress);
        updMinterRole(false, receiverAddress);
        updDirectorRole(false, receiverAddress);
        result = await _contractFunction("revokeRole",
            [minterHash, EthereumAddress.fromHex(receiverAddress)]);
        addRole(titleController.text.trim(), _recipientAddress);

        break;
    }
    print(result);
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
        padding: EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 30,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: ownerController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Correo de quien recibira el rol.'),
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
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 40,
                child: Text('Este usuario tiene rol de: $_rolDescr'),
              ),
              Row(
                children: [
                  Text("Selecciona el tipo de rol:"),
                  DropdownButton(
                    value: dropdownvalue,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: titleController,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.length < 1
                        ? 'Como se llama este rol?.'
                        : null,
                  )),
            ],
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              label: const Text(
                'Dar Rol',
                style: TextStyle(fontSize: 24),
              ),
              icon: const Icon(Icons.arrow_forward, size: 32),
              onPressed: () {
                _validEmail
                    ? (admin
                        ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('No puede cambiar el rol de un admin.')))
                        : _setRole(_recipientAddress, dropdownvalue))
                    : ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Valide el destinatario.')));
              },
            ),
          )
        ],
      ),
    );
  }
}
