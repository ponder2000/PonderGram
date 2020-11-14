import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pondergram/models/user.dart';
import 'package:pondergram/pages/home.dart';
import 'package:pondergram/pages/profile.dart';
import 'package:pondergram/widgets/loading.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> seaechResultsFuture;

  // searching according to username
  handleSearch(String val) {
    Future<QuerySnapshot> users =
        usersRef.where("username", isGreaterThanOrEqualTo: val).get();
    setState(() {
      this.seaechResultsFuture = users;
    });
  }

  clearedSearch() {
    setState(() {
      seaechResultsFuture = null;
    });
    searchController.clear();
  }

  buildNoContent() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SvgPicture.asset(
              'assets/images/fishing.svg',
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.w800,
              ),
            )
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
        future: seaechResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchResults = [];
          snapshot.data.docs.forEach((doc) {
            User user = User.fromDocument(doc);
            UserResult userResult = UserResult(user);
            searchResults.add(userResult);
          });
          return ListView(
            children: searchResults,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextFormField(
          controller: searchController,
          onFieldSubmitted: handleSearch,
          decoration: InputDecoration(
            hintText: "Search for a User",
            prefixIcon: Icon(Icons.account_box),
            suffixIcon: IconButton(
              onPressed: clearedSearch,
              icon: Icon(Icons.clear),
            ),
          ),
        ),
      ),
      body:
          seaechResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);

  //show a full profile page
  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          profileId: profileId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  // color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(user.username),
            ),
          ),
          Divider(
            height: 5.0,
            color: Colors.black,
          )
        ],
      ),
    );
  }
}
