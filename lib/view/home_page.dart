import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase/util/Constant.dart';
import 'package:flutter_firebase/bean/User.dart';
import 'package:flutter_firebase/view/post_page.dart';
import 'package:flutter_firebase/view/users_list_page.dart';
import 'package:flutter_firebase/view/edit_profile_page.dart';
import 'package:flutter_firebase/bean/PostItem.dart';
import 'package:share/share.dart';
import 'package:flutter_firebase/vertical_divider.dart';
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
  String url = "";
  bool isLoading = true;
  List<PostItem> itemsList = new List();

  @override
  initState() {
    super.initState();
    _getFilterData();
  }

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
              icon: new Icon(Icons.add, color: Colors.white,),
              onPressed: () {
                switchToPost(context);
              }),
          new IconButton(icon: new Icon(Icons.list, color: Colors.white,),
              onPressed: () {
                switchToUsers(context);
              })
        ],
      ),
      body: new Container(
        color: Colors.white,
        child: itemsList.length != 0 ? _getDataFromDatabase() : new Container(),
      ),
      floatingActionButton: new FloatingActionButton(
        elevation: 10.0,
        highlightElevation: 20.0,
        onPressed: () {
          switchToPost(context);
        },
        child: new Icon(Icons.add),),
    );
  }

//  sort: (a, b) => b.key.compareTo(a.key),
  _getDataFromDatabase() {
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _buildListRow(index);
      },
      itemCount: itemsList.length,
    );
  }

  _getFilterData() {
    final DatabaseReference _counterRef = FirebaseDatabase.instance.reference();
    final DatabaseReference _userRef = FirebaseDatabase.instance.reference()
        .child(Constant.TABLE_USER);

    _counterRef
        .child(Constant.TABLE_POST)
        .onChildAdded
        .listen((Event event) {
      try {
        _userRef.child(event.snapshot.key).once().then((DataSnapshot dataSpan) {
          event.snapshot.value.forEach((key, value) {
            try {
              PostItem item = new PostItem(
                  key,
                  value['description'],
                  value['postImage'],
                  value['timestamp'],
                  dataSpan.value['emailId'],
                  value['userId'],
                  dataSpan.value['userImage'],
                  dataSpan.value['name']);
              itemsList.add(item);
            } catch (e) {
              print(e);
            }
          });

          setState(() {
            itemsList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          });
        }).catchError((e) {
          print(e);
        });
      } catch (e) {
        print(e);
      }
    });
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

  _buildListRow(int index) {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Padding(padding: const EdgeInsets.all(5.0),
            child: new Row(
              children: <Widget>[
                new CircleAvatar(
                    backgroundImage: new NetworkImage(
                        itemsList[index].userImage)),
                new Expanded(child: new Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        itemsList[index].userName, style: _textStyle(),),
                      new Text(
                        itemsList[index].userEmail, style: _textStyle(),),
                    ],
                  ),
                )
                ),
                itemsList[index].userId == widget.user.userId
                    ?
                new IconButton(
                    icon: new Icon(Icons.more_vert), onPressed: () {
                  _deleteConfirmationDialog(itemsList[index].key, index);
                }) : new Container()
              ],
            ),
          ),
          new Align(
            alignment: Alignment.topLeft,
            child: new Padding(padding: const EdgeInsets.only(
                top: 8.0, bottom: 12.0, left: 16.0, right: 16.0),
              child: new Text(itemsList[index].description,
                style: _textStyle(),
              ),
            ),
          ),
          new Container(height: 8.0,),
          new Center(
            child: new Image.network(itemsList[index].postImage,
              fit: BoxFit.fitWidth,
            ),
          ),
          new Container(
            child: _bottomView(),
          ),
          new Divider(height: 2.0, color: Colors.deepPurple,)
        ],
      ),
    );
  }

  _deleteConfirmationDialog(String postItemId, int index) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      child: new AlertDialog(
        title: new Text('Alert !'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text('Do you want to delete this post?'),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          new FlatButton(
            child: new Text('Yes'),
            onPressed: () {
              _deleteItem(postItemId, index);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  _deleteItem(String postItemId, int index) {
    final DatabaseReference _counterRef = FirebaseDatabase.instance.reference();
    _counterRef.child(Constant.TABLE_POST).child(widget.user.userId)
        .child(postItemId)
        .remove();
    itemsList.removeAt(index);
    setState(() {});
  }

  _textStyle() {
    new TextStyle(color: Colors.deepPurple, fontSize: 16.0);
  }

  Widget _bottomView() {
    Widget widget;
    widget = new Row(
      children: <Widget>[
        new Expanded(child: new IconButton(
            icon: new Icon(Icons.thumb_up, color: Colors.deepPurple,),
            onPressed: null),),
        new VerticalDivider(height: 30.0, color: Colors.deepPurple,),
        new Expanded(child: new IconButton(
            icon: new Icon(Icons.comment, color: Colors.deepPurple,),
            onPressed: null),),
        new VerticalDivider(height: 30.0, color: Colors.deepPurple,),
        new Expanded(child: new IconButton(
            icon: new Icon(Icons.share, color: Colors.deepPurple,),
            onPressed: () {
              _onShareButtonClick("tesa", "test");
            }),
        )
      ],
    );
//  new Expanded(child: new Icon(Icons.comment)),
//    new Expanded(child: new Icon(Icons.share))
    return widget;
  }


  _onShareButtonClick(String text, String imageUrl) {
    share(text + "\n\n" + imageUrl);
  }
}