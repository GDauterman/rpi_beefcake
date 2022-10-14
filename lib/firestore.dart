import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final CollectionReference userReference = FirebaseFirestore.instance.collection('users');
final CollectionReference foodReference = FirebaseFirestore.instance.collection('foods');

class FirebaseService {
  final String userID;
  late DocumentReference userDoc;
  CollectionReference? sleepCol;
  CollectionReference? nutritionCol;
  CollectionReference? hydrationCol;
  CollectionReference? workoutCol;
  
  FirebaseService(this.userID) {
    userReference.where("userid", isEqualTo: userID)
      .get().then((value) => userDoc = value.docs.first.reference,
        onError: (e) => print(e.toString()));
  }

  void addSleep(List<dynamic> data) async {
    sleepCol ??= userDoc.collection('sleep');
    final newEntry = <String, dynamic>{
      "hours": data[0],
      "time_logged": Timestamp.now(),
      "sleep_quality": data[1],
      "notes":data[3]
    };
    await sleepCol!.add(newEntry).then((documentSnapshot) => print("Added Sleep Data with ID: ${documentSnapshot.id}"));
  }
}