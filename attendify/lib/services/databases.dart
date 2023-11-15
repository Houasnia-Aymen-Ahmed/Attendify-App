import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/attendify_student.dart';
import '../models/attendify_teacher.dart';
import '../models/module_model.dart';
import '../models/user_of_attendify.dart';
import 'auth.dart';

class DatabaseService {
  final AuthService _auth = AuthService();
  final String? uid;
  bool isUserDataExist = true;
  bool isModuleDataExist = true;
  DatabaseService({this.uid});

  CollectionReference userColl =
      FirebaseFirestore.instance.collection("UserCollection");
  CollectionReference teacherColl =
      FirebaseFirestore.instance.collection("TeacherCollection");
  CollectionReference studentColl =
      FirebaseFirestore.instance.collection("StudentCollection");
  CollectionReference modulesColl =
      FirebaseFirestore.instance.collection("Modules");

  Future updateUserData({
    required String userName,
    required String userType,
    String token = '',
    required String usrUid,
  }) async {
    DocumentReference userDoc = userColl.doc(uid);
    await userDoc.set({
      'username': userName,
      'userType': userType,
      'token': token,
      'uid': uid,
    });
    if (userType == "teacher") {
      await teacherColl.doc(uid).set({
        'username': userName,
        'userType': userType,
        'token': token,
        'uid': uid,
      });
    } else {
      await studentColl.doc(uid).set({
        'username': userName,
        'userType': userType,
        'token': token,
        'uid': uid,
      });
    }
  }

  Future updateUserSpecificData({
    String? username,
    String? userType,
    String? token,
    String? uid,
  }) async {
    String usrUid = uid ?? _auth.currentUsr!.uid;
    Map<String, dynamic> map = {
      "username": username,
      "userType": userType,
      "token": token,
      "uid": uid,
    };
    for (var entry in map.entries) {
      if (entry.value != null) {
        await userColl.doc(usrUid).update({
          entry.key.toString(): entry.value,
        });
      }
    }
  }

  Future<void> updateTeacherData({
    required String userName,
    required String userType,
    String token = '',
    required String uid,
    List<String>? modules,
  }) async {
    await teacherColl.doc(uid).set(
      {
        'user': uid,
        'username': userName,
        'userType': userType,
        'token': token,
        'modules': modules,
      },
    );
  }

  Future<void> updateTeacherSpecificData({
    String? username,
    String? userType,
    String? token,
    String? uid,
    List<String>? modules,
  }) async {
    String usrUid = uid ?? _auth.currentUsr!.uid;
    Map<String, dynamic> map = {
      "username": username,
      "userType": userType,
      "token": token,
      "uid": uid,
    };
    for (var entry in map.entries) {
      if (entry.value != null) {
        await teacherColl.doc(usrUid).update({
          entry.key.toString(): entry.value,
        });
      }
    }

    if (modules != null) {
      await teacherColl.doc(usrUid).update({
        "modules": FieldValue.arrayUnion(modules),
      });
    }
  }

  Future<void> updateStudentData({
    required String userName,
    required String userType,
    String token = '',
    required String uid,
    String? grade,
    String? speciality,
  }) async {
    await studentColl.doc(uid).set(
      {
        'uid': uid,
        'username': userName,
        'userType': userType,
        'token': token,
        'grade': grade,
        'speciality': speciality,
      },
    );
  }

  Future<void> updateStudentSpecificData({
    String? username,
    String? userType,
    String? token,
    String? uid,
    String? grade,
    String? speciality,
  }) async {
    String usrUid = uid ?? _auth.currentUsr!.uid;
    Map<String, dynamic> map = {
      "username": username,
      "userType": userType,
      "token": token,
      "uid": uid,
      "grade": grade,
      "speciality": speciality,
    };
    for (var entry in map.entries) {
      if (entry.value != null) {
        await teacherColl.doc(usrUid).update({
          entry.key.toString(): entry.value,
        });
      }
    }
  }

