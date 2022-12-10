import 'dart:core';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

typedef void ServiceCallback(List<dynamic> data);

/// Enumeration to define all possible log fields
///
/// Last letter is the collection it is a part of
enum DBFields {
  nameN,
  caloriesN,
  fatN,
  carbsN,
  proteinN,
  durationS,
  qualityS,
  noteS,
  quantityH,
  weightM,
  waistM,
  bicepM,
  exercise
}

/// Extends associated values upon the DBFields enumeration
extension DBFieldValues on DBFields {
  /// Returns the field name used in Firestore
  ///
  /// Throws an exception if the field has no such property
  String get getFieldStr {
    switch (this) {
      case DBFields.nameN:
        return 'food_name';
      case DBFields.caloriesN:
        return 'total_calories';
      case DBFields.carbsN:
        return 'total_carbs';
      case DBFields.fatN:
        return 'total_fats';
      case DBFields.proteinN:
        return 'total_protein';
      case DBFields.durationS:
        return 'hours';
      case DBFields.qualityS:
        return 'sleep_quality';
      case DBFields.noteS:
        return 'notes';
      case DBFields.quantityH:
        return 'amount';
      case DBFields.weightM:
        return 'weight';
      case DBFields.waistM:
        return 'waist';
      case DBFields.bicepM:
        return 'bicep';
      default:
        throw Exception('There is no field for the enum ${toString()}');
    }
  }

  /// Returns the field name of the user's goal in this category
  ///
  /// Throws an exception if the field has no such property
  String get getGoalStr {
    switch (this) {
      case DBFields.caloriesN:
        return 'calorie_goal';
      case DBFields.carbsN:
        return 'carb_goal';
      case DBFields.fatN:
        return 'fat_goal';
      case DBFields.proteinN:
        return 'protein_goal';
      case DBFields.durationS:
        return 'sleep_goal';
      case DBFields.quantityH:
        return 'hydration_goal';
      case DBFields.weightM:
        return 'weight_goal';
      case DBFields.waistM:
        return 'waist_goal';
      case DBFields.bicepM:
        return 'bicep_goal';
      default:
        throw Exception('There is no goal for the field ${toString()}');
    }
  }

  /// Returns the field name of the user's aggregate plot points in this category
  ///
  /// Throws an exception if the field has no such property
  String get getRawPlotStr {
    switch (this) {
      case DBFields.caloriesN:
        return 'sum_calories_y';
      case DBFields.carbsN:
        return 'sum_carbs_y';
      case DBFields.fatN:
        return 'sum_fats_y';
      case DBFields.proteinN:
        return 'sum_protein_y';
      case DBFields.durationS:
        return 'sum_sleep_hours_y';
      case DBFields.quantityH:
        return 'sum_hydration_y';
      case DBFields.weightM:
        return 'avg_weight_y';
      case DBFields.waistM:
        return 'avg_waist_y';
      case DBFields.bicepM:
        return 'avg_bicep_y';
      default:
        throw Exception('There is no plot points for the field ${toString()}');
    }
  }

  /// Returns the field names of the user's trendline in this category
  /// (based on raw plot points)
  ///
  /// Uses y=mx+b
  ///
  /// [0]: represents the m
  ///
  /// [1]: represents the b
  ///
  /// Throws an exception if the field has no such property
  List<String> get getTrendsStr {
    switch (this) {
      case DBFields.caloriesN:
        return ['calories_m', 'calories_b'];
      case DBFields.carbsN:
        return ['carbs_m', 'carbs_b'];
      case DBFields.fatN:
        return ['fats_m', 'fats_b'];
      case DBFields.proteinN:
        return ['protein_m', 'protein_b'];
      case DBFields.durationS:
        return ['sleep_hours_m', 'sleep_hours_b'];
      case DBFields.quantityH:
        return ['hydration_m', 'hydration_b'];
      case DBFields.weightM:
        return ['weight_m', 'weight_b'];
      case DBFields.waistM:
        return ['waist_m', 'waist_b'];
      case DBFields.bicepM:
        return ['bicep_m', 'bicep_b'];
      default:
        throw Exception('There are no trends for the field ${toString()}');
    }
  }

  /// Returns the title name of this field
  ///
  /// Throws an exception if the field has no such property
  String get getTitle {
    switch (this) {
      case DBFields.exercise:
        return 'Exercises';
      case DBFields.caloriesN:
        return 'Calories';
      case DBFields.durationS:
        return 'Hours Slept';
      case DBFields.quantityH:
        return 'Water Drank';
      case DBFields.weightM:
        return 'Weight';
      case DBFields.carbsN:
        return 'Carb';
      case DBFields.fatN:
        return 'Fats';
      case DBFields.proteinN:
        return 'Protein';
      case DBFields.waistM:
        return 'Waist Circ.';
      case DBFields.bicepM:
        return 'Bicep Circ.';
      default:
        return '';
    }
  }

