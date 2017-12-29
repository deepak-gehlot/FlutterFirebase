import 'package:flutter/material.dart';
import 'package:flutter_firebase/bean/User.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase/util/Constant.dart';

class EditProfilePage extends StatefulWidget {

  final User user;

  EditProfilePage(this.user);

  @override
  State createState() {
    return new EditProfilePageState();
  }
}

class EditProfilePageState extends State<EditProfilePage> {

  File imageFile;
  bool isShowImage = false;
  bool isShowLoader = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Edit Profile"),
      ),
      body: new Container(
        child: new Column(
          children: <Widget>[
            new GestureDetector(
              onTap: getImage,
              child: new Align(
                alignment: Alignment.topCenter,
                child: new Stack(
                  children: <Widget>[
                    new Container(
                      margin: const EdgeInsets.all(16.0),
                      height: 150.0,
                      width: 150.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          border: new Border.all(
                              color: Colors.deepOrange,
                              width: 1.0
                          )
                      ),
                      child: isShowImage
                          ? _showImageFromFile()
                          : _showImageFromUrl(),
                    ),
                    new Positioned(
                        right: 0.5,
                        left: 0.5,
                        top: 0.5,
                        bottom: 0.5,
                        child: new Opacity(
                            opacity: 0.4,
                          child: new Container(
                            margin: const EdgeInsets.all(16.0),
                            height: 150.0,
                            width: 150.0,
                            decoration: new BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                                border: new Border.all(
                                    color: Colors.deepOrange,
                                    width: 1.0
                                )
                            ),
                            child: new IconButton(
                                padding: const EdgeInsets.all(46.0),
                                icon: new Icon(Icons.camera_alt,color: Colors.white,), onPressed: null),
                          ),
                        ))
                  ],
                ),
              ),
            ),
            new Align(
              alignment: Alignment.topCenter,
              child: new Text(widget.user.name, style: new TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),),
            ),
            new Align(
              alignment: Alignment.topCenter,
              child: new Text(widget.user.email,
                style: new TextStyle(color: Colors.black, fontSize: 16.0),),
            ),
            new Divider(color: Colors.deepOrange,),
          ],
        ),
      ),
    );
  }

  getImage() async {
    File _fileName = await ImagePicker.pickImage();
    imageFile = _fileName;

    setState(() {
      isShowImage = true;
    });

    widget.user.profilePic = await _postImage();

    await FirebaseDatabase.instance.reference()
        .child(Constant.TABLE_USER).child(widget.user.userId).set({
      'emailId': widget.user.email,
      'name': widget.user.name,
      'userId': widget.user.userId,
      'userImage': widget.user.profilePic
    });
  }

  _showImageFromFile() {
    return new Container(
      height: 200.0, width: 200.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        image: new DecorationImage(
          image: new FileImage(imageFile),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  _showImageFromUrl() {
    return new Container(
      height: 200.0, width: 200.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        image: new DecorationImage(
          image: new NetworkImage(widget.user.profilePic),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<String> _postImage() async {
    String fileName = basename(imageFile.path);
    final StorageReference ref = FirebaseStorage.instance.ref().child(
        '$fileName');
    final StorageUploadTask uploadTask = ref.put(imageFile);
    return (await uploadTask.future).downloadUrl.toString();
  }

}