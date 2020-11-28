import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pondergram/constants.dart';
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

  buildAllUser() {
    return FutureBuilder(
      future: usersRef.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress();
        List<GridTile> _userBoxs = [];
        snapshot.data.docs.forEach((d) {
          User _user = User.fromDocument(d);
          UserBox _ub = UserBox(_user);
          _userBoxs.add(GridTile(child: _ub));
        });
        return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: _userBoxs,
        );
      },
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: seaechResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress();
        List<GridTile> _userBoxs = [];
        snapshot.data.docs.forEach((d) {
          User _user = User.fromDocument(d);
          UserBox _ub = UserBox(_user);
          _userBoxs.add(GridTile(child: _ub));
        });
        return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: _userBoxs,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Theme.of(context).primaryColor,
          title: TextFormField(
            controller: searchController,
            onFieldSubmitted: handleSearch,
            decoration: InputDecoration(
              hintText: "Search for a User",
              prefixIcon: Icon(
                Icons.supervised_user_circle,
                color: Theme.of(context).accentColor,
                size: 35.0,
              ),
              suffixIcon: IconButton(
                onPressed: clearedSearch,
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
        ),
        body:
            seaechResultsFuture == null ? buildAllUser() : buildSearchResults(),
      ),
    );
  }
}

class UserBox extends StatelessWidget {
  final User _user;
  UserBox(this._user);

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
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: () => showProfile(context, profileId: _user.id),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 10.0)],
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: [
              CachedNetworkImage(
                imageUrl: _user.photoUrl,
                imageBuilder: (context, imageProvider) => Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Container(height: 10.0),
              Text(
                _user.username,
                style: kBoldText,
              ),
              Text(
                _user.displayName,
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
