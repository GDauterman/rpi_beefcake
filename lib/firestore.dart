import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';

typedef void ServiceCallback(List<dynamic> data);

enum DBFields { nameN, caloriesN, fatN, carbsN, proteinN, durationS, qualityS, noteS, quantityH }

class FirebaseService {

  bool connected = false;

  DocumentReference? userDoc;
  CollectionReference? sleepCol;
  CollectionReference? nutritionCol;
  CollectionReference? hydrationCol;
  CollectionReference? workoutCol;

  final CollectionReference userReference = FirebaseFirestore.instance.collection('users');
  final CollectionReference foodReference = FirebaseFirestore.instance.collection('foods');

  final Map<DBFields, String> dbFieldMap = {
    DBFields.nameN: 'food_name',
    DBFields.caloriesN: 'total_calories',
    DBFields.carbsN: 'total_carbs',
    DBFields.fatN: 'total_fat',
    DBFields.proteinN: 'total_protein',
    DBFields.durationS: 'hours',
    DBFields.qualityS: 'sleep_quality',
    DBFields.noteS: 'notes',
    DBFields.quantityH: 'amount',
  };

  final Map<DBFields, String> dbGoalMap = {
    DBFields.caloriesN: 'calorie_goal',
    DBFields.carbsN: 'carb_goal',
    DBFields.fatN: 'fat_goal',
    DBFields.proteinN: 'protein_goal',
    DBFields.durationS: 'sleep_goal',
    DBFields.quantityH: 'hydration_goal',
  };

  Map<DBFields, CollectionReference?> dbColMap = {
    DBFields.nameN: null,
    DBFields.caloriesN: null,
    DBFields.carbsN: null,
    DBFields.fatN: null,
    DBFields.proteinN: null,
    DBFields.durationS: null,
    DBFields.qualityS: null,
    DBFields.noteS: null,
    DBFields.quantityH: null,
  };

  final Map<DBFields, String> dbUnitMap = {
    DBFields.nameN: '',
    DBFields.caloriesN: '',
    DBFields.carbsN: 'grams',
    DBFields.fatN: 'grams',
    DBFields.proteinN: 'grams',
    DBFields.durationS: 'hours',
    DBFields.qualityS: '0-100',
    DBFields.noteS: '',
    DBFields.quantityH: 'oz',
  };

  final Map<DBFields, String> dbTitleMap = {
    DBFields.nameN: 'Food Name',
    DBFields.caloriesN: 'Calories',
    DBFields.carbsN: 'Carb',
    DBFields.fatN: 'Fats',
    DBFields.proteinN: 'Protein',
    DBFields.durationS: 'Hours Slept',
    DBFields.qualityS: 'Sleep Quality',
    DBFields.quantityH: 'Water Consumed',
  };

  // makes firebase service a global singleton
  static final FirebaseService _db = FirebaseService._internal();
  factory FirebaseService() {
    return _db;
  }
  FirebaseService._internal();

  void initService() {
    if(FirebaseAuth.instance.currentUser == null) {
      print('Attempted to init firebaseservice without being logged in');
      assert(false);
    }
    userReference!.where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get().then(
      (value) {
        if(value.size == 0) {
          initUser();
        } else {
          userDoc = value.docs.first.reference;
          sleepCol = userDoc!.collection('sleep');
          nutritionCol = userDoc!.collection('nutrition');
          hydrationCol = userDoc!.collection('hydration');
          workoutCol = userDoc!.collection('workout');
          dbColMap[DBFields.nameN] = nutritionCol;
          dbColMap[DBFields.caloriesN] = nutritionCol;
          dbColMap[DBFields.carbsN] = nutritionCol;
          dbColMap[DBFields.fatN] = nutritionCol;
          dbColMap[DBFields.proteinN] = nutritionCol;
          dbColMap[DBFields.durationS] = sleepCol;
          dbColMap[DBFields.qualityS] = sleepCol;
          dbColMap[DBFields.noteS] = sleepCol;
          dbColMap[DBFields.quantityH] = hydrationCol;
          connected = true;
        }
      },
      onError: (e) => print(e.toString())
    );
  }

