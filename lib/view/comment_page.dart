import 'package:flutter/material.dart';
import 'package:flutter_firebase/bean/PostItem.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase/util/Constant.dart';
import 'package:flutter_firebase/bean/CommentItem.dart';

class CommentPage extends StatefulWidget {

  final PostItem postItem;

  CommentPage(this.postItem);

  @override
  State createState() {
    return new CommentPageState();
  }
}

class CommentPageState extends State<CommentPage> {

  final TextEditingController _textController = new TextEditingController();
  bool loadList = false;
  List<CommentItem> commentItemList = new List();

  @override
  initState() {
    super.initState();
    _getFilterData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Comments"),),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Flexible(
                child: loadList ? _messagesList() : new Center(
                  child: new Text("Be first to commet.", style: _textStyle(),),)
            ),
            new Divider(height: 1.0, color: Colors.deepPurple,),
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
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _buildListRow(index);
      },
      itemCount: commentItemList.length,
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
                        commentItemList[index].userImage)),
                new Expanded(child: new Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        commentItemList[index].userName, style: _textStyle(),),
                    ],
                  ),
                ),
                ),
                new Container(child: new Text(
                  commentItemList[index].dateTime,
                  style: _textStyle(),),
                )
              ],
            ),
          ),
          new Align(
            alignment: Alignment.topLeft,
            child: new Padding(padding: const EdgeInsets.only(
                top: 8.0, bottom: 12.0, left: 16.0, right: 16.0),
              child: new Text(commentItemList[index].comment,
                style: _textStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _textStyle() {
    new TextStyle(color: Colors.deepPurple, fontSize: 16.0);
  }

  _getFilterData() {
    final DatabaseReference _counterRef = FirebaseDatabase.instance.reference();
    final DatabaseReference _userRef = FirebaseDatabase.instance.reference()
        .child(Constant.TABLE_USER);

    _counterRef
        .child(Constant.TABLE_COMMENT)
        .child(widget.postItem.key)
        .onChildAdded
        .listen((Event event) {
      try {
        _userRef.child(event.snapshot.key).once().then((DataSnapshot dataSpan) {
          event.snapshot.value.forEach((key, value) {
            try {
              var dateTime = new DateTime.fromMillisecondsSinceEpoch(
                  value['timestamp']);
              String dateTimeString = dateTime.day.toString() + "-" +
                  dateTime.month.toString() + "-" + dateTime.year.toString() +
                  " " + dateTime.hour.toString() + ":" +
                  dateTime.minute.toString();
              CommentItem item = new CommentItem(
                dateTimeString,
                value['comment'],
                dataSpan.value['name'],
                dataSpan.value['userImage'],
              );
              commentItemList.add(item);
            } catch (e) {
              print(e);
            }
          });
          setState(() {
            loadList = true;
          });
        }).catchError((e) {
          print(e);
        });
      } catch (e) {
        print(e);
      }
    });
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
                    hintText: "Enter your comment..."),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send, color: Colors.deepPurple,),
                  onPressed: () => _handleSubmitted(_textController.text)),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmitted(String text) async {
    if (text.isNotEmpty) {
      /*if (!loadList) {
        setState(() {
          loadList = true;
        });
      }*/
      _textController.clear();
      final DatabaseReference _counterRef = FirebaseDatabase.instance
          .reference()
          .child(Constant.TABLE_COMMENT).child(widget.postItem.key).child(
          widget.postItem.userId).push();
      await _counterRef.set({
        'comment': text,
        'timestamp': new DateTime.now().millisecondsSinceEpoch,
      });

      widget.postItem.commentCount = widget.postItem.commentCount + 1;

      await FirebaseDatabase.instance.reference()
          .child(Constant.TABLE_POST)
          .child(widget.postItem.key).set({
        'userId': widget.postItem.userId,
        'postImage': widget.postItem.postImage,
        'description': widget.postItem.description,
        'timestamp': widget.postItem.timestamp,
        'likeCount': widget.postItem.likeCount,
        'shareCount': widget.postItem.shareCount,
        'commentCount': widget.postItem.commentCount
      }
      );
    }
  }
}