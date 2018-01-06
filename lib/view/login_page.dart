import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'register_page.dart';
import 'package:flutter_firebase/bean/User.dart';
import 'package:flutter_firebase/util/Constant.dart';

class LoginPage extends StatefulWidget {

  @override
  State createState() {
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;


  @override
  initState() {
    super.initState();
    isLogin();
  }

  isLogin() async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      switchPageToHome(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('Login'),
        ),
        body: mainBody()
    );
  }

  Widget mainBody() {
    return new Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            buildInputField(context, "Enter your email", Icons.email, false,
                _emailController),
            buildInputField(context, "Enter your password", Icons.lock, true,
                _passwordController),
            new Container(
                margin: const EdgeInsets.only(top: 46.0),
                child: loading ? loader() : loginButton()
            ),
            new Container(
                child: new GestureDetector(
                  onTap: switchPageToRegister,
                  child: new Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.bottomCenter,
                      child: new Text("Not yet Registerd? Register Now.",
                        style: new TextStyle(color: Colors.deepPurple,
                            decoration: TextDecoration.underline),)
                  ),
                )
            ),
          ],
        )
    );
  }

  Widget loader() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new CircularProgressIndicator()
      ],
    );
  }

  Widget loginButton() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RaisedButton(
          onPressed: click,
          child: new Text(
            'Login',
            style: new TextStyle(color: Colors.deepPurple),),)
      ],
    );
  }

  click() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      showLoading(true);
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user != null) {
        _showMessage(user.uid);
        switchPageToHome(user);
      } else {
        showLoading(false);
        _showMessage("Something went wrong.");
      }
    } else {
      _showMessage("All fields required.");
    }
  }

  switchPageToHome(FirebaseUser firebaseuser) async {
    final DatabaseReference _counterRef = FirebaseDatabase.instance.reference()
        .child(Constant.TABLE_USER).child(firebaseuser.uid);
    DataSnapshot snapshot = await _counterRef.once();
    if (snapshot.value != null) {
      showLoading(false);
      User user = new User(
          firebaseuser.uid, firebaseuser.email, snapshot.value['name'],
          snapshot.value['userImage']);
      Navigator.of(context).pop();
      Navigator.of(context).push(
          new MaterialPageRoute(builder: (c) {
            return new HomePage(user);
          })
      );
    }
    // Navigator.of(context).pop(true);
  }

  void switchPageToRegister() {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (c) {
          return new RegisterPage();
        })
    );
  }

  void _showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(message)
    ));
  }

  void showLoading(bool isLoading) {
    setState(() {
      loading = isLoading;
    });
  }
}

/// create InputField
Widget buildInputField(BuildContext context, String hint, IconData
iconData,
    bool isPassword, TextEditingController controller) {
  return new Container(
      decoration: new BoxDecoration(
          border: new Border.all(color: Colors.grey)
      ),
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.only(top: 16.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Icon(iconData, color: Colors.deepPurple,),
          new Flexible(
              child: new Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: new TextField(
                  controller: controller,
                  style: new TextStyle(fontSize: 16.0, color: Colors.deepPurple),
                  decoration: new InputDecoration.collapsed(hintText: hint),
                  obscureText: isPassword,
                ),)),
        ],
      )
  );
}


/*Widget mainBody() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              buildInputField(context, "Enter your email", Icons.email, false,
                  _emailController),
              buildInputField(context, "Enter your password", Icons.lock, true,
                  _passwordController),
              new Container(
                  margin: const EdgeInsets.only(top: 46.0),
                  child: loading ? loader() : loginButton()
              ),
              new Container(
                  child: new GestureDetector(
                    onTap: switchPageToRegister,
                    child: new Container(
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.bottomCenter,
                        child: new Text("Not yet Registerd? Register Now.",
                          style: new TextStyle(color: Colors.deepOrange,
                              decoration: TextDecoration.underline),)
                    ),
                  )
              )
            ],
          ),
        ),
      ],
    );
  }*/