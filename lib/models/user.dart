import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id, username, email, photoUrl, displayName, bio;
  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.data()['id'],
      email: doc.data()['email'],
      photoUrl: doc.data()['photoUrl'],
      displayName: doc.data()['displayName'],
      bio: doc.data()['bio'],
      username: doc.data()['username'],
    );
  }
}
