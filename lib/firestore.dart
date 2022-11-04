import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

typedef void serviceCallback(List<dynamic> data);

class FirebaseService {
  bool readyToWrite = false;

  DocumentReference? userDoc;
  CollectionReference? sleepCol;
  CollectionReference? nutritionCol;
  CollectionReference? hydrationCol;
  CollectionReference? workoutCol;

  final CollectionReference userReference = FirebaseFirestore.instance.collection('users');
  final CollectionReference foodReference = FirebaseFirestore.instance.collection('foods');

  void initService() {
    if(FirebaseAuth.instance.currentUser == null) {
      print('Attempted to init firebaseservice without being logged in');
      assert(false);
    }
    userReference!.where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get().then(
      (value) {
        if(value.size == 0) {
          print('We ball');
          initUser();
        } else {
          userDoc = value.docs.first.reference;
          sleepCol = userDoc!.collection('sleep');
          nutritionCol = userDoc!.collection('nutrition');
          hydrationCol = userDoc!.collection('hydration');
          workoutCol = userDoc!.collection('workout');
          readyToWrite = true;
        }
      },
      onError: (e) => print(e.toString())
    );
  }

  void clearService() {
    readyToWrite = false;
    userDoc = null;
    sleepCol = null;
    nutritionCol = null;
    hydrationCol = null;
    workoutCol = null;
  }

  void initUser() {
    if(FirebaseAuth.instance.currentUser != null) {
      final newUserEntry = <String, dynamic> {
        'height': -1,
        'name': '',
        'uid': FirebaseAuth.instance.currentUser!.uid.toString(),
        'email': FirebaseAuth.instance.currentUser!.email,
        'weight': -1,
      };
      userReference.add(newUserEntry).then((newUserDoc) {
        userDoc = newUserDoc;
        initService();
      });
    }
  }

  void addSleep(List<dynamic> data) async {

    while(!readyToWrite) { print('trying to write while '); }
    sleepCol ??= userDoc!.collection('sleep');
    final newEntry = <String, dynamic>{
      "hours": data[0],
      "time_logged": Timestamp.now(),
      "sleep_quality": data[1],
      "notes":data[2]
    };
    await sleepCol!.add(newEntry).then((documentSnapshot) => print("Added Sleep Data with ID: ${documentSnapshot.id}"));
  }

  void addHydration(List<dynamic> data) async {
    while(!readyToWrite) { print('trying to write while '); }
    hydrationCol ??= userDoc!.collection('hydration');
    final newEntry = <String, dynamic>{
      "amount": data[0],
      "time_logged": Timestamp.now(),
    };
    await hydrationCol!.add(newEntry).then((documentSnapshot) => print("Added Hydration Data with ID: ${documentSnapshot.id}"));
  }

  void addNutrition(List<dynamic> data) async {
    while(!readyToWrite) { print('trying to write while '); }
    nutritionCol ??= userDoc!.collection('nutrition');
    final newEntry = <String, dynamic>{
      "food_name": data[0],
      "time_logged": Timestamp.now(),
      "total_calories": data[1],
      "total_carbs":data[2],
      "total_fats":data[3],
      "total_protein":data[4]
    };
    await nutritionCol!.add(newEntry).then((documentSnapshot) => print("Added Nutrition Data with ID: ${documentSnapshot.id}"));
  }

}