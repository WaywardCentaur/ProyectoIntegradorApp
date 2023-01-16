import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wallet/main.dart';
import 'package:wallet/utilities/firestore.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/token.dart';

class CreateNFTWidget extends StatefulWidget {
  final Function(String) createToken;

  const CreateNFTWidget({
    Key? key,
    required this.createToken,
  }) : super(key: key);

  @override
  _CreateNFTWidgetState createState() => _CreateNFTWidgetState();
}

class _CreateNFTWidgetState extends State<CreateNFTWidget> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final subjectController = TextEditingController();
  final nrcController = TextEditingController();
  final ownerController = TextEditingController();
  bool validEmail = false;
  DateTime now = DateTime.now();
  String ownerAdress = "";
  String professor = "";

  String dropdownvalue = 'A';

  // List of items in our dropdown menu
  var items = ['S+', 'S', 'A', 'B', 'C', 'D', 'F'];

  var images = [
    "https://news.wttw.com/sites/default/files/styles/full/public/article/image-non-gallery/ee3b6579-97bb-4fea-899c-d2425f456cc5.jpg?itok=wbmbZ9AT",
    "https://ca-times.brightspotcdn.com/dims4/default/6ec92a0/2147483647/strip/true/crop/1026x1129+0+0/resize/1026x1129!/quality/80/?url=https%3A%2F%2Fcalifornia-times-brightspot.s3.amazonaws.com%2F5b%2F2f%2Fa8ea8baf460588888e506b0f6576%2Fla-me-slo-monkey.jpg",
    "https://static.scientificamerican.com/sciam/cache/file/885FD6DB-C422-4BC5-A617827873CE6EB1_source.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAuJl5Pg4CJLjWUPmRKfWuD-Bd3qyzFEl7iQ&usqp=CAU",
    "https://i.dawn.com/primary/2022/05/628072c395a80.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQV4fBHifRltkLYJl234lfmX_ZfhDOqihw-w&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSSPfjR0B7Rtm4h2yytXXDeKxg4y-fvDQ7Bnw&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSK-KfZnh4vJE1VnD0Z9AVbHp0IIlm9bN21lg&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQt1HRf2R0Oy_P-YIFYC8qXxTnzcnHNvjuGEA&usqp=CAU",
    "https://animals.sandiegozoo.org/sites/default/files/2016-09/animals_hero_monkey.jpg",
  ];

  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    subjectController.dispose();
    nrcController.dispose();
    ownerController.dispose();

    super.dispose();
  }

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  _createTokenJson() async {
    final path = await _localPath;
    File file = File('${path}/temp.json');
    var token = Token(
        ownerAdress,
        images[Random().nextInt(images.length)],
        titleController.text.trim(),
        subjectController.text.trim(),
        nrcController.text.trim(),
        professor,
        DateFormat('kk:mm:ss \n EEE d MMM').format(now),
        dropdownvalue,
        detailsController.text.trim());
    String json = jsonEncode(token);

    await file.writeAsString('$json');
    print('address $ownerAdress');
    widget.createToken(ownerAdress);
  }

  _getAdress(String email) async {
    dynamic dta = await getUserDetails();
    professor = dta['user_name'];
    String d = await getKeyFromEmail(email);
    ownerAdress = d;
  }

  Future<bool> _checkEmail(String email) async {
    validEmail = await checkForUserByEmail(email);
    if (validEmail) {
      _getAdress(email);
    }
    return validEmail;
  }

  bool _checkFields() {
    if (validEmail &&
        titleController.text.isNotEmpty &&
        detailsController.text.isNotEmpty &&
        subjectController.text.isNotEmpty &&
        nrcController.text.isNotEmpty) {
      validEmail = false;
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Creemos un token!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: titleController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Titulo'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 1
                    ? 'Como se llama este token?.'
                    : null,
              ),
              TextFormField(
                controller: detailsController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'detalles'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 1
                    ? 'Ingresa detallles del token.'
                    : null,
              ),
              TextFormField(
                controller: subjectController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Curso'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 1
                    ? 'Este campo no puede estar vacio.'
                    : null,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: nrcController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'NRC del curso'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 1
                    ? 'Este campo no puede estar vacio.'
                    : null,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Selecciona el rango:"),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: ownerController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Correo del estudiante.'),
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
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                label: const Text(
                  'Crear Token',
                  style: TextStyle(fontSize: 24),
                ),
                icon: const Icon(Icons.arrow_forward, size: 32),
                onPressed: () {
                  _checkFields()
                      ? _createTokenJson()
                      : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Todos los campos deben estar llenos.')));
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
}