  /// Returns the units of this field
  String get getUnits {
    switch (this) {
      case DBFields.nameN:
        return '';
      case DBFields.caloriesN:
        return 'kcal';
      case DBFields.carbsN:
        return 'grams';
      case DBFields.fatN:
        return 'grams';
      case DBFields.proteinN:
        return 'grams';
      case DBFields.durationS:
        return 'hours';
      case DBFields.qualityS:
        return '0-100';
      case DBFields.noteS:
        return '';
      case DBFields.quantityH:
        return 'oz';
      case DBFields.weightM:
        return 'lbs';
      case DBFields.waistM:
        return 'inches';
      case DBFields.bicepM:
        return 'inches';
      case DBFields.exercise:
        return '1RM';
      default:
        return '';
    }
  }
}

enum FeedbackTypes { error, suggestion }

extension FeedbackTypeNames on FeedbackTypes {
  String get getDBName {
    switch (this) {
      case FeedbackTypes.error:
        return 'error';
      case FeedbackTypes.suggestion:
        return 'suggestion';
    }
  }

  String get getTitle {
    switch (this) {
      case FeedbackTypes.error:
        return 'Error';
      case FeedbackTypes.suggestion:
        return 'Suggestion';
    }
  }
}

class FirebaseService {
  // makes firebase service a global singleton
  static final FirebaseService _db = FirebaseService._internal();
  factory FirebaseService() {
    return _db;
  }
  FirebaseService._internal();

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

  final CollectionReference userReference =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference foodReference =
      FirebaseFirestore.instance.collection('foods');
  final CollectionReference feedbackReference =
      FirebaseFirestore.instance.collection('feedback');

  /// Maps all DBField objects to a collectionreference object
  ///
  /// Updated each time this object is updated
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

  /// Represents all of this user's logged exercises
  List<String> _exerciseFields = [];

  /// Represents the titles of all exerciseFields
  List<String> _exerciseTitles = [];

  /// Represents the plotpoint fields of all exerciseFields
  List<String> _exercisePlotPoints = [];

  /// Represents all of this user's logged exercises
  List<String> getExerciseFields() {
    return _exerciseFields;
  }

  /// Represents the titles of all exerciseFields
  List<String> getExerciseTitles() {
    return _exerciseTitles;
  }

  /// Represents the plotpoint fields of all exerciseFields
  List<String> getExercisePlotPoints() {
    return _exercisePlotPoints;
  }

  /// Adds a new exercise with title [title] that the user wants to be able to log
  ///
  /// Adds to both database and current lists  of exercises
  void addExerciseName(String title) {
    String field = exerciseTitleToField(title);
    if (_exerciseFields.contains(field)) {
      return;
    }
    _exerciseFields.add(field);
    _exerciseTitles.add(title);
    _exercisePlotPoints.add("max1rm_${field}_y");
    userDoc!.update({'exercises': _exerciseTitles});
  }

  /// Returns a field name based on an exercise's title
  static String exerciseTitleToField(String title) {
    return title.replaceAll(' ', '_').toLowerCase();
  }

  /// Gets the formatted document title based on [date]
  static String getDateDocName(DateTime date) {
    String val = '${date.year}-';
    val += '${date.month < 10 ? '0' : ''}${date.month}-';
    val += (date.day < 10 ? '0' : '') + date.day.toString();
    return val;
  }

  /// [callback] will be called when connection status changes with a bool
  void addConnectedCallback(ValueSetter<bool> callback) {
    _connectionCallbacks.add(callback);
  }

  /// Remove all callbacks that are listening for connection status changes
  void clearConnectedCallback() {
    _connectionCallbacks.clear();
  }

