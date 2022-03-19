import 'dart:async';

import 'package:bubbkegame0318/widget/MyButton.dart';
import 'package:bubbkegame0318/widget/ball.dart';
import 'package:bubbkegame0318/widget/missile.dart';
import 'package:bubbkegame0318/widget/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

enum direction {LEFT, RIGHT}

class _HomePageState extends State<HomePage> {
  static double playerX = 0;

  //Missile variables
  double missileX = playerX;
  double missileHeight = 10;
  bool midShot = false;

  //ball variables
  double ballX = 0.5;
  double ballY = 1;
  var ballDirection = direction.LEFT;

  void startGame(){

    double time = 0;
    double height = 0;
    double velocity = 60; //how strong jump is
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      height = -5 * time * time + velocity * time;
      //if the ball reaches the ground, reset the jump
      if(height < 0){
        time = 0;
      }

      //update new ball direction
      setState(() {
        ballY = heightToPosition(height);
      });

      time += 0.1;

      //if the ball hits the left wall, then change direction to right
      if(ballX - 0.005 < -1){
        ballDirection = direction.RIGHT;
        //if the ball hits the right wall, then change direction to left
      }else if(ballX + 0.005 > 1){
        ballDirection = direction.LEFT;
      }
        //move the ball in the correct direction
      if(ballDirection == direction.LEFT){
        setState(() {
          ballX -= 0.005;
        });
      } else if(ballDirection == direction.RIGHT){
        setState(() {
          ballX += 0.005;
        });
      }
      //check if ball hits the player
      if(playerDies()){
        timer.cancel();
        _showDialog();
      }

    });
  }


  void moveLeft(){
    setState(() {
      if(playerX - 0.1 < -1){
        //do nothing
      } else{
        playerX -= 0.1;
      }

      // only make the X co0rdinate the same when it isn't in the middle of a shot
      if(!midShot){
        missileX = playerX;
      }

    });
  }

  void moveRight(){
    setState(() {
      if(playerX + 0.1 > 1){
        //do nothing
      } else{
        playerX += 0.1;
      }
      missileX = playerX;
    });
  }

  void fireMissile(){
   if(midShot == false){
     Timer.periodic(Duration(milliseconds: 20),(timer){
       midShot = true;
       //missile grows til it hits the top of the screen
       setState(() {
         missileHeight += 10;
       });

       //stop missle when it reaches top of screen
       if(missileHeight > MediaQuery.of(context).size.height * 3/4) {
         //stop missile
         resetMissile();
         timer.cancel();
       }
       //check if missile has hit the ball
       if(ballY > heightToPosition(missileHeight) &&
           (ballX - missileX).abs() < 0.03) {
         resetMissile();
         ballX = 5;
         timer.cancel();
       }
     });
   }
  }

  //convert height to  a coodinate
  double heightToPosition(double height){
    double totalHeight = MediaQuery.of(context).size.height * 3/4;
    double position = 1- 2 * height / totalHeight;
    return position;
  }

  void resetMissile(){
    missileX = playerX;
    missileHeight = 10;
    midShot = false;
  }

  bool playerDies(){
    //if player position and the ball position are the same,
    // then player dies
    if((ballX - playerX).abs() < 0.05 && ballY > 0.95){
      return true;
    }else{
      return false;
    }
  }

  void _showDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: Colors.grey[700],
          title: Center(
            child: Text('You dead!!',
            style: TextStyle(
              color: Colors.white
            ),),
          ),
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event){
        if(event.isKeyPressed(LogicalKeyboardKey.arrowLeft)){
          moveLeft();
        }else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)){
          moveRight();
        }
        if(event.isKeyPressed(LogicalKeyboardKey.space)){
          fireMissile();
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 3,
              child: Container(
                color: Colors.pink[100],
                child: Center(
                  child: Stack(
                    children: [
                      MyBall(ballX: ballX, ballY: ballY),
                     MyMissile(missileX: missileX, missileHeight: missileHeight,),
                      MyPlayer(playerX: playerX,),

                    ],
                  ),
                ),
              )),
          Expanded(
              child: Container(
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyButton(
                      icon: Icons.play_arrow,
                      function: startGame,
                    ),
                    MyButton(
                      icon: Icons.arrow_back,
                      function: moveLeft,
                    ),
                    MyButton(
                      icon: Icons.arrow_upward,
                      function: fireMissile,
                    ),
                    MyButton(
                      icon: Icons.arrow_forward,
                      function: moveRight,
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
