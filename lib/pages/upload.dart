import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pondergram/models/user.dart';
import 'package:pondergram/pages/home.dart';
import 'package:pondergram/widgets/loading.dart';
import 'package:pondergram/widgets/reusable_header.dart';
import 'package:uuid/uuid.dart';

class UploadPage extends StatefulWidget {
  final User currentUser;
  UploadPage({this.currentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final picker = ImagePicker(); // imagePicker object to read image file
  File file;
  bool isUploading = false; // a variable to determine the uploading state
  String postId = Uuid().v4(); // randomly generated string for PostId
  TextEditingController captionController =
      TextEditingController(); // control caption field
  TextEditingController locationController =
      TextEditingController(); // control location field

  // helper function to capture and read a photo from Camera
  handleTakePhoto(BuildContext context) async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = File(pickedFile.path);
    });
  }

  // helper function to read a photo from Gallery
  handlePhotoFromGallery(BuildContext context) async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = File(pickedFile.path);
    });
  }

  // dropdown menu for image source
  selectImage(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: [
              SimpleDialogOption(
                child: Text("Image with Camera"),
                onPressed: () => handleTakePhoto(context),
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: () => handlePhotoFromGallery(context),
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  // Upload Screen UI
  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            // child: SvgPicture.asset('assets/images/picture.svg'),
            child: Image.asset('assets/images/camera.png'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: RaisedButton(
              color: Theme.of(context).accentColor,
              onPressed: () => selectImage(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Upload Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // if no image is selected after the popup then return to upload page
  clearImage() {
    setState(() {
      this.file = null;
    });
  }

  // helper function to upload the post into firestore and return a downloadable link
  Future<String> uploadImage(File imageFile) async {
    UploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap =
        await uploadTask; // returns data of uploaded file
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  // helper function to add userPost in Post collection of firebase
  createPostInFirestore({String mediaUrl, String location, String caption}) {
    postsRef
        .doc(widget.currentUser.id)
        .collection('userPosts')
        .doc(postId)
        .set({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });
  }

  // uploads image to firebase_firestore and update the Posts collection
  postImage() async {
    setState(() {
      isUploading = true;
    });
    String mediaUrl = await uploadImage(file);
    print(mediaUrl);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      caption: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  // create Post UI
  buildUploadPostScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : Text(""),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 7.0,
                      color: Theme.of(context).accentColor,
                    )
                  ],
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Theme.of(context).accentColor,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Add Location",
                  border: InputBorder.none,
                  focusColor: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              padding: EdgeInsets.all(15.0),
              onPressed: isUploading ? () {} : () => postImage(),
              icon: Icon(
                Icons.post_add,
                color:
                    isUploading ? Theme.of(context).accentColor : Colors.white,
              ),
              label: Text(
                isUploading ? "Uploading..." : "Upload Post",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Theme.of(context).accentColor,
              elevation: 10.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: false, title: "CREATE POST"),
      body: file == null ? buildSplashScreen() : buildUploadPostScreen(),
    );
  }
}
