import 'package:flutter/material.dart';

class MyMissile extends StatelessWidget {
  final missileX;
  final missileHeight;
  MyMissile({this.missileX,this.missileHeight});

  @override
  Widget build(BuildContext context) {
    return  Container(
        alignment: Alignment(missileX,1),
        child:Container(
          width: 2,
          height: missileHeight,
          color: Colors.grey,
        )
    );
  }
}
