import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

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
      "hours": double.parse(data[0]) as num,
      "time_logged": Timestamp.now(),
      "sleep_quality": double.parse(data[1]) as num,
      "notes":data[2]
    };
    await sleepCol!.add(newEntry).then((documentSnapshot) => print("Added Sleep Data with ID: ${documentSnapshot.id}"));
  }

  void addHydration(List<dynamic> data) async {
    while(!readyToWrite) { print('trying to write while '); }
    hydrationCol ??= userDoc!.collection('hydration');
    final newEntry = <String, dynamic>{
      "amount": double.parse(data[0]) as num,
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
      "total_calories": double.parse(data[1]) as num,
      "total_carbs": double.parse(data[2]) as num,
      "total_fats": double.parse(data[3]) as num,
      "total_protein": double.parse(data[4]) as num
    };
    await nutritionCol!.add(newEntry).then((documentSnapshot) => print("Added Nutrition Data with ID: ${documentSnapshot.id}"));
  }

  void getTodayNutrition(String field, ValueSetter<num> whenGet) async {
    while(!readyToWrite) { print('trying to read while '); }
    nutritionCol ??= userDoc!.collection('nutrition');
    return nutritionCol!.where("time_logged", isNotEqualTo: DateTime.now()).get().then((value) {
      num sum = 0;
      for(int i = 0; i < value.docs.length; i++) {
        if(value.docs[i] is String) {
          sum += double.parse(value.docs[i].get(field));
        } else if(value.docs[i].get(field) is num || value.docs[i].get(field) is int || value.docs[i].get(field) is double) {
          sum += value.docs[i].get(field);
        } else {
          print(value.docs[i].get(field));
        }
      }
      whenGet(sum);
    });
  }

  void getTodaySleep(String field, ValueSetter<num> whenGet) async {
    while(!readyToWrite) { print('trying to read while '); }
    sleepCol ??= userDoc!.collection('sleep');
    return sleepCol!.where("time_logged", isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days:2))).get().then((value) {
      num sum = 0;
      for(int i = 0; i < value.docs.length; i++) {
        if(value.docs[i] is String) {
          sum += double.parse(value.docs[i].get(field));
        } else if(value.docs[i].get(field) is num || value.docs[i].get(field) is int || value.docs[i].get(field) is double) {
          sum += value.docs[i].get(field);
        } else {
          print(value.docs[i].get(field));
        }
      }
      whenGet(sum);
    });
  }

  void getTodayHydration(String field, ValueSetter<num> whenGet) async {
    while(!readyToWrite) { print('trying to read while '); }
    hydrationCol ??= userDoc!.collection('hydration');
    return hydrationCol!.where("time_logged", isGreaterThanOrEqualTo: DateTime.now().subtract(const Duration(days:2))).get().then((value) {
      num sum = 0;
      for(int i = 0; i < value.docs.length; i++) {
        if(value.docs[i] is String) {
          sum += double.parse(value.docs[i].get(field));
        } else if(value.docs[i].get(field) is num || value.docs[i].get(field) is int || value.docs[i].get(field) is double) {
          sum += value.docs[i].get(field);
        } else {
          print(value.docs[i].get(field));
        }
      }
      whenGet(sum);
    });
  }
}