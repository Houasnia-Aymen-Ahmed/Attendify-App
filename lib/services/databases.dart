import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/theme/attendify_theme.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/models/user_of_attendify.dart';
import 'package:attendify/services/auth.dart';

class DatabaseService {
  final AuthService _auth = AuthService();
  final String? uid;
  bool isUserDataExist = true;
  bool isModuleDataExist = true;
  DatabaseService({this.uid});

  CollectionReference teacherEmailsColl =
      FirebaseFirestore.instance.collection('TeacherEmailsCollection');
  CollectionReference adminEmailsColl =
      FirebaseFirestore.instance.collection('AdminEmailsCollection');
  CollectionReference userColl =
      FirebaseFirestore.instance.collection('UserCollection');
  CollectionReference teacherColl =
      FirebaseFirestore.instance.collection('TeacherCollection');
  CollectionReference studentColl =
      FirebaseFirestore.instance.collection('StudentCollection');
  CollectionReference modulesColl =
      FirebaseFirestore.instance.collection('Modules');

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Map<String, dynamic> _asMap(dynamic data) =>
      Map<String, dynamic>.from(data as Map);

  String _resolvedUserName(String? primary, String? fallback) {
    final candidate = (primary ?? '').trim();
    if (candidate.isNotEmpty && candidate.toLowerCase() != 'username') {
      return candidate;
    }

    final backup = (fallback ?? '').trim();
    return backup.isNotEmpty ? backup : 'Username';
  }

  String _resolvedPhotoUrl(String? primary, String? fallback) {
    final candidate = (primary ?? '').trim();
    if (candidate.isNotEmpty &&
        candidate.toLowerCase() != 'photourl' &&
        candidate.toLowerCase() != 'url') {
      return candidate;
    }

    return (fallback ?? '').trim();
  }

  Future<Map<String, dynamic>?> _findFirstByEmail(
    CollectionReference collection,
    String email,
  ) async {
    final searchTerms = <String>{email.trim(), _normalizeEmail(email)}
      ..removeWhere((value) => value.isEmpty);

    for (final searchTerm in searchTerms) {
      final querySnapshot =
          await collection.where('email', isEqualTo: searchTerm).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        return _asMap(querySnapshot.docs.first.data());
      }
    }