  Future updateModuleData({
    required String uid,
    required String name,
    required bool isActive,
    required String speciality,
    required String grade,
    required Map<String, String> students,
    required Map<String, dynamic> attendanceTable,
    bool? checkExists,
  }) async {
    if (checkExists == null || !checkExists) {
      return await modulesColl.doc(uid).set({
        'uid': uid,
        'name': name,
        'isActive': isActive,
        'speciality': speciality,
        'grade': grade,
        'students': students,
        'attendanceTable': attendanceTable,
      });
    } else {
      DocumentSnapshot document = await modulesColl.doc(uid).get();
      if (!document.exists) {
        return await modulesColl.doc(uid).set({
          'uid': uid,
          'name': name,
          'isActive': isActive,
          'speciality': speciality,
          'grade': grade,
          'students': students,
          'attendanceTable': attendanceTable,
        });
      }
    }
  }

  Future updateModuleSpecificData({
    String? uid,
    String? name,
    bool? isActive,
    String? speciality,
    String? grade,
    String? addStudent,
    String? studentName,
    bool? checkExists,
  }) async {
    if (addStudent != null && studentName != null) {
      final moduleDoc = modulesColl.doc(uid);
      final currentStudents = Map<String, String>.from(
        (await moduleDoc.get()).get("students") ?? {},
      );

      currentStudents[addStudent] = studentName;
      await moduleDoc.update(
        {
          "students": currentStudents,
        },
      );
    }

    Map<String, dynamic> map = {
      'uid': uid,
      'name': name,
      'isActive': isActive,
      'speciality': speciality,
      'grade': grade,
    };

    for (var entry in map.entries) {
      if (entry.value != null) {
        await modulesColl.doc(uid).update({
          entry.key.toString(): entry.value,
        });
      }
    }
  }

  Future<void> updateAttendance(
    String moduleID,
    String date,
    String studentID,
    bool isPresent,
    BuildContext context,
  ) async {
    try {
      await modulesColl.doc(moduleID).update({
        'attendanceTable.$date.$studentID': isPresent,
      });
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20.0),
          backgroundColor: Colors.red,
          dismissDirection: DismissDirection.startToEnd,
          elevation: 20.0,
          content: Text(e.toString()),
          action: SnackBarAction(
            textColor: Colors.blue[100],
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> addToAttendanceTable(
    String moduleID,
    Map<String, dynamic> newAttendance,
  ) async {
    await modulesColl.doc(moduleID).set(
      {
        'attendanceTable': newAttendance,
      },
      SetOptions(merge: true),
    );
  }

  Future<QuerySnapshot> getModulesByGradeAndSpeciality(
      String grade, String speciality) async {
    QuerySnapshot querySnapshot = await modulesColl
        .where('grade', isEqualTo: grade)
        .where('speciality', isEqualTo: speciality)
        .get();

    return querySnapshot;
  }

  Future<void> updateModulesWithCriteria({
    String? grade,
    String? speciality,
    String? studentUID,
    String? studentName,
  }) async {
    QuerySnapshot querySnapshot = await getModulesByGradeAndSpeciality(
      grade!,
      speciality!,
    );

    for (var doc in querySnapshot.docs) {
      await updateModuleSpecificData(
        uid: doc.id,
        addStudent: studentUID,
        studentName: studentName,
      );
    }
  }

  AttendifyUser _currentUserFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      isUserDataExist = true;
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;
      return AttendifyUser(
        userName: doc["username"] ?? 'username',
        userType: doc["userType"] ?? "usertype",
        token: doc["token"] ?? 'token',
        uid: doc["uid"] ?? 'uid',
      );
    } else {
      isUserDataExist = false;
      return AttendifyUser(
        userName: 'username',
        userType: "usertype",
        token: 'token',
        uid: 'uid',
      );
    }
  }

