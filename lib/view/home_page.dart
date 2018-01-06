import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase/util/Constant.dart';
import 'package:flutter_firebase/bean/User.dart';
import 'package:flutter_firebase/view/post_page.dart';
import 'package:flutter_firebase/view/users_list_page.dart';
import 'package:flutter_firebase/view/edit_profile_page.dart';
import 'package:flutter_firebase/bean/PostItem.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  final User user;

  HomePage(this.user);

  @override
  State createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          leading: new IconButton(
              icon: new Icon(Icons.person, color: Colors.white,),
              onPressed: switchToProfile),
          title: new Text(widget.user.name),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.camera_alt, color: Colors.white,),
                onPressed: () {
                  switchToPost(context);
                }),
            new IconButton(icon: new Icon(Icons.list, color: Colors.white,),
                onPressed: () {
                  switchToUsers(context);
                })
          ],
        ),
        body: loginButton()
    );
  }

  Widget loginButton() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RaisedButton(
          onPressed: null,
          child: new Text(
            'Login',
            style: new TextStyle(color: const Color(0xFFff6347)),),)
      ],
    );
  }


  switchToPost(BuildContext context) {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (c) {
          return new PostPage(widget.user);
        })
    );
  }

  switchToUsers(BuildContext context) {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (c) {
          return new UsersListPage(widget.user);
        })
    );
  }

  switchToProfile() {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (c) {
          return new EditProfilePage(widget.user);
        })
    );
  }
}