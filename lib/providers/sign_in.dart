import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String uid;
  final String email;
  final String displayName;

  const User({@required this.uid, @required this.email, @required this.displayName});
}

class Auth with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User _currentUser;

  Future<String> signInWithGoogle() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    _currentUser = User(uid: user.uid, email: user.email, displayName: user.displayName);
    _prefs.setString('email', _currentUser.email);
    _prefs.setString('id', _currentUser.uid);
    _prefs.setString('displayName', _currentUser.displayName);


    notifyListeners();
    DocumentSnapshot data = await Firestore.instance
        .collection('Users')
        .document(_currentUser.email.toString())
        .get();
    if (data == null || !data.exists)
      await Firestore.instance
          .collection('Users')
          .document(_currentUser.email.toString())
          .setData({
        'id': _currentUser.uid.toString(),
        'username': _currentUser.displayName,
        'email': _currentUser.email,
        'isAdmin': false,
      });
    return 'signInWithGoogle succeeded: $user';
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    await _auth.signOut();
    print("User Sign Out");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('id');
    prefs.remove('displayName');
    _currentUser = null;
    notifyListeners();
  }

  Future<void> autoLogin() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var uid = _prefs.getString('id');
    var email = _prefs.getString('email');
    var displayName = _prefs.getString('displayName');
    if(uid != null) {
      _currentUser = User(uid: uid, email: email, displayName: displayName);
    }
    notifyListeners();
  }

  User get curUser {
    return _currentUser;
  }
}
