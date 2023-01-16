import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/models/token.dart';

class TokenController extends GetxController {
  List<Token> tokenList = <Token>[].obs;

  addTokenToList(Token) {
    tokenList.add(Token);
    print(tokenList.length);
  }

  clearTokenList() {
    tokenList.clear();
  }

  List<Token> get getTokenList {
    return tokenList;
  }
}
