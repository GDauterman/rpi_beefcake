import 'dart:core';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';

typedef void ServiceCallback(List<dynamic> data);

enum DBFields { nameN, caloriesN, fatN, carbsN, proteinN, durationS, qualityS, noteS, quantityH, weightM, waistM, bicepM, exercise }

class FirebaseService {

  bool connected = false;
  List<ValueSetter<bool>> _connectionCallbacks = [];

  DocumentReference? userDoc;
  CollectionReference? sleepCol;
  CollectionReference? nutritionCol;
  CollectionReference? hydrationCol;
  CollectionReference? workoutCol;
  CollectionReference? measurementCol;
  CollectionReference? rawGraphCol;
  DocumentSnapshot? trendsDoc;

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
    DBFields.weightM: 'weight',
    DBFields.waistM: 'waist',
    DBFields.bicepM: 'bicep',
  };

  final Map<DBFields, String> dbGoalMap = {
    DBFields.caloriesN: 'calorie_goal',
    DBFields.carbsN: 'carb_goal',
    DBFields.fatN: 'fat_goal',
    DBFields.proteinN: 'protein_goal',
    DBFields.durationS: 'sleep_goal',
    DBFields.quantityH: 'hydration_goal',
    DBFields.weightM: 'weight_goal',
    DBFields.waistM: 'waist_goal',
    DBFields.bicepM: 'bicep_goal',
  };

  final Map<DBFields, String> dbPlotYMap = {
    DBFields.caloriesN: 'sum_calories_y',
    DBFields.carbsN: 'sum_carbs_y',
    DBFields.fatN: 'sum_fats_y',
    DBFields.proteinN: 'sum_protein_y',
    DBFields.durationS: 'sum_sleep_hours_y',
    DBFields.quantityH: 'sum_hydration_y',
    DBFields.weightM: 'avg_weight_y',
    DBFields.waistM: 'avg_waist_y',
    DBFields.bicepM: 'avg_bicep_y',
  };

  Map<DBFields, List<String>> dbTrendMap = {
    DBFields.caloriesN: ['calories_m', 'calories_b'],
    DBFields.carbsN: ['carbs_m', 'carbs_b'],
    DBFields.fatN: ['fats_m', 'fats_b'],
    DBFields.proteinN: ['protein_m', 'protein_b'],
    DBFields.durationS: ['sleep_hours_m', 'sleep_hours_b'],
    DBFields.quantityH: ['hydration_m', 'hydration_b'],
    DBFields.weightM: ['weight_m', 'weight_b'],
    DBFields.waistM: ['waist_m', 'waist_b'],
    DBFields.bicepM: ['bicep_m', 'bicep_b'],
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
    DBFields.weightM: null,
    DBFields.waistM: null,
    DBFields.bicepM: null,
    DBFields.exercise: null,
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
    DBFields.weightM: 'lbs',
    DBFields.waistM: 'inches',
    DBFields.bicepM: 'inches',
    DBFields.exercise: '1RM',
  };

  final Map<DBFields, String> dbTitleMap = {
    DBFields.exercise: 'Exercises',
    DBFields.caloriesN: 'Calories',
    DBFields.durationS: 'Hours Slept',
    DBFields.quantityH: 'Water Drank',
    DBFields.weightM: 'Weight',
    DBFields.carbsN: 'Carb',
    DBFields.fatN: 'Fats',
    DBFields.proteinN: 'Protein',
    DBFields.waistM: 'Waist Circ.',
    DBFields.bicepM: 'Bicep Circ.',
  };

  List<String> _exerciseFields = [];
  List<String> _exerciseTitles = [];
  List<String> _exercisePlotPoints = [];

  List<String> getExerciseFields() { return _exerciseFields; }
  List<String> getExerciseTitles() { return _exerciseTitles; }
  List<String> getExercisePlotPoints() { return _exercisePlotPoints; }

  void addExerciseName(String title) {
    String field = fieldify(title);
    if(_exerciseFields.contains(field)) {
      return;
    }
    _exerciseFields.add(field);
    _exerciseTitles.add(title);
    _exercisePlotPoints.add("max1rm_"+field+"_y");
  }

  static String fieldify(String title) {
    return title.replaceAll(' ', '_').toLowerCase();
  }

  static String getDateDocName(DateTime date) {
    String val = date.year.toString() + '-';
    val += (date.month < 10 ? '0' : '') + date.month.toString() + '-';
    val += (date.day < 10 ? '0' : '') + date.day.toString();
    return val;
  }

  void addConnectedCallback(ValueSetter<bool> callback){
    _connectionCallbacks.add(callback);
  }

  void clearConnectedCallback() {
    _connectionCallbacks.clear();
  }

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
          List<dynamic> temp = (value.docs.first.data()! as Map<String, dynamic>)['exercises'];
          for(int i = 0; i < temp.length; i++) {
            _exerciseTitles.add(temp[i].toString());
          }
          for(int i = 0; i < _exerciseTitles.length; i++) {
            String exField = fieldify(_exerciseTitles[i]);
            _exerciseFields.add(exField);
            _exercisePlotPoints.add("max1rm_"+exField+"_y");
          }
          userDoc!.collection('graph_data').where(FieldPath.documentId, isEqualTo: 'trend_data').get().then((value) {
            trendsDoc = value.docs.first;
            connected = true;
            for(int i = 0; i < _connectionCallbacks.length; i++) {
              _connectionCallbacks[i](true);
            }
          });
          sleepCol = userDoc!.collection('sleep');
          nutritionCol = userDoc!.collection('nutrition');
          hydrationCol = userDoc!.collection('hydration');
          measurementCol = userDoc!.collection('measurement');
          workoutCol = userDoc!.collection('workout');
          rawGraphCol = userDoc!.collection('raw_graph_points');
          dbColMap[DBFields.nameN] = nutritionCol;
          dbColMap[DBFields.caloriesN] = nutritionCol;
          dbColMap[DBFields.carbsN] = nutritionCol;
          dbColMap[DBFields.fatN] = nutritionCol;
          dbColMap[DBFields.proteinN] = nutritionCol;
          dbColMap[DBFields.durationS] = sleepCol;
          dbColMap[DBFields.qualityS] = sleepCol;
          dbColMap[DBFields.noteS] = sleepCol;
          dbColMap[DBFields.quantityH] = hydrationCol;
          dbColMap[DBFields.weightM] = measurementCol;
          dbColMap[DBFields.waistM] = measurementCol;
          dbColMap[DBFields.bicepM] = measurementCol;
          dbColMap[DBFields.exercise] = workoutCol;
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
    measurementCol = null;
    workoutCol = null;
    rawGraphCol = null;
    for(int i = 0; i < _connectionCallbacks.length; i++) {
      _connectionCallbacks[i](false);
    }
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
        'weight_goal': 175,
        'waist_goal': 30,
        'bicep_goal': 15,
      };
      userReference.add(newUserEntry).then((newUserDoc) {
        const Map<String, num> initTrends = {
          'calories_m': -1,
          'calories_b': -1,
          'carbs_m': -1,
          'carbs_b': -1,
          'fats_m': -1,
          'fats_b': -1,
          'protein_m': -1,
          'protein_b': -1,
          'sleep_hours_m': -1,
          'sleep_hours_b': -1,
          'hydration_m': -1,
          'hydration_b': -1,
          'weight_m': -1,
          'weight_b': -1,
          'waist_m': -1,
          'waist_b': -1,
          'bicep_m': -1,
          'bicep_b': -1,
        };
        userDoc = newUserDoc;
        userDoc!.collection('graph_data').doc('trend_data').set(initTrends).then((value) {
          initService();
        });
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
      throw Exception('Attempted to add to hydration while not connected');
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
    num setCount = data[2].length;

    final newEntry = <String, dynamic>{
      "exercise_name": data[0],
      "time_logged": Timestamp.now(),
      "notes": data[1],
      "set_count": setCount,
      "reps": data[2],
      "weight": data[3],
    };
    await workoutCol!.add(newEntry).then((documentSnapshot) => print("Added Workout Data with ID: ${documentSnapshot.id}"));
  }

  void addMeasurement(List<dynamic> data) async {
    if(!connected) {
      throw Exception('Attempted to add to measurement while not connected');
    }
    final newEntry = <String, dynamic>{
      "weight": data[0].isEmpty ? -1 : num.parse(data[0]),
      "waist": data[1].isEmpty ? -1 : num.parse(data[1]),
      "bicep": data[2].isEmpty ? -1 : num.parse(data[2]),
      "time_logged": Timestamp.now(),
    };
    await measurementCol!.add(newEntry).then((documentSnapshot) => print("Added Measurement Data with ID: ${documentSnapshot.id}"));
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
    dbColMap[field]!.where('time_logged', isGreaterThanOrEqualTo: dt).get().then((value) {
      List<num> fieldValList = [];
      for(int i = 0; i < value.docs.length; i++) {
        Map<String, dynamic> docData = value.docs[i].data() as Map<String, dynamic>;
        if(docData.keys.contains(dbFieldMap[field]!)) {
          fieldValList.add(value.docs[i].get(dbFieldMap[field]!));
        }
      }
      num result = aggFunc(fieldValList);
      whenGet(result);
    });
  }

  void getRawPlotPoints(DBFields field, void Function(List<dynamic> points) whenGet, int daysAgo, int? exIdx) async {
    if(!connected){
      throw Exception('trying to read while not connected');
    }
    final List<String> validDocIDs = List.generate(daysAgo, (i) {
      DateTime curDay = DateTime.now().subtract(Duration(days:i));
      return curDay.year.toString() + '-' + (curDay.month<10?'0':'') + curDay.month.toString() + '-' + (curDay.day<10?'0':'') + curDay.day.toString();
    });
    rawGraphCol!.where(FieldPath.documentId, whereIn: validDocIDs).get().then((value) {
      String fieldStr = field == DBFields.exercise ? _exercisePlotPoints[exIdx!] : dbPlotYMap[field]!;
      print(fieldStr);
      if(exIdx != null)
        print(exIdx);
      List<FlSpot> points = [];
      num xmin = double.maxFinite;
      num xmax = -double.maxFinite;
      num ymin = double.maxFinite;
      num ymax = -double.maxFinite;
      print(value.docs.length);
      for(int i = 0; i < value.docs.length; i++) {
        Map<String, dynamic> docData = value.docs[i].data() as Map<String, dynamic>;
        if(docData.keys.contains(fieldStr)) { //checks if document has an entry (for newly tracked values)
          double xval = double.parse(value.docs[i].id.replaceAll(RegExp(r'-'), ''));
          double yval = docData[fieldStr].toDouble();
          if (yval > 0) {
            xmin = min(xval, xmin);
            xmax = max(xval, xmax);
            ymin = min(yval, ymin);
            ymax = max(yval, ymax);
            points.add(FlSpot(xval, yval));
          }
        }
      }
      whenGet([xmin, xmax, ymin, ymax, points]);
    });
  }
}