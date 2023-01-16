import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:ipfs_client_flutter/ipfs_client_flutter.dart';
import 'package:wallet/service/ipfs_add.dart';
import 'package:wallet/widgets/create_nft_widget.dart';
import 'package:wallet/widgets/nftTile.dart';
import 'package:web3dart/web3dart.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/token.dart';
import '../../utilities/firestore.dart';

class NFTCreationScreen extends StatefulWidget {
  @override
  _NFTCreationState createState() => _NFTCreationState();
}

class _NFTCreationState extends State<NFTCreationScreen> {
  late Client httpClient;
  late Web3Client ethereumClient;

  final Dio _dio = Dio();
  final _baseUrl = 'https://ipfs.infura.io:5001';
  final _projectID = "2KCffGKrToDO2SEGEndt9ddrStS";
  final _projectToken = "4ae1942319cc8e09783d615f375df6df";

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
            created = data['wallet_created'];
            _getBalance();
          })
        : print("Data is NULL!");
  }

  Future<List<dynamic>> _query(String functionName, List<dynamic> args) async {
    DeployedContract contract = await _getContract();
    ContractFunction function = contract.function(functionName);
    List<dynamic> result = [];
    try {
      result = await ethereumClient.call(
          contract: contract, function: function, params: args);
      balance =
          (await ethereumClient.getBalance(EthereumAddress.fromHex(address)))
              .getValueInUnit(EtherUnit.ether)
              .toString();
    } catch (e, stackTrace) {
      print(e.toString());
    }
    return result;
  }

  _transaction(String functionName, List<dynamic> args) async {
    EthPrivateKey credential = EthPrivateKey.fromHex(privAddress);
    DeployedContract contract = await _getContract();
    ContractFunction function = contract.function(functionName);
    dynamic result;
    try {
      result = await ethereumClient.sendTransaction(
        credential,
        Transaction.callContract(
          contract: contract,
          function: function,
          parameters: args,
        ),
        fetchChainIdFromNetworkId: true,
        chainId: null,
      );
    } catch (e, stackTrace) {
      print(e.toString());
    }
  }

  Future<DeployedContract> _getContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");

    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );

    return contract;
  }

  _createToken(String recipientAddress) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss-d-MM-yyyy').format(now);
    final path = await _localPath;
    // final String response = await rootBundle.loadString('${path}/temp.json');
    final _authorizationToken =
        base64.encode(utf8.encode('$_projectID:$_projectToken'));

    LocalIpfsClient ipfsClient = LocalIpfsClient(
        url: "https://ipfs.infura.io:5001",
        authorizationToken: _authorizationToken);

    var response = await ipfsClient.add(
        dir: 'token/$formattedDate.png',
        filePath: '$path/temp.json',
        fileName: "$formattedDate.png");

    while (recipientAddress.isEmpty) {}
    _transaction('awardAchievement', [
      EthereumAddress.fromHex(recipientAddress),
      'https://usfqipfs.infura-ipfs.io/ipfs/${response['Hash']}'
    ]);
    // try {
    //   var res = await _dio.post(
    //     '$_baseUrl/api/v0/add?',
    //     data: response,
    //     options: Options(
    //       validateStatus: (_) => true,
    //       headers: {
    //         "authorization": _authorizationToken,
    //       },
    //     ),
    //   );

    //   print('User created: ${res.data}');

    //   print(res);
    // } catch (e) {
    //   print('Error creating user: $e');
    // }
    // final path = await _localPath;
    // File file = File('${path}/temp.json');
    // var token = Token(
    //     owner, image, title, subject, nrc, professor, date, rank, details);
    // String json = jsonEncode(token);
    // print(json);
    // file.writeAsString('$json');
  }

  Future<void> _getBalance() async {
    loading = true;
    setState(() {});
    // List<dynamic> result =
    //     await _query('tokensOfOwner', [EthereumAddress.fromHex(address)]);
    balance =
        (await ethereumClient.getBalance(EthereumAddress.fromHex(address)))
            .getValueInUnit(EtherUnit.ether)
            .toString();

    //_getMetaData(result.toString());
    loading = false;
    setState(() {});
  }

  // Future<void> _getMetaData(String listOfTokens) async {
  //   final split =
  //       listOfTokens.replaceAll("[", "").replaceAll("]", "").split(',');
  //   List<Uri> tempList = [];
  //   for (int i = 0; i < split.length; i++) {
  //     if (split[i].isNotEmpty) {
  //       BigInt bTokenID = BigInt.from(int.parse(split[i]));
  //       List<dynamic> result = await _query('tokenURI', [bTokenID]);
  //       tempList.add(Uri.parse(
  //           result.toString().replaceAll("[", "").replaceAll("]", "")));
  //     }
  //   }

  //   NFTUriList = tempList;
  //   print(NFTUriList);
  //   nftList = [];
  //   for (int j = 0; j < NFTUriList.length; j++) {
  //     _readJsonFile(NFTUriList.elementAt(j));
  //   }

  //   setState(() {});
  // }

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  // Future<void> _readJsonFile(Uri uri) async {
  //   Response response = await http.get(uri);
  //   Map<String, dynamic> data = jsonDecode(response.body);
  //   print(data);
  //   var tempTile = NFTTile(
  //       title: data["title"], owner: data["owner"], image: data["image"]);
  //   nftList.add(tempTile);
  //   setState(() {});
  // }

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
          Column(
            children: [
              Text(
                "Balance",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                balance.toString(),
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Column(
            children: [CreateNFTWidget(createToken: _createToken)],
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
