import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void addUserDetails(privateKey, publicKey) async {
  var userInstance = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userInstance!.uid)
      .set({
        'privateKey': privateKey.toString(),
        'publicKey': publicKey.toString(),
        'wallet_created': true,
      }, SetOptions(merge: true))
      .whenComplete(() => {print("executed")})
      .catchError((error) {
        print(error.toString());
      });
}

void updAdminRole(bool state, String address) async {
  var userInstance = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance
      .collection("users")
      .doc(await _getUIDFromAddress(address))
      .update({
        'admin': state,
      })
      .whenComplete(() => {print("executed")})
      .catchError((error) {
        print(error.toString());
      });
}

void addRole(String rol, String address) async {
  var userInstance = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance
      .collection("users")
      .doc(await _getUIDFromAddress(address))
      .update({
        'rol': rol,
      })
      .whenComplete(() => {print("executed")})
      .catchError((error) {
        print(error.toString());
      });
}

void updMinterRole(bool state, String address) async {
  var userInstance = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance
      .collection("users")
      .doc(await _getUIDFromAddress(address))
      .update({
        'minter': state,
      })
      .whenComplete(() => {print("executed")})
      .catchError((error) {
        print(error.toString());
      });
}

void updDirectorRole(bool state, String address) async {
  var userInstance = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance
      .collection("director")
      .doc(await _getUIDFromAddress(address))
      .update({
        'minter': state,
      })
      .whenComplete(() => {print("executed")})
      .catchError((error) {
        print(error.toString());
      });
}

void addUserName(username, cod, email) async {
  var userInstance = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userInstance!.uid)
      .set({
        'user_name': username,
        'codigo': cod,
        'email': email,
        'wallet_created': false,
        'minter': false,
        'admin': false,
        'rol': 'usuario',
        'director': false,
        'image':
            'https://www.wipo.int/export/sites/www/wipo_magazine/images/en/2018/2018_01_art_7_1_400.jpg'
      })
      .whenComplete(() => {print("executed")})
      .catchError((error) {
        print(error.toString());
      });
}

Future<dynamic> getUserDetails() async {
  dynamic data;
  var userInstance = FirebaseAuth.instance.currentUser;
  final DocumentReference document =
      FirebaseFirestore.instance.collection("users").doc(userInstance!.uid);
  await document.get().then<dynamic>((DocumentSnapshot snapshot) {
    data = snapshot.data();
  });
  return data;
}

Future<dynamic> getNetworkDetails() async {
  dynamic data;
  var userInstance = FirebaseAuth.instance.currentUser;
  final DocumentReference document =
      FirebaseFirestore.instance.collection("blockdata").doc("main");
  await document.get().then<dynamic>((DocumentSnapshot snapshot) {
    data = snapshot.data();
  });
  return data;
}

Future<String> getKeyFromEmail(String email) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .where('email', isEqualTo: email)
      .get();
  print(snapshot.docs.first.id);
  return snapshot.docs.first['publicKey'];
}

Future<bool> getAdminFromEmail(String email) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .where('email', isEqualTo: email)
      .get();
  print(snapshot.docs.first.id);
  return snapshot.docs.first['admin'];
}

Future<String> _getUIDFromAddress(String address) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .where('publicKey', isEqualTo: address)
      .get();

  return snapshot.docs.first.id;
}

Future<String> getRolFromEmail(String email) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .where('email', isEqualTo: email)
      .get();

  return snapshot.docs.first['rol'];
}

Future<String> getNameFromAddress(String adress) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .where('publicKey', isEqualTo: adress)
      .get();

  return snapshot.docs.first['user_name'];
}

Future<bool> checkForUserByEmail(String email) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .where('email', isEqualTo: email)
      .get();
  bool exists = snapshot.docs.isNotEmpty;
  var dat = await getUserDetails();
  bool validWallet = dat['wallet_created'];

  bool ans = false;
  if (exists && validWallet) {
    ans = true;
  }

  return ans;
}
