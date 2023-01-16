import 'package:flutter/material.dart';

class ErrorWidget extends StatelessWidget {
  final String error;

  const ErrorWidget({
    Key? key,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
          child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan,
        ),
        onPressed: () {},
        child: null,
      ));
}
