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
      id: doc['id'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      username: doc['username'],
    );
  }
}
