import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter_firebase/util/Constant.dart';
import 'package:flutter_firebase/bean/User.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_firebase/view/chat_page.dart';
import 'package:flutter_firebase/bean/ChatBean.dart';

class UsersListPage extends StatefulWidget {

  final User user;

  UsersListPage(this.user);

  @override
  State createState() {
    return new UsersListPageState();
  }
}

class UsersListPageState extends State<UsersListPage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Friends"),
      ),
      body: new Container(
        child: _userList(),
      ),
    );
  }

  _userList() {
    final DatabaseReference _counterRef = FirebaseDatabase.instance.reference()
        .child(Constant.TABLE_USER);
    return new FirebaseAnimatedList(
      query: _counterRef,
      itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation,
          int index) {
        return new UserRow(snapshot, animation, index, widget.user);
      },
    );
  }
}

class UserRow extends StatelessWidget {

  final DataSnapshot snapshot;
  final Animation animation;
  final int index;
  final User user;

  UserRow(this.snapshot, this.animation, this.index, this.user);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new GestureDetector(
          onTap: () {
            onItemClick(index, context);
          },
          child: new Padding(padding: const EdgeInsets.all(10.0),
            child: new Row(
              children: <Widget>[
                new CircleAvatar(
                  child: new Text(snapshot.value['name'][0]),),
                new Expanded(child: new Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        snapshot.value['name'], style: _textStyle(),),
                      new Container(height: 5.0,),
                      new Text(
                        snapshot.value['emailId'], style: _textStyle(),),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        new Divider(color: Colors.deepPurple[200],),
      ],
    );
  }

  _textStyle() {
    new TextStyle(color: Colors.deepOrange, fontSize: 16.0);
  }

  onItemClick(int index, BuildContext context) {
    if (user.userId == snapshot.value['userId']) {
      return;
    }
    ChatBean bean = new ChatBean(
        snapshot.value['name'], snapshot.value['userId'], user.name,
        user.userId);
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (c) {
          return new ChatPage(bean);
        })
    );
  }
}