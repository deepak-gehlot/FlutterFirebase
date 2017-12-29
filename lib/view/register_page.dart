import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase/bean/User.dart';
import 'package:flutter_firebase/util/Constant.dart';

class RegisterPage extends StatefulWidget {

  @override
  State createState() {
    return new RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('Register'),
        ),
        body: mainBody()
    );
  }

  Widget mainBody() {
    return new Container(
        margin: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            buildInputField(context, "Full Name", Icons.person, false,
                _nameController),
            buildInputField(context, "Enter your email", Icons.email, false,
                _emailController),
            buildInputField(context, "Enter your password", Icons.lock, true,
                _passwordController),
            buildInputField(context, "Confirm your password", Icons.lock, true,
                _confirmPasswordController),
            new Container(
                margin: const EdgeInsets.only(top: 26.0),
                child: loading ? loader() : loginButton()
            )
          ],
        )
    );
  }

  Widget loader() {
    return new Align(
      alignment: Alignment.topCenter,
      child: new CircularProgressIndicator(),
    );
  }

  Widget loginButton() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RaisedButton(
          onPressed: click,
          child: new Text(
            'Sign up',
            style: new TextStyle(color: const Color(0xFFff6347)),),)
      ],
    );
  }

  click() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        showLoading(true);
        FirebaseUser user = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        if (user != null) {
          _showMessage(user.uid);
          switchPage(user, name);
        } else {
          showLoading(false);
          _showMessage("Something went wrong.");
        }
      } else {
        _showMessage("Password not match.");
      }
    } else {
      _showMessage("All fields required.");
    }
  }

  switchPage(FirebaseUser firebaseUser, String name) async {
    User user = new User(firebaseUser.uid, firebaseUser.email, name, "");

    final DatabaseReference _counterRef = FirebaseDatabase.instance.reference()
        .child(Constant.TABLE_USER);
    await _counterRef.child(firebaseUser.uid).set({
      'emailId': firebaseUser.email,
      'name': name,
      'userId': firebaseUser.uid,
      'userImage': Constant.DEFAULT_IMAGE
    });
    showLoading(false);
    Navigator.of(context).pop();
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (c) {
          return new HomePage(user);
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
          new Icon(iconData, color: const Color(0xFFff6347),),
          new Flexible(
              child: new Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: new TextField(
                  controller: controller,
                  style: new TextStyle(fontSize: 16.0, color: Colors.red),
                  decoration: new InputDecoration.collapsed(hintText: hint),
                  obscureText: isPassword,
                ),)),
        ],
      )
  );
}