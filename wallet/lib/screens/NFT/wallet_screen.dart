import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:wallet/controllers/tokenController.dart';
import 'package:wallet/models/token.dart';
import 'package:wallet/widgets/nftTile.dart';
import 'package:web3dart/web3dart.dart';

import '../../utilities/firestore.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final controller = Get.put(TokenController());
  late Client httpClient;
  late Web3Client ethereumClient;

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

  _details() async {
    dynamic data = await getUserDetails();
    data['wallet_created'] == true
        ? setState(() {
            privAddress = data['privateKey'];
            address = data['publicKey'];
            minter = data['minter'];

            var temp = EthPrivateKey.fromHex("0x$privAddress");
            credentials = temp.address;
            // EthPrivateKey fromHex = EthPrivateKey.fromHex(privAddress);
            // final password = FirebaseAuth.instance.currentUser!.uid;
            // Random random=Random.secure();
            // Wallet wallet = Wallet.createNew(fromHex, password,random);
            // print(wallet.toJson());
            created = data['wallet_created'];
            _getBalance();
          })
        : print("Data is NULL!");
  }

  Future<List<dynamic>> _query(String functionName, List<dynamic> args) async {
    DeployedContract contract = await _getContract();
    ContractFunction function = contract.function(functionName);
    List<dynamic> result = await ethereumClient.call(
        contract: contract, function: function, params: args);
    balance =
        (await ethereumClient.getBalance(EthereumAddress.fromHex(address)))
            .getValueInUnit(EtherUnit.ether)
            .toString();
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

  Future<void> _getBalance() async {
    loading = true;
    setState(() {});
    List<dynamic> result =
        await _query('tokensOfOwner', [EthereumAddress.fromHex(address)]);
    balance =
        (await ethereumClient.getBalance(EthereumAddress.fromHex(address)))
            .getValueInUnit(EtherUnit.ether)
            .toString();

    _getMetaData(result.toString());
    loading = false;
    setState(() {});
  }

  Future<void> _getMetaData(String listOfTokens) async {
    final split =
        listOfTokens.replaceAll("[", "").replaceAll("]", "").split(',');
    List<Uri> tempList = [];
    for (int i = 0; i < split.length; i++) {
      if (split[i].isNotEmpty) {
        BigInt bTokenID = BigInt.from(int.parse(split[i]));
        List<dynamic> result = await _query('tokenURI', [bTokenID]);
        tempList.add(Uri.parse(
            result.toString().replaceAll("[", "").replaceAll("]", "")));
      }
    }

    NFTUriList = tempList;
    nftList.clear();

    for (int j = 0; j < NFTUriList.length; j++) {
      _readJsonFile(NFTUriList.elementAt(j));
    }

    for (Token i in controller.getTokenList) {
      nftList.add(NFTTile(title: i.title, owner: i.owner, image: i.image));
    }
    controller.clearTokenList();
    setState(() {});
  }

  Future<void> _readJsonFile(Uri uri) async {
    var response = await http.get(uri);
    print(response.body);

    try {
      var data = await jsonDecode(response.body);
      controller.addTokenToList(Token(
          await getNameFromAddress(data['owner']),
          data['image'],
          data['title'],
          data['subject'],
          data['nrc'],
          data['professor'],
          data['date'],
          data['rank'],
          data['details']));
      controller.refresh;
      setState(() {});
    } on FormatException catch (e) {
      print('The provided string is not valid JSON');
    }
  }

  List<NFTTile> nftList = [];

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethereumClient = Web3Client(ethereumClientUrl, httpClient);
    for (Token i in controller.tokenList) {
      nftList.add(NFTTile(title: i.title, owner: i.owner, image: i.image));
    }
    _details();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          SizedBox(
            height: 30,
          ),
          // minter
          //     ? Column(
          //         children: [
          //           Text(
          //             "Balance",
          //             style:
          //                 TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          //           ),
          //           Text(
          //             balance.toString(),
          //             style:
          //                 TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
          //           ),
          //         ],
          //       )
          //     : Spacer(),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: nftList.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, childAspectRatio: 7 / 6),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(onTap: () {}, child: nftList[index]);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: IconButton(
                  onPressed: address.isNotEmpty ? _getBalance : () {},
                  icon: Icon(Icons.refresh),
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
