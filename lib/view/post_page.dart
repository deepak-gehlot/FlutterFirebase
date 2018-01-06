import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase/bean/User.dart';
import 'package:flutter_firebase/util/Constant.dart';

class PostPage extends StatefulWidget {

  final User user;

  PostPage(this.user);

  @override
  State createState() {
    return new PostPageState();
  }
}

class PostPageState extends State<PostPage> {
  final TextEditingController _postText = new TextEditingController();
  File imageFile;
  bool isShowImage = false;
  bool isShowLoader = false;
  String imageUrl;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Share"),
      ),
      body: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        child: new ListView(
          children: <Widget>[
            new GestureDetector(
              onTap: getImage,
              child: new Align(
                alignment: Alignment.topCenter,
                child: new Container(
                  margin: const EdgeInsets.all(16.0),
                  height: 150.0,
                  width: 150.0,
                  decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.all(
                          const Radius.circular(4.0)),
                      border: new Border.all(
                          color: Colors.deepPurple,
                          width: 1.0
                      )
                  ),
                  child: isShowImage
                      ? _showImage()
                      : new Icon(Icons.add_a_photo),
                ),
              ),
            ),
            new Container(margin: const EdgeInsets.only(top: 26.0),),
            _buildInputField(context, "Enter text", _postText),
            new Container(margin: const EdgeInsets.only(top: 26.0),),
            new Container(
                child: isShowLoader ? _loader() : _shareButton(context)
            )
            ,
          ],
        ),
      )
      ,
    );
  }

  Widget _buildInputField(BuildContext context, String hint,
      TextEditingController controller) {
    return new Container(
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(const Radius.circular(4.0)),
            border: new Border.all(color: Colors.grey)
        ),
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.only(top: 16.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Flexible(
                child: new Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: new TextField(
                    controller: controller,
                    style: new TextStyle(fontSize: 16.0, color: Colors.red),
                    decoration: new InputDecoration.collapsed(hintText: hint),
                    obscureText: false,
                    maxLines: 5,
                    maxLength: 200,
                  ),)),
          ],
        )
    );
  }

  getImage() async {
    File _fileName = await ImagePicker.pickImage();
    imageFile = _fileName;
    setState(() {
      isShowImage = true;
    });
  }

  _showImage() {
    return new Container(
      height: 200.0, width: 200.0,
      decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new FileImage(imageFile),
            fit: BoxFit.cover,
          ),
          borderRadius: new BorderRadius.all(
              const Radius.circular(4.0))
      ),
    );
  }

  _shareButton(BuildContext context) {
    return new Align(
      alignment: Alignment.topCenter,
      child: new RaisedButton(
        onPressed: () {
          _sharePost(context);
        },
        child: new Text(
          'SHARE',
          style: new TextStyle(color: Colors.deepPurple))),
    );
  }

  _loader() {
    return new Align(
      alignment: Alignment.topCenter,
      child: new CircularProgressIndicator(),
    );
  }


  Future<String> _postImage() async {
    String fileName = basename(imageFile.path);
    final StorageReference ref = FirebaseStorage.instance.ref().child(
        '$fileName');
    final StorageUploadTask uploadTask = ref.put(imageFile);
    return (await uploadTask.future).downloadUrl.toString();
  }

  _sharePost(BuildContext context) async {
    setState(() {
      isShowLoader = true;
    });
    String url = await _postImage();
    final DatabaseReference _counterRef = FirebaseDatabase.instance.reference()
        .child(Constant.TABLE_POST);
    await _counterRef.child(widget.user.userId).push().set({
      'userId': widget.user.userId,
      'postImage': url,
      'description': _postText.text,
      'timestamp': new DateTime.now().millisecondsSinceEpoch,
    });
    setState(() {
      isShowLoader = false;
    });
    Navigator.of(context).pop();
  }
}
