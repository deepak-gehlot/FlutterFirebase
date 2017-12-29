import 'package:flutter/material.dart';
import 'package:flutter_firebase/bean/ChatBean.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase/util/Constant.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/animation.dart';

class ChatPage extends StatefulWidget {

  final ChatBean bean;

  ChatPage(this.bean);

  @override
  State createState() {
    return new ChatPageState();
  }
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = new TextEditingController();
  String threadKey = "";
  int msgThreadCheckTag = 0;
  bool loadList = false;

  @override
  initState() {
    super.initState();
    threadKey = widget.bean.loginUserId + '_' + widget.bean.friendId;
    _getAllMessage();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.bean.friendName),
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Flexible(
                child: loadList ? _messagesList() : new Container()
            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(
                  color: Theme
                      .of(context)
                      .cardColor),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }

  _messagesList() {
    final DatabaseReference _counterRef = FirebaseDatabase.instance.reference()
        .child(Constant.TABLE_MESSAGE).child(threadKey);
    return new FirebaseAnimatedList(
      query: _counterRef,
      sort: (a, b) => b.key.compareTo(a.key),
      reverse: true,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation,
          int index) {
        return new ChatRow(snapshot, animation, index);
      },
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme
          .of(context)
          .accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(
                    hintText: "Send a message"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text)),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmitted(String text) async {
    if (text.isNotEmpty) {
      if (!loadList) {
        setState(() {
          loadList = true;
        });
      }
      _textController.clear();
      final DatabaseReference _counterRef = FirebaseDatabase.instance
          .reference()
          .child(Constant.TABLE_MESSAGE);
      await _counterRef.child(
          threadKey).push().set({
        'message': text,
        'userName': widget.bean.loginUserName,
        'userId': widget.bean.loginUserId,
      });
    }
  }

  _getAllMessage() async {
    try {
      final DatabaseReference _counterRef = FirebaseDatabase.instance
          .reference()
          .child(Constant.TABLE_MESSAGE);
      DataSnapshot snapshot = await _counterRef.orderByKey().equalTo(
          threadKey)
          .once();
      if (snapshot.value != null) { // key exist
        setState(() {
          loadList = true;
        });
      } else { // key not exist
        if (msgThreadCheckTag != 1) {
          threadKey = widget.bean.friendId + '_' + widget.bean.loginUserId;
          msgThreadCheckTag = 1;
          _getAllMessage();
        }
      }
    } catch (e) {
      print(e);
    }
  }
}

class ChatRow extends StatelessWidget {
  final DataSnapshot snapshot;
  final Animation<double> animation;
  final int index;

  ChatRow(this.snapshot, this.animation, this.index);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new Row(
            children: <Widget>[
              new CircleAvatar(
                child: new Text(snapshot.value['userName'][0]),
              ),
              new Expanded(child: new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Text(snapshot.value['message']),))
            ],
          ),
        ),
        new Divider(),
      ],
    );
  }
}