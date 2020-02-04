import 'package:flutter/material.dart';

class BuildBodyBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 1000,
      child: Image.asset(
        "images/stonks.jpg",
        fit: BoxFit.cover,
        height: 1000.0,
      ),
      /*decoration: BoxDecoration(
        image: DecorationImage(image: ),
          gradient: LinearGradient(colors: [
        Color.fromARGB(255, 0, 0, 0),
        Color.fromARGB(255, 0, 00, 80) //RGBA(0,4,80,0)
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),*/
    );
  }
}

Widget txt(String txt, {style}) {
  return Text(txt,
      style: TextStyle(
          fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white));
}

Widget iconVariation(double variation) {
  if (variation > 0) {
    return Icon(Icons.arrow_drop_up, color: Colors.green, size: 60);
  } else if (variation < 0) {
    return Icon(Icons.arrow_drop_down, color: Colors.red, size: 60);
  } else {
    return Icon(Icons.remove, color: Colors.white, size: 60);
  }
}

Widget rowInfo(String title, String value, {TextStyle style, bool btn}) => Row(
      children: <Widget>[
        Container(
          child: Text(title,
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        Expanded(
          child: Container(),
        ),
        Container(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: (value.length > 18) ? 15 : 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))),
      ],
    );
