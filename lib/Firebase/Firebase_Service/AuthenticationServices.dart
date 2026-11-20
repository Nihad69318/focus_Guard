
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  // Google Sign-In
  Future<User?> googleWithSignin() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: '96623975228-o5d0v0h0809nd6at65g9s1406uv93opj.apps.googleusercontent.com',
      );

      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

      // Google Authentication
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      // Firebase Credential
      final AuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Firebase Login
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          print("New User: ${user.displayName}");
          print("Email: ${user.email}");
        } else {
          print("Existing User: ${user.displayName}");
        }
      }

      return user;
    } catch (e, stackTrace) {
      print("GOOGLE LOGIN ERROR: $e");
      print(stackTrace);
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }


}