    return null;
  }

  Future<void> addTeacherEmail(String email) async {
    teacherEmailsColl.doc('TeacherEmails').update({
      'emails': FieldValue.arrayUnion([email])
    });
  }

  Future<void> removeTeacherEmail(String email) async {
    teacherEmailsColl.doc('TeacherEmails').update({
      'emails': FieldValue.arrayRemove([email])
    });
  }

  Future<void> updateUserData({
    required String userName,
    required String userType,
    required String usrUid,
    required String email,
    required String photoURL,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    DocumentReference userDoc = userColl.doc(uid);
    await userDoc.set({
      'username': userName,
      'userType': userType,
      'uid': uid,
      'email': normalizedEmail,
      'photoURL': photoURL,
    });

    switch (userType) {
      case 'teacher':
        await teacherColl.doc(uid).set({
          'username': userName,
          'userType': userType,
          'uid': uid,
          'email': normalizedEmail,
          'photoURL': photoURL,
        });
        break;
      case 'student':
        await studentColl.doc(uid).set({
          'username': userName,
          'userType': userType,
          'uid': uid,
          'email': normalizedEmail,
          'photoURL': photoURL,
        });
        break;
    }
  }

  Future<bool> isUserRegistered(String email) async {
    try {
      return await _findFirstByEmail(userColl, email) != null ||
          await _findFirstByEmail(teacherColl, email) != null ||
          await _findFirstByEmail(studentColl, email) != null;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<AttendifyUser?> ensureRegisteredUserProfile({
    required String uid,
    required String email,
    String? fallbackUserName,
    String? fallbackPhotoURL,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    final userSnapshot = await userColl.doc(uid).get();
    if (userSnapshot.exists) {
      final user = _currentUserFromSnapshots(userSnapshot);
      final normalizedUser = AttendifyUser(
        userName: _resolvedUserName(user.userName, fallbackUserName),
        userType: user.userType,
        uid: uid,
        email: normalizedEmail,
        photoURL: _resolvedPhotoUrl(user.photoURL, fallbackPhotoURL),
      );

      await userColl.doc(uid).set({
        'username': normalizedUser.userName,
        'userType': normalizedUser.userType,
        'uid': uid,
        'email': normalizedUser.email,
        'photoURL': normalizedUser.photoURL,
      }, SetOptions(merge: true));

      return normalizedUser;
    }

    final teacherSnapshot = await teacherColl.doc(uid).get();
    if (teacherSnapshot.exists) {
      final teacher = _currentTeacherFromSnapshots(teacherSnapshot);
      final normalizedTeacher = AttendifyUser(
        userName: _resolvedUserName(teacher.userName, fallbackUserName),
        userType: 'teacher',
        uid: uid,
        email: normalizedEmail,
        photoURL: _resolvedPhotoUrl(teacher.photoURL, fallbackPhotoURL),
      );

      await teacherColl.doc(uid).set({
        'username': normalizedTeacher.userName,
        'userType': normalizedTeacher.userType,
        'uid': uid,
        'email': normalizedTeacher.email,
        'photoURL': normalizedTeacher.photoURL,
      }, SetOptions(merge: true));
      await userColl.doc(uid).set({
        'username': normalizedTeacher.userName,
        'userType': normalizedTeacher.userType,
        'uid': uid,
        'email': normalizedTeacher.email,
        'photoURL': normalizedTeacher.photoURL,
      }, SetOptions(merge: true));

      return normalizedTeacher;
    }

    final studentSnapshot = await studentColl.doc(uid).get();
    if (studentSnapshot.exists) {
      final student = _currentStudentFromSnapshots(studentSnapshot);
      final normalizedStudent = AttendifyUser(
        userName: _resolvedUserName(student.userName, fallbackUserName),
        userType: 'student',
        uid: uid,
        email: normalizedEmail,
        photoURL: _resolvedPhotoUrl(student.photoURL, fallbackPhotoURL),
      );

      await studentColl.doc(uid).set({
        'username': normalizedStudent.userName,
        'userType': normalizedStudent.userType,
        'uid': uid,
        'email': normalizedStudent.email,
        'photoURL': normalizedStudent.photoURL,
      }, SetOptions(merge: true));
      await userColl.doc(uid).set({
        'username': normalizedStudent.userName,
        'userType': normalizedStudent.userType,
        'uid': uid,
        'email': normalizedStudent.email,
        'photoURL': normalizedStudent.photoURL,
      }, SetOptions(merge: true));

      return normalizedStudent;
    }

    final teacherByEmail =
        await _findFirstByEmail(teacherColl, normalizedEmail);
    if (teacherByEmail != null) {
      final userName = _resolvedUserName(
          teacherByEmail['username'] as String?, fallbackUserName);
      final photoURL = _resolvedPhotoUrl(
        teacherByEmail['photoURL'] as String?,
        fallbackPhotoURL,
      );
      final modules = (teacherByEmail['modules'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList();

      await teacherColl.doc(uid).set({
        'uid': uid,
        'email': normalizedEmail,
        'username': userName,
        'userType': 'teacher',
        'photoURL': photoURL,
        'modules': modules,
      }, SetOptions(merge: true));
      await userColl.doc(uid).set({
        'username': userName,
        'userType': 'teacher',
        'uid': uid,
        'email': normalizedEmail,
        'photoURL': photoURL,
      }, SetOptions(merge: true));

      return AttendifyUser(
        userName: userName,
        userType: 'teacher',
        uid: uid,
        email: normalizedEmail,
        photoURL: photoURL,
      );
    }

    final studentByEmail =
        await _findFirstByEmail(studentColl, normalizedEmail);
    if (studentByEmail != null) {
      final userName = _resolvedUserName(
          studentByEmail['username'] as String?, fallbackUserName);
      final photoURL = _resolvedPhotoUrl(
        studentByEmail['photoURL'] as String?,
        fallbackPhotoURL,
      );

      await studentColl.doc(uid).set({
        'uid': uid,
        'email': normalizedEmail,
        'username': userName,
        'userType': 'student',
        'photoURL': photoURL,
        'grade': studentByEmail['grade'] as String?,
        'speciality': studentByEmail['speciality'] as String?,
      }, SetOptions(merge: true));
      await userColl.doc(uid).set({
        'username': userName,
        'userType': 'student',
        'uid': uid,
        'email': normalizedEmail,
        'photoURL': photoURL,
      }, SetOptions(merge: true));

      return AttendifyUser(
        userName: userName,
        userType: 'student',
        uid: uid,
        email: normalizedEmail,
        photoURL: photoURL,
      );
    }

    final userByEmail = await _findFirstByEmail(userColl, normalizedEmail);
    if (userByEmail != null) {
      final normalizedUser = AttendifyUser(
        userName: _resolvedUserName(
            userByEmail['username'] as String?, fallbackUserName),
        userType: userByEmail['userType'] as String? ?? 'admin',
        uid: uid,
        email: normalizedEmail,
        photoURL: _resolvedPhotoUrl(
            userByEmail['photoURL'] as String?, fallbackPhotoURL),
      );

      await userColl.doc(uid).set({
        'username': normalizedUser.userName,
        'userType': normalizedUser.userType,
        'uid': uid,
        'email': normalizedUser.email,
        'photoURL': normalizedUser.photoURL,
      }, SetOptions(merge: true));

      return normalizedUser;
    }

    return null;
  }

  Future<void> updateUserSpecificData({
    String? username,
    String? userType,
    String? uid,
    String? email,
    String? photoURL,
  }) async {
    String usrUid = uid ?? _auth.currentUsr!.uid;
    Map<String, String?> map = {
      'username': username,
      'userType': userType,
      'uid': uid,
      'email': email,
      'photoURL': photoURL,
    };
    for (var entry in map.entries) {
      if (entry.value != null) {
        await userColl.doc(usrUid).update({
          entry.key: entry.key == 'email'
              ? _normalizeEmail(entry.value!)
              : entry.value,
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
    final normalizedEmail = _normalizeEmail(email);
    await teacherColl.doc(uid).set(
      {
        'uid': uid,
        'email': normalizedEmail,
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
    Map<String, String?> map = {
      'username': username,
      'userType': userType,
      'uid': uid,
      'email': email,
      'photoURL': photoURL,
    };
    for (var entry in map.entries) {
      if (entry.value != null) {
        await teacherColl.doc(usrUid).update({
          entry.key: entry.key == 'email'
              ? _normalizeEmail(entry.value!)
              : entry.value,
        });
      }
    }

    if (modules != null) {
      await teacherColl.doc(usrUid).update({
        'modules': FieldValue.arrayUnion(modules),
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
    final normalizedEmail = _normalizeEmail(email);
    await studentColl.doc(uid).set(
      {
        'uid': uid,
        'email': normalizedEmail,
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
    Map<String, String?> map = {
      'username': username,
      'userType': userType,
      'uid': uid,
      'email': email,
      'photoURL': photoURL,
      'grade': grade,
      'speciality': speciality,
    };
    for (var entry in map.entries) {
      if (entry.value != null) {
        await studentColl.doc(usrUid).update({
          entry.key: entry.key == 'email'
              ? _normalizeEmail(entry.value!)
              : entry.value,
        });
      }
    }
  }

  Future<void> updateModuleData({
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
          String docUid = doc.get('uid') as String;
          if (docUid.startsWith(uid)) {
            int? currentIndex = int.tryParse(docUid.substring(uid.length));
            if (currentIndex != null && currentIndex >= index) {
              index = currentIndex + 1;
            }
          }
        }
        String finalUid = '$uid$index';
        await modulesColl.doc(finalUid).set({
          'uid': finalUid,
          'name': name,
          'isActive': isActive,
          'speciality': speciality,
          'grade': grade,
          'numberOfStudents': numberOfStudents,
          'students': <dynamic, dynamic>{},
          'attendanceTable': <dynamic, dynamic>{},
        });
      } else {
        await modulesColl.doc(uid).set({
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
        await modulesColl.doc(uid).set({
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

  Future<void> updateModuleSpecificData({
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
        (await moduleDoc.get()).get('students') as Map? ?? {},
      );

      currentStudents[addStudent] = studentName;
      await moduleDoc.update(
        {
          'students': currentStudents,
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
          entry.key: entry.value,
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
          backgroundColor: AttendifyPalette.error,
          dismissDirection: DismissDirection.startToEnd,
          elevation: 20.0,
          content: Text(e.toString()),
          action: SnackBarAction(
            textColor: AttendifyPalette.surfaceMuted,
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
        moduleSnapshot.get('attendanceTable') as Map<String, dynamic>;
    Map<String, int> attendanceData = {};

    if (attendanceTable.isNotEmpty) {
      attendanceTable.forEach((date, data) {
        final attendanceMap = data as Map<dynamic, dynamic>;
        int presentCount =
            attendanceMap.values.where((value) => value == true).length;
        attendanceData[date] = presentCount;
      });
    }
    return attendanceData;
  }

  Future<Map<String, int>> fetchModuleStudentAttendancePercentage(
      String moduleId) async {
    DocumentSnapshot moduleSnapshot = await modulesColl.doc(moduleId).get();
    Map<String, dynamic> attendanceTable =
        moduleSnapshot.get('attendanceTable') as Map<String, dynamic>;
    Map<String, int> studentPresenceCount = {};

    if (attendanceTable.isNotEmpty) {
      attendanceTable.forEach((date, data) {
        final attendanceMap = data as Map<dynamic, dynamic>;
        attendanceMap.forEach((student, isPresent) {
          final String studentId = student as String;
          if (!studentPresenceCount.containsKey(studentId)) {
            studentPresenceCount[studentId] = 0;
          }
          if (isPresent as bool) {
            studentPresenceCount[studentId] =
                studentPresenceCount[studentId]! + 1;
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
    ) as Map<String, dynamic>;
    Map<String, int> attendanceData = {};
    Map<String, double> studentPresenceCount = {};

    if (attendanceTable.isNotEmpty) {
      attendanceTable.forEach(
        (date, data) {
          final attendanceMap = data as Map<dynamic, dynamic>;
          int presentCount =
              attendanceMap.values.where((value) => value == true).length;
          attendanceData[date] = presentCount;

          attendanceMap.forEach(
            (student, isPresent) {
              final String studentId = student as String;
              if (!studentPresenceCount.containsKey(studentId)) {
                studentPresenceCount[studentId] = 0;
              }
              if (isPresent as bool) {
                studentPresenceCount[studentId] =
                    studentPresenceCount[studentId]! + 1;
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
        userName: doc['username'] as String? ?? 'username',
        userType: doc['userType'] as String? ?? 'usertype',
        uid: doc['uid'] as String? ?? 'uid',
        email: doc['email'] as String? ?? 'email',
        photoURL: doc['photoURL'] as String? ?? 'photoURL',
      );
    } else {
      isUserDataExist = false;
      return AttendifyUser(
        userName: 'username',
        userType: 'usertype',
        uid: 'uid',
        email: 'email',
        photoURL: 'photoURL',
      );
    }
  }

  Student _currentStudentFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;
      return Student(
        userName: doc['username'] as String? ?? 'username',
        userType: doc['userType'] as String? ?? 'usertype',
        uid: doc['uid'] as String? ?? 'uid',
        email: doc['email'] as String? ?? 'email',
        photoURL: doc['photoURL'] as String? ?? 'photoURL',
        grade: doc['grade'] as String? ?? 'grade',
        speciality: doc['speciality'] as String? ?? 'speciality',
      );
    } else {
      return Student(
        userName: 'username',
        userType: 'usertype',
        uid: 'uid',
        email: 'email',
        photoURL: 'photoURL',
        grade: 'grade',
        speciality: 'speciality',
      );
    }
  }

  Module _currentModuleFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;

      return Module(
        uid: doc['uid'] as String? ?? 'uid',
        name: doc['name'] as String? ?? 'name',
        speciality: doc['speciality'] as String? ?? 'speciality',
        grade: doc['grade'] as String? ?? 'grade',
        numberOfStudents: doc['numberOfStudents'] as int? ?? 0,
        isActive: doc['isActive'] as bool? ?? false,
        students: Map<String, String>.from(
          doc['students'] as Map? ?? {},
        ),
        attendanceTable: Map<String, dynamic>.from(
          doc['attendanceTable'] as Map? ?? {},
        ),
      );
    } else {
      return Module(
        uid: 'uid',
        name: 'name',
        speciality: 'speciality',
        grade: 'grade',
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

      List<String>? modules = (doc['modules'] as List<dynamic>?)
              ?.map(
                (e) => e.toString(),
              )
              .toList() ??
          [];

      return Teacher(
        userName: doc['username'] as String? ?? 'username',
        userType: doc['userType'] as String? ?? 'usertype',
        uid: doc['uid'] as String? ?? 'uid',
        email: doc['email'] as String? ?? 'email',
        photoURL: doc['photoURL'] as String? ?? 'photoURL',
        modules: modules,
      );
    } else {
      return Teacher(
        userName: 'username',
        userType: 'usertype',
        uid: 'uid',
        email: 'email',
        photoURL: 'photoURL',
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
    studentUIDs = studentUIDs.isNotEmpty ? studentUIDs : ['stuentdUid'];
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
              uid: 'uid',
              name: 'names',
              speciality: 'speciality',
              grade: 'grade',
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
        moduleUIDs.isNotEmpty ? moduleUIDs : ['grade_speciality_module_index'];
    return modulesColl
        .where(FieldPath.documentId, whereIn: moduleUIDs)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Module> modules = [];
      for (var doc in snapshot.docs) {
        Module module = _currentModuleFromSnapshots(doc);
        modules.add(module);
      }
      if (modules.length == 1 && modules[0].uid == 'uid') {
        modules = [];
      }
      return modules;
    });
  }

  Stream<List<Module>> getModulesOfTeacherFromAdmin(
      List<String> moduleUIDs) async* {
    moduleUIDs =
        moduleUIDs.isNotEmpty ? moduleUIDs : ['grade_speciality_module_index'];

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
      await teacherEmailsColl.doc('TeacherEmails').get().then(
          (DocumentSnapshot value) =>
              emails = (value.get('emails') as List<dynamic>).cast<String>());
      return emails;
    } on Exception catch (_) {
      throw Exception('not-authenticated-teacher');
    }
  }

  Future<List<String>> getAllAdminsEmails() async {
    try {
      List<String> emails = [];
      await adminEmailsColl.doc('AdminEmails').get().then(
          (DocumentSnapshot value) =>
              emails = (value.get('emails') as List<dynamic>).cast<String>());
      return emails;
    } on Exception catch (_) {
      throw Exception('not-authenticated-admin');
    }
  }

  Stream<List<Module>> getAllModulesStream() {
    return modulesColl.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => _currentModuleFromSnapshots(doc))
          .toList(),
    );
  }

  Stream<List<Student>> getAllStudentsStream() {
    return studentColl.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => _currentStudentFromSnapshots(doc))
          .toList(),
    );
  }

  Stream<Map<String, dynamic>> getAllTeachersAndEmailsStream() async* {
    final teacherStream = teacherColl.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => _currentTeacherFromSnapshots(doc))
          .toList(),
    );

    // We combine mathe two streams. Whenever either updates, we emit a new map.
    await for (final teachers in teacherStream) {
      // This is a simplified combine. In a real app, we'd use RxDart combineLatest.
      // Since we want to avoid adding dependencies, we'll fetch the latest email
      // value when teachers update, or use a separate listener.
      final emailsSnapshot = await teacherEmailsColl.doc('TeacherEmails').get();
      final emails = emailsSnapshot.exists
          ? (emailsSnapshot.get('emails') as List<dynamic>).cast<String>()
          : <String>[];

      yield {
        'teachers': teachers,
        'emails': emails,
      };
    }
  }

  Future<bool> isTeacherEmailRegistered(String email) async {
    try {
      List<String> allTeacherEmails = await getAllTeachersEmails();
      return allTeacherEmails.contains(email);
    } catch (e) {
      throw Exception('Database error: $e');
    }
  }

  Future<bool> isAdminEmailRegistered(String email) async {
    try {
      List<String> allAdminEmails = await getAllAdminsEmails();
      return allAdminEmails.contains(email);
    } catch (e) {
      throw Exception('Database error: $e');
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
