import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  User? get currentUser  => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  static String? gid;
  static String? gEmail;

  GoogleSignIn _googleSignIn = GoogleSignIn();
   static GoogleSignInAccount? gUser;
  signInWithGoogle() async {
     gUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication gAuth  = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken
    );
    gid = gUser!.id;
    gEmail = gUser!.email;

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential?> signInWithFacebook() async {
    try{

      // Trigger the sign-in flow
      final LoginResult loginResult = await _facebookAuth.login( permissions: ["email"]);

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

      // Once signed in, return the UserCredential
      return _firebaseAuth.signInWithCredential(facebookAuthCredential);
    }  catch (e){
      print(e);
    }

  }

  Future<void> signOutGoogle()async{
    await _firebaseAuth.signOut();
    await _facebookAuth.logOut();

    // await _googleSignIn!.signOut();
  }
}
//For Generating sha1 key
// keytool -list -v -alias androiddebugkey -keystore C:/Users/Devesh/.android/debug.keystore