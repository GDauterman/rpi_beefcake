import 'package:firebase_auth/firebase_auth.dart';

class FireAuth {
  static void loginWithEP(List<dynamic> l) {
    FirebaseAuth.instance.signInWithEmailAndPassword(email: l[0], password: l[1]);
  }

  static void registerWithEP(List<dynamic> l) {
    print('we ball with ' + l[0]);
    FirebaseAuth.instance.createUserWithEmailAndPassword(email: l[0], password: l[1]);
  }

}