  void clearService() {
    connected = false;
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
        'calorie_goal': 2000,
        'protein_goal': 200,
        'fat_goal': 50,
        'carb_goal': 150,
        'sleep_goal': 8,
        'hydration_goal': 64,
      };
      userReference.add(newUserEntry).then((newUserDoc) {
        userDoc = newUserDoc;
        initService();
      });
    }
  }

  void updateGoal(DBFields field, num val) async {
    if(!connected) {
      throw Exception('Attempted to add to sleep while not connected');
    }
    final Map<String, num> updateEntry = {
      dbGoalMap[field]!: val
    };
    userDoc!.update(updateEntry);
  }

  void addSleep(List<dynamic> data) async {

    if(!connected) {
      throw Exception('Attempted to add to sleep while not connected');
    }
    final newEntry = <String, dynamic>{
      "hours": num.parse(data[0]),
      "time_logged": Timestamp.now(),
      "sleep_quality": num.parse(data[1]),
      "notes":data[2]
    };
    await sleepCol!.add(newEntry).then((documentSnapshot) => print("Added Sleep Data with ID: ${documentSnapshot.id}"));
  }

  void addHydration(List<dynamic> data) async {
    if(!connected) {
      throw Exception('Attempted to add to sleep while not connected');
    }
    final newEntry = <String, dynamic>{
      "amount": num.parse(data[0]),
      "time_logged": Timestamp.now(),
    };
    await hydrationCol!.add(newEntry).then((documentSnapshot) => print("Added Hydration Data with ID: ${documentSnapshot.id}"));
  }

  void addNutrition(List<dynamic> data) async {
    if(!connected) {
      throw Exception('Attempted to add to sleep while not connected');
    }
    final newEntry = <String, dynamic>{
      "food_name": data[0],
      "time_logged": Timestamp.now(),
      "total_calories": num.parse(data[1]),
      "total_carbs": num.parse(data[2]),
      "total_fats": num.parse(data[3]),
      "total_protein": num.parse(data[4])
    };
    await nutritionCol!.add(newEntry).then((documentSnapshot) => print("Added Nutrition Data with ID: ${documentSnapshot.id}"));
  }

  void addWorkout(List<dynamic> data) async {
    if(!connected) {
      throw Exception('Attempted to add to sleep while not connected');
    }
    int setCount = data[2].length;

    final newEntry = <String, dynamic>{
      "Workout_name": data[0],
      "notes": data[1],
      "set_count": setCount,
      "reps": data[2],
      "weight": data[3],
    };
    await workoutCol!.add(newEntry).then((documentSnapshot) => print("Added Workout Data with ID: ${documentSnapshot.id}"));
  }
  static num sumAgg(List<num> nums) {
    return nums.sum;
  }

  static num avgAgg(List<num> nums) {
    return nums.average;
  }

  void getFieldAggSince(DBFields field, ValueSetter<num> whenGet, int daysAgo, num Function(List<num> nums) aggFunc) async {
    if(!connected){
      throw Exception('trying to read while not connected');
    }
    DateTime dt = DateTime.now().subtract(Duration(days: daysAgo, hours: DateTime.now().hour, minutes: DateTime.now().minute));
    // Timestamp ts = Timestamp.fromDate(dt);
    dbColMap[field]!.where('time_logged', isGreaterThanOrEqualTo: dt).get().then((value) {
      List<num> fieldValList = [];
      print(value.docs.length);
      for(int i = 0; i < value.docs.length; i++) {
        fieldValList.add(value.docs[i].get(dbFieldMap[field]!));
      }
      num result = aggFunc(fieldValList);
      whenGet(result);
    });
  }

  num get getNutGoal{
    while(!connected) { print('trying to read while ');}
    return (2000);
  }
  num get getHydroGoal{
    while(!connected) { print('trying to read while ');}
    return (64);
  }
  num get getSleepGoal{
    while(!connected) { print('trying to read while ');}
    return (8);
  }
}