  Student _currentStudentFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;
      return Student(
        userName: doc["username"] ?? 'username',
        userType: doc["userType"] ?? "usertype",
        token: doc["token"] ?? 'token',
        uid: doc["uid"] ?? 'uid',
        grade: doc["grade"] ?? 'grade',
        speciality: doc["speciality"] ?? 'speciality',
      );
    } else {
      return Student(
        userName: 'username',
        userType: "usertype",
        token: 'token',
        uid: 'uid',
        grade: 'grade',
        speciality: 'speciality',
      );
    }
  }

  Module _currentModuleFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;

      return Module(
        uid: doc["uid"] ?? 'uid',
        name: doc["name"] ?? 'name',
        speciality: doc["speciality"] ?? 'speciality',
        grade: doc["grade"] ?? "grade",
        isActive: doc["isActive"] ?? false,
        students: Map<String, String>.from(
          doc["students"] ?? {},
        ),
        attendanceTable: Map<String, dynamic>.from(
          doc["attendanceTable"] ?? {},
        ),
      );
    } else {
      return Module(
        uid: "uid",
        name: "name",
        speciality: "speciality",
        grade: "grade",
        isActive: false,
        students: {},
        attendanceTable: {},
      );
    }
  }

  Teacher _currentTeacherFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;
      String userUid = doc["user"];

      List<String>? modules = (doc["modules"] as List<dynamic>?)
              ?.map(
                (e) => e.toString(),
              )
              .toList() ??
          [""];

      return Teacher(
        userName: doc["username"] ?? 'username',
        userType: doc["userType"] ?? "usertype",
        token: doc["token"] ?? 'token',
        uid: userUid,
        modules: modules,
      );
    } else {
      return Teacher(
        userName: 'username',
        userType: "usertype",
        token: 'token',
        uid: 'uid',
        modules: [],
      );
    }
  }

  Stream<Teacher> getTeacherDataStream(String teacherId) {
    return teacherColl
        .doc(teacherId)
        .snapshots()
        .map(_currentTeacherFromSnapshots);
  }

  Stream<AttendifyUser> getUserDataStream(String userId) {
    return userColl.doc(userId).snapshots().map(_currentUserFromSnapshots);
  }

  Stream<Student> getStudentDataStream(String userId) {
    return studentColl
        .doc(userId)
        .snapshots()
        .map(_currentStudentFromSnapshots);
  }

  Stream<List<Student>> getStudentsList(List<String> studentUIDs) {
    studentUIDs = studentUIDs.isNotEmpty ? studentUIDs : ["stuentdUid"];
    return studentColl
        .where(FieldPath.documentId, whereIn: studentUIDs)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return _currentStudentFromSnapshots(doc);
      }).toList();
    });
  }

  Stream<Module> getModuleStream(String moduleId) {
    return modulesColl
        .doc(moduleId)
        .snapshots()
        .map(_currentModuleFromSnapshots);
  }

  Stream<List<Module>> getModuleByGradeSpeciality(
    String grade,
    String speciality,
  ) {
    return modulesColl
        .where('grade', isEqualTo: grade)
        .where('speciality', isEqualTo: speciality)
        .snapshots()
        .asyncMap(
      (snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          List<Module> modules = [];
          for (var doc in snapshot.docs) {
            Module module = _currentModuleFromSnapshots(doc);
            modules.add(module);
          }
          return modules;
        } else {
          return [
            Module(
              uid: "uid",
              name: "names",
              speciality: "speciality",
              grade: "grade",
              isActive: false,
              students: {},
              attendanceTable: {},
            ),
          ];
        }
      },
    );
  }

  Stream<List<Module>> getModuleDataStream(String moduleID) {
    return modulesColl.doc(moduleID).snapshots().asyncMap(
      (snapshot) async {
        return [
          _currentModuleFromSnapshots(snapshot),
        ];
      },
    );
  }

  Stream<List<Module>> getModulesOfTeacher(List<String> moduleUIDs) {
    moduleUIDs =
        moduleUIDs.isNotEmpty ? moduleUIDs : ["grade_speciality_module_index"];
    return modulesColl
        .where(FieldPath.documentId, whereIn: moduleUIDs)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Module> modules = [];
      for (var doc in snapshot.docs) {
        Module module = _currentModuleFromSnapshots(doc);
        modules.add(module);
      }
      return modules;
    });
  }
}
