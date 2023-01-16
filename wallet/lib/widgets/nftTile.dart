import 'package:flutter/material.dart';

class NFTTile extends StatelessWidget {
  final String title;
  final String owner;
  final String image;

  const NFTTile({
    Key? key,
    required this.title,
    required this.owner,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 170,
        width: 200,
        child: Card(
          elevation: 2,
          child: Stack(children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  width: 240,
                  height: 100,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                      )),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          owner,
                          style: TextStyle(fontSize: 12),
                        ),
                      ]),
                ),
              ]),
            )
          ]),
        ));
  }
}
