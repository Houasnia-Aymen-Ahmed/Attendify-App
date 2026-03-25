import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

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

  CollectionReference teacherEmailsColl =
      FirebaseFirestore.instance.collection("TeacherEmailsCollection");
  CollectionReference adminEmailsColl =
      FirebaseFirestore.instance.collection("AdminEmailsCollection");
  CollectionReference userColl =
      FirebaseFirestore.instance.collection("UserCollection");
  CollectionReference teacherColl =
      FirebaseFirestore.instance.collection("TeacherCollection");
  CollectionReference studentColl =
      FirebaseFirestore.instance.collection("StudentCollection");
  CollectionReference modulesColl =
      FirebaseFirestore.instance.collection("Modules");

  Future<void> addTeacherEmail(String email) async {
    teacherEmailsColl.doc("TeacherEmails").update({
      'emails': FieldValue.arrayUnion([email])
    });
  }

  Future<void> removeTeacherEmail(String email) async {
    teacherEmailsColl.doc("TeacherEmails").update({
      'emails': FieldValue.arrayRemove([email])
    });
  }

  Future updateUserData({
    required String userName,
    required String userType,
    required String usrUid,
    required String email,
    required String photoURL,
  }) async {
    DocumentReference userDoc = userColl.doc(uid);
    await userDoc.set({
      'username': userName,
      'userType': userType,
      'uid': uid,
      'email': email,
      'photoURL': photoURL,
    });

    switch (userType) {
      case "teacher":
        await teacherColl.doc(uid).set({
          'username': userName,
          'userType': userType,
          'uid': uid,
          'email': email,
          'photoURL': photoURL,
        });
        break;
      case "student":
        await studentColl.doc(uid).set({
          'username': userName,
          'userType': userType,
          'uid': uid,
          'email': email,
          'photoURL': photoURL,
        });
        break;
    }
  }

  Future<bool> isUserRegistered(String email) async {
    try {
      QuerySnapshot querySnapshot = await userColl
          .where(
            'email',
            isEqualTo: email,
          )
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return false;
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future updateUserSpecificData({
    String? username,
    String? userType,
    String? uid,
    String? email,
    String? photoURL,
  }) async {
    String usrUid = uid ?? _auth.currentUsr!.uid;
    Map<String, dynamic> map = {
      "username": username,
      "userType": userType,
      "uid": uid,
      "email": email,
      "photoURL": photoURL,
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
    required String uid,
    required String email,
    required String photoURL,
    List<String>? modules,
  }) async {
    await teacherColl.doc(uid).set(
      {
        'uid': uid,
        'email': email,
        'username': userName,
        'userType': userType,
        'photoURL': photoURL,
        'modules': modules,
      },
    );
  }

  Future<void> updateTeacherSpecificData({
    String? username,
    String? userType,
    String? uid,
    String? email,
    String? photoURL,
    List<String>? modules,
  }) async {
    String usrUid = uid ?? _auth.currentUsr!.uid;
    Map<String, dynamic> map = {
      "username": username,
      "userType": userType,
      "uid": uid,
      "email": email,
      'photoURL': photoURL,
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
    required String uid,
    required String email,
    required String photoURL,
    String? grade,
    String? speciality,
  }) async {
    await studentColl.doc(uid).set(
      {
        'uid': uid,
        'email': email,
        'username': userName,
        'userType': userType,
        'photoURL': photoURL,
        'grade': grade,
        'speciality': speciality,
      },
    );
  }

  Future<void> updateStudentSpecificData({
    String? username,
    String? userType,
    String? uid,
    String? email,
    String? photoURL,
    String? grade,
    String? speciality,
  }) async {
    String usrUid = uid ?? _auth.currentUsr!.uid;
    Map<String, dynamic> map = {
      "username": username,
      "userType": userType,
      "uid": uid,
      "email": email,
      'photoURL': photoURL,
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
    required int numberOfStudents,
    required Map<String, String> students,
    required Map<String, dynamic> attendanceTable,
    bool? checkExists,
    bool isNewModule = false,
  }) async {
    if (checkExists == null || !checkExists) {
      if (isNewModule) {
        int index = 0;
        QuerySnapshot querySnapshot = await modulesColl
            .where('uid', isGreaterThanOrEqualTo: uid)
            .orderBy('uid', descending: true)
            .limit(1)
            .get();
        for (var doc in querySnapshot.docs) {
          String docUid = doc.get('uid');
          if (docUid.startsWith(uid)) {
            int? currentIndex = int.tryParse(docUid.substring(uid.length));
            if (currentIndex != null && currentIndex >= index) {
              index = currentIndex + 1;
            }
          }
        }
        uid = '$uid$index';
        return await modulesColl.doc(uid).set({
          'uid': uid,
          'name': name,
          'isActive': isActive,
          'speciality': speciality,
          'grade': grade,
          'numberOfStudents': numberOfStudents,
          'students': {},
          'attendanceTable': {},
        });
      } else {
        return await modulesColl.doc(uid).set({
          'uid': uid,
          'name': name,
          'isActive': isActive,
          'speciality': speciality,
          'grade': grade,
          'numberOfStudents': numberOfStudents,
          'students': students,
          'attendanceTable': attendanceTable,
        });
      }
    } else {
      DocumentSnapshot document = await modulesColl.doc(uid).get();
      if (!document.exists) {
        return await modulesColl.doc(uid).set({
          'uid': uid,
          'name': name,
          'isActive': isActive,
          'speciality': speciality,
          'grade': grade,
          'numberOfStudents': numberOfStudents,
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
    int? numberOfStudents,
    String? addStudent,
    String? studentName,
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
      'numberOfStudents': numberOfStudents
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

  Future<Map<String, int>> fetchModuleAttendanceData(String moduleId) async {
    DocumentSnapshot moduleSnapshot = await modulesColl.doc(moduleId).get();
    Map<String, dynamic> attendanceTable =
        moduleSnapshot.get('attendanceTable');
    Map<String, int> attendanceData = {};

    if (attendanceTable.isNotEmpty) {
      attendanceTable.forEach((date, data) {
        int presentCount = data.values.where((value) => value == true).length;
        attendanceData[date] = presentCount;
      });
    }
    return attendanceData;
  }

  Future<Map<String, int>> fetchModuleStudentAttendancePercentage(
      String moduleId) async {
    DocumentSnapshot moduleSnapshot = await modulesColl.doc(moduleId).get();
    Map<String, dynamic> attendanceTable =
        moduleSnapshot.get('attendanceTable');
    Map<String, int> studentPresenceCount = {};

    if (attendanceTable.isNotEmpty) {
      attendanceTable.forEach((date, data) {
        data.forEach((student, isPresent) {
          if (!studentPresenceCount.containsKey(student)) {
            studentPresenceCount[student] = 0;
          }
          if (isPresent) {
            studentPresenceCount[student] = studentPresenceCount[student]! + 1;
          }
        });
      });
    }
    return studentPresenceCount;
  }

  Future<Map<String, dynamic>> fetchModuleStats(
    String moduleId,
  ) async {
    DocumentSnapshot moduleSnapshot = await modulesColl.doc(moduleId).get();
    Map<String, dynamic> attendanceTable = moduleSnapshot.get(
      'attendanceTable',
    );
    Map<String, int> attendanceData = {};
    Map<String, double> studentPresenceCount = {};

    if (attendanceTable.isNotEmpty) {
      attendanceTable.forEach(
        (date, data) {
          int presentCount = data.values.where((value) => value == true).length;
          attendanceData[date] = presentCount;

          data.forEach(
            (student, isPresent) {
              if (!studentPresenceCount.containsKey(student)) {
                studentPresenceCount[student] = 0;
              }
              if (isPresent) {
                studentPresenceCount[student] =
                    studentPresenceCount[student]! + 1;
              }
            },
          );
        },
      );
      int totalDates = attendanceTable.length;
      studentPresenceCount.forEach((student, presenceCount) {
        double percentage = (presenceCount / totalDates) * 100;
        studentPresenceCount[student] = percentage;
      });
    }

    return {
      'attendanceData': attendanceData,
      'studentPresenceCount': studentPresenceCount,
    };
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
        uid: doc["uid"] ?? 'uid',
        email: doc["email"] ?? "email",
        photoURL: doc["photoURL"] ?? "photoURL",
      );
    } else {
      isUserDataExist = false;
      return AttendifyUser(
        userName: 'username',
        userType: "usertype",
        uid: 'uid',
        email: "email",
        photoURL: "photoURL",
      );
    }
  }

  Student _currentStudentFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;
      return Student(
        userName: doc["username"] ?? 'username',
        userType: doc["userType"] ?? "usertype",
        uid: doc["uid"] ?? 'uid',
        email: doc["email"] ?? "email",
        photoURL: doc["photoURL"] ?? "photoURL",
        grade: doc["grade"] ?? 'grade',
        speciality: doc["speciality"] ?? 'speciality',
      );
    } else {
      return Student(
        userName: 'username',
        userType: "usertype",
        uid: 'uid',
        email: "email",
        photoURL: "photoURL",
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
        numberOfStudents: doc["numberOfStudents"] ?? 0,
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
        numberOfStudents: 0,
        isActive: false,
        students: {},
        attendanceTable: {},
      );
    }
  }

  Teacher _currentTeacherFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;

      List<String>? modules = (doc["modules"] as List<dynamic>?)
              ?.map(
                (e) => e.toString(),
              )
              .toList() ??
          [];

      return Teacher(
        userName: doc["username"] ?? 'username',
        userType: doc["userType"] ?? "usertype",
        uid: doc["uid"] ?? 'uid',
        email: doc["email"] ?? "email",
        photoURL: doc["photoURL"] ?? "photoURL",
        modules: modules,
      );
    } else {
      return Teacher(
        userName: 'username',
        userType: "usertype",
        uid: 'uid',
        email: "email",
        photoURL: "photoURL",
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
              numberOfStudents: 0,
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
      if (modules.length == 1 && modules[0].uid == "uid") {
        modules = [];
      }
      return modules;
    });
  }

  Stream<List<Module>> getModulesOfTeacherFromAdmin(
      List<String> moduleUIDs) async* {
    moduleUIDs =
        moduleUIDs.isNotEmpty ? moduleUIDs : ["grade_speciality_module_index"];

    List<Stream<List<Module>>> streams = [];
    for (var i = 0; i < moduleUIDs.length; i += 30) {
      var end = (i + 30 < moduleUIDs.length) ? i + 30 : moduleUIDs.length;
      var slice = moduleUIDs.sublist(i, end);

      streams.add(
        modulesColl.where(FieldPath.documentId, whereIn: slice).snapshots().map(
          (snapshot) {
            return snapshot.docs
                .map((doc) => _currentModuleFromSnapshots(doc))
                .toList();
          },
        ),
      );
    }

    yield* StreamGroup.merge(streams);
  }

  Future<void> removeTeacherById(String id) async {
    await teacherColl.doc(id).delete();
  }

  Future<void> removeStudentById(String id) async {
    await studentColl.doc(id).delete();
  }

  Future<void> removeModuleById(String id) async {
    await modulesColl.doc(id).delete();
  }

  Future<List<Module>> getAllModules() async {
    QuerySnapshot querySnapshot = await modulesColl.get();
    return querySnapshot.docs
        .map((doc) => _currentModuleFromSnapshots(doc))
        .toList();
  }

  Future<List<Student>> getAllStudents() async {
    QuerySnapshot querySnapshot = await studentColl.get();
    return querySnapshot.docs
        .map((doc) => _currentStudentFromSnapshots(doc))
        .toList();
  }

  Future<List<Teacher>> getAllTeachers() async {
    QuerySnapshot querySnapshot = await teacherColl.get();
    return querySnapshot.docs
        .map((doc) => _currentTeacherFromSnapshots(doc))
        .toList();
  }

  Future<List<String>> getAllTeachersEmails() async {
    try {
      List<String> emails = [];
      await teacherEmailsColl.doc("TeacherEmails").get().then((value) =>
          emails = (value.get("emails") as List<dynamic>).cast<String>());
      return emails;
    } on Exception catch (_) {
      throw Exception("not-authenticated-teacher");
    }
  }

  Future<List<String>> getAllAdminsEmails() async {
    try {
      List<String> emails = [];
      await adminEmailsColl.doc("AdminEmails").get().then((value) =>
          emails = (value.get("emails") as List<dynamic>).cast<String>());
      return emails;
    } on Exception catch (_) {
      throw Exception("not-authenticated-admin");
    }
  }

  Future<bool> isTeacherEmailRegistered(String email) async {
    try {
      List<String> allTeacherEmails = await getAllTeachersEmails();
      return allTeacherEmails.contains(email);
    } catch (e) {
      throw Exception("Database error: $e");
    }
  }

  Future<bool> isAdminEmailRegistered(String email) async {
    try {
      List<String> allAdminEmails = await getAllAdminsEmails();
      return allAdminEmails.contains(email);
    } catch (e) {
      throw Exception("Database error: $e");
    }
  }

  Future<Map<String, dynamic>> getAllTeachersAndEmails() async {
    final List<Teacher> teachers = await getAllTeachers();
    final List<String> emails = await getAllTeachersEmails();

    return {
      'teachers': teachers,
      'emails': emails,
    };
  }
}