  void initService() {
    if (FirebaseAuth.instance.currentUser == null) {
      assert(false);
    }
    userReference
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      if (value.size == 0) {
        initUser();
      } else {
        userDoc = value.docs.first.reference;
        List<dynamic> temp =
            (value.docs.first.data()! as Map<String, dynamic>)['exercises'];
        for (int i = 0; i < temp.length; i++) {
          _exerciseTitles.add(temp[i].toString());
        }
        for (int i = 0; i < _exerciseTitles.length; i++) {
          String exField = exerciseTitleToField(_exerciseTitles[i]);
          _exerciseFields.add(exField);
          _exercisePlotPoints.add("max1rm_${exField}_y");
        }
        userDoc!
            .collection('graph_data')
            .where(FieldPath.documentId, isEqualTo: 'trend_data')
            .get()
            .then((value) {
          trendsDoc = value.docs.first;
          connected = true;
          for (int i = 0; i < _connectionCallbacks.length; i++) {
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
    }, onError: (e) => print(e.toString()));
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
    for (int i = 0; i < _connectionCallbacks.length; i++) {
      _connectionCallbacks[i](false);
    }
  }

  /// Initializes the current user a new document
  ///
  /// Fills goals, exercises, and trends with empty/default values
  void initUser() {
    if (FirebaseAuth.instance.currentUser != null) {
      final newUserEntry = <String, dynamic>{
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
        'exercises': ['Bench Press', 'Squat', 'Deadlift'],
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
        userDoc!
            .collection('graph_data')
            .doc('trend_data')
            .set(initTrends)
            .then((value) {
          initService();
        });
      });
    }
  }

  /// Updates the current users's goal for the given [field] with [val]
  void updateGoal(DBFields field, num val) async {
    if (!connected) {
      throw Exception('Attempted to add to sleep while not connected');
    }
    final Map<String, num> updateEntry = {field.getGoalStr: val};
    userDoc!.update(updateEntry);
  }

  /// Logs the given [data] into the user's sleep collection
  ///
  /// data[0]: string of the log's hours of sleep
  ///
  /// data[1]: string of the log's sleep quality
  ///
  /// data[2]: string of the log's notes
  void addSleep(List<dynamic> data) async {
    if (!connected) {
      throw Exception('Attempted to add to sleep while not connected');
    }
    final newEntry = <String, dynamic>{
      "hours": num.parse(data[0]),
      "time_logged": Timestamp.now(),
      "sleep_quality": num.parse(data[1]),
      "notes": data[2]
    };
    await sleepCol!.add(newEntry).then((documentSnapshot) =>
        print("Added Sleep Data with ID: ${documentSnapshot.id}"));
  }

  /// Logs the given [data] into the user's hydration collection
  ///
  /// data[0]: string of the log's new hydration
  void addHydration(List<dynamic> data) async {
    if (!connected) {
      throw Exception('Attempted to add to hydration while not connected');
    }
    final newEntry = <String, dynamic>{
      "amount": num.parse(data[0]),
      "time_logged": Timestamp.now(),
    };
    await hydrationCol!.add(newEntry).then((documentSnapshot) =>
        print("Added Hydration Data with ID: ${documentSnapshot.id}"));
  }

  /// Logs the given [data] into the user's nutrition collection
  ///
  /// data[0]: string of the log's food name
  ///
  /// data[1]: string of the log's total calories
  ///
  /// data[2]: string of the log's total carbs
  ///
  /// data[3]: string of the log's total fats
  ///
  /// data[4]: string of the log's total protein
  void addNutrition(List<dynamic> data) async {
    if (!connected) {
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
    await nutritionCol!.add(newEntry).then((documentSnapshot) =>
        print("Added Nutrition Data with ID: ${documentSnapshot.id}"));
  }

  /// Logs the given [data] into the user's workout collection
  ///
  /// data[0]: string of the log's exercise name
  ///
  /// data[1]: string of the log's notes
  ///
  /// data[2]: list of nums of the log's exercise reps
  ///
  /// data[3]: list of nums of the log's exercise weight
  void addWorkout(List<dynamic> data) async {
    if (!connected) {
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
    await workoutCol!.add(newEntry).then((documentSnapshot) =>
        print("Added Workout Data with ID: ${documentSnapshot.id}"));
  }

  /// Logs the given [data] into the user's measurement collection
  ///
  /// [data] must be of length 3, but values can be empty if no data should
  /// be logged
  ///
  /// data[0]: string of log's weight (empty if no logged value)
  ///
  /// data[1]: string of log's waist circumference (empty if no logged value)
  ///
  /// data[2]: string of log's bicep circumference (empty if no logged value)
  void addMeasurement(List<dynamic> data) async {
    if (!connected) {
      throw Exception('Attempted to add to measurement while not connected');
    }
    final newEntry = <String, dynamic>{
      "weight": data[0].isEmpty ? -1 : num.parse(data[0]),
      "waist": data[1].isEmpty ? -1 : num.parse(data[1]),
      "bicep": data[2].isEmpty ? -1 : num.parse(data[2]),
      "time_logged": Timestamp.now(),
    };
    await measurementCol!.add(newEntry).then((documentSnapshot) =>
        print("Added Measurement Data with ID: ${documentSnapshot.id}"));
  }

  void addFeedback(List<dynamic> data) async {
    if (!connected) {
      throw Exception('Attempted to add to measurement while not connected');
    }
    final newEntry = {
      "feedback_type": data[0],
      "note": data[1],
      "uid": FirebaseAuth.instance.currentUser!.uid,
      "time_logged": Timestamp.now(),
    };
    await feedbackReference.add(newEntry).then((documentSnapshot) =>
        print("Logged feedback with ID: ${documentSnapshot.id}"));
  }

  /// Returns the sum of all values in a list
  static num sumAgg(List<num> nums) {
    return nums.sum;
  }

  /// Returns the average of all values in a list
  static num avgAgg(List<num> nums) {
    return nums.average;
  }

  /// Calls [whenGet] with the result of [aggFunc] given all [field] values in
  /// the last [daysAgo] days
  void getFieldAggSince(DBFields field, ValueSetter<num> whenGet, int daysAgo,
      num Function(List<num> nums) aggFunc) async {
    if (!connected) {
      throw Exception('trying to read while not connected');
    }
    DateTime dt = DateTime.now().subtract(Duration(
        days: daysAgo,
        hours: DateTime.now().hour,
        minutes: DateTime.now().minute));
    dbColMap[field]!
        .where('time_logged', isGreaterThanOrEqualTo: dt)
        .get()
        .then((value) {
      List<num> fieldValList = [];
      for (int i = 0; i < value.docs.length; i++) {
        Map<String, dynamic> docData =
            value.docs[i].data() as Map<String, dynamic>;
        if (docData.keys.contains(field.getFieldStr)) {
          fieldValList.add(value.docs[i].get(field.getFieldStr));
        }
      }
      num result = aggFunc(fieldValList);
      whenGet(result);
    });
  }

  /// Calls [whenGet] with a list of points from raw data points in [field].
  ///
  /// there can be up to [daysAgo] values, however they will be filtered for invalid results
  ///
  /// [exIdx] should specify the index of the exercise if [field] specifies an exercise field
  void getRawPlotPoints(
      DBFields field,
      void Function(List<dynamic> points) whenGet,
      int daysAgo,
      int? exIdx) async {
    if (!connected) {
      throw Exception('trying to read while not connected');
    }
    final List<String> validDocIDs = List.generate(daysAgo, (i) {
      DateTime curDay = DateTime.now().subtract(Duration(days: i));
      return '${curDay.year}-${curDay.month < 10 ? '0' : ''}${curDay.month}-${curDay.day < 10 ? '0' : ''}${curDay.day}';
    });
    rawGraphCol!
        .where(FieldPath.documentId, whereIn: validDocIDs)
        .get()
        .then((value) {
      String fieldStr = field == DBFields.exercise
          ? _exercisePlotPoints[exIdx!]
          : field.getRawPlotStr;
      print(fieldStr);
      if (exIdx != null) print(exIdx);
      List<FlSpot> points = [];
      num xmin = double.maxFinite;
      num xmax = -double.maxFinite;
      num ymin = double.maxFinite;
      num ymax = -double.maxFinite;
      print(value.docs.length);
      for (int i = 0; i < value.docs.length; i++) {
        Map<String, dynamic> docData =
            value.docs[i].data() as Map<String, dynamic>;
        if (docData.keys.contains(fieldStr)) {
          //checks if document has an entry (for newly tracked values)
          RegExp dashreg = RegExp(r'-');
          String xstring = value.docs[i].id;
          int y_idx = xstring.indexOf(dashreg);
          num xdty = num.parse(xstring.substring(0, y_idx));
          int m_idx = xstring.indexOf(dashreg, y_idx + 1);
          num xdtm = num.parse(xstring.substring(y_idx + 1, m_idx));
          num xdtd = num.parse(xstring.substring(m_idx + 1));
          num xval = DateTime(xdty.toInt(), xdtm.toInt(), xdtd.toInt())
              .millisecondsSinceEpoch;
          // double xval =
          //     double.parse(value.docs[i].id.replaceAll(RegExp(r'-'), ''));
          double yval = docData[fieldStr].toDouble();
          if (yval > 0) {
            xmin = min(xval, xmin);
            xmax = max(xval, xmax);
            ymin = min(yval, ymin);
            ymax = max(yval, ymax);
            points.add(FlSpot(xval.toDouble(), yval));
          }
        }
      }
      whenGet([xmin, xmax, ymin, ymax, points]);
    });
  }
}
