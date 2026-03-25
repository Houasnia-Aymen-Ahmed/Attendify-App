import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';

import '../models/attendify_student.dart';
import '../models/attendify_teacher.dart';
import '../models/module_model.dart';
import '../models/user_of_attendify.dart';
// import 'auth.dart'; // AuthService instance removed, not used directly in this refactored version.

class DatabaseService {
  final String? uid; // UID of the current user, if relevant for the instance context

  // These flags' utility is questionable and they are not used in the refactored methods.
  // Consider removing them.
  // bool isUserDataExist = true;
  // bool isModuleDataExist = true;

  final FirebaseFirestore _firestore; // For testability

  DatabaseService({this.uid, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;


  // Collection References using the injected _firestore instance
  CollectionReference get teacherEmailsColl =>
      _firestore.collection("TeacherEmailsCollection");
  CollectionReference get adminEmailsColl =>
      _firestore.collection("AdminEmailsCollection");
  CollectionReference get userColl =>
      _firestore.collection("UserCollection");
  CollectionReference get teacherColl =>
      _firestore.collection("TeacherCollection");
  CollectionReference get studentColl =>
      _firestore.collection("StudentCollection");
  CollectionReference get modulesColl =>
      _firestore.collection("Modules");

  // Private helper method for updating document data
  Future<bool> _updateDocumentData(DocumentReference docRef, Map<String, dynamic> data) async {
    try {
      if (data.isEmpty) { // No actual data to update
        return true; // Or false if this is considered an issue. For now, true as nothing failed.
      }
      await docRef.update(data);
      return true;
    } catch (e) {
      log("Error updating document ${docRef.path}: $e");
      return false;
    }
  }

  Future<void> addTeacherEmail(String email) async {
    try {
      await teacherEmailsColl.doc("TeacherEmails").update({
        'emails': FieldValue.arrayUnion([email])
      });
    } catch (e) {
      log("Error in addTeacherEmail: $e");
    }
  }

  Future<void> removeTeacherEmail(String email) async {
    try {
      await teacherEmailsColl.doc("TeacherEmails").update({
        'emails': FieldValue.arrayRemove([email])
      });
    } catch (e) {
      log("Error in removeTeacherEmail: $e");
    }
  }

  Future<bool> updateUserData({
    required String userName,
    required String userType,
    required String targetUid,
    required String email,
    required String photoURL,
  }) async {
    try {
      if (targetUid.isEmpty) {
        log("Error in updateUserData: targetUid is null or empty.");
        return false;
      }

      DocumentReference userDoc = userColl.doc(targetUid);
      await userDoc.set({
        'username': userName, 'userType': userType, 'uid': targetUid,
        'email': email, 'photoURL': photoURL,
      });

      switch (userType.toLowerCase()) {
        case "teacher":
          await teacherColl.doc(targetUid).set({
            'username': userName, 'userType': userType, 'uid': targetUid,
            'email': email, 'photoURL': photoURL,
          });
          break;
        case "student":
          await studentColl.doc(targetUid).set({
            'username': userName, 'userType': userType, 'uid': targetUid,
            'email': email, 'photoURL': photoURL,
          });
          break;
      }
      return true;
    } catch (e) {
      log("Error in updateUserData for uid $targetUid: $e");
      return false;
    }
  }

  Future<bool> isUserRegistered(String email) async {
    try {
      QuerySnapshot querySnapshot = await userColl
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error in isUserRegistered for email $email: $e");
      return false;
    }
  }

  Future<bool> updateUserSpecificData({
    required String targetUid,
    String? username,
    String? userType,
    String? email,
    String? photoURL,
  }) async {
    try {
      if (targetUid.isEmpty) {
        log("Error in updateUserSpecificData: targetUid is empty.");
        return false;
      }
      Map<String, dynamic> dataToUpdate = {};
      if (username != null) dataToUpdate['username'] = username;
      if (userType != null) dataToUpdate['userType'] = userType;
      if (email != null) dataToUpdate['email'] = email;
      if (photoURL != null) dataToUpdate['photoURL'] = photoURL;

      return await _updateDocumentData(userColl.doc(targetUid), dataToUpdate);
    } catch (e) { // Should be caught by _updateDocumentData, but as a fallback.
      log("Error in updateUserSpecificData for uid $targetUid: $e");
      return false;
    }
  }

  Future<bool> updateTeacherData({
    required String userName,
    required String userType,
    required String uid,
    required String email,
    required String photoURL,
    List<String>? modules,
  }) async {
    try {
      await teacherColl.doc(uid).set({
        'uid': uid, 'email': email, 'username': userName,
        'userType': userType, 'photoURL': photoURL, 'modules': modules ?? [],
      });
      return true;
    } catch (e) {
      log("Error in updateTeacherData for uid $uid: $e");
      return false;
    }
  }

  Future<bool> updateTeacherSpecificData({
    required String targetUid,
    String? username,
    String? email,
    String? photoURL,
    List<String>? modules,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {};
      if (username != null) dataToUpdate['username'] = username;
      if (email != null) dataToUpdate['email'] = email;
      if (photoURL != null) dataToUpdate['photoURL'] = photoURL;

      bool mainDataUpdated = await _updateDocumentData(teacherColl.doc(targetUid), dataToUpdate);
      if (!mainDataUpdated && dataToUpdate.isNotEmpty) return false; // Stop if initial update failed

      if (modules != null && modules.isNotEmpty) {
        await teacherColl.doc(targetUid).update({
          "modules": FieldValue.arrayUnion(modules),
        });
      }
      return true;
    } catch (e) {
      log("Error in updateTeacherSpecificData for uid $targetUid: $e");
      return false;
    }
  }

  Future<bool> updateStudentData({
    required String userName,
    required String userType,
    required String uid,
    required String email,
    required String photoURL,
    String? grade,
    String? speciality,
  }) async {
    try {
      await studentColl.doc(uid).set({
        'uid': uid, 'email': email, 'username': userName,
        'userType': userType, 'photoURL': photoURL,
        'grade': grade, 'speciality': speciality,
      });
      return true;
    } catch (e) {
      log("Error in updateStudentData for uid $uid: $e");
      return false;
    }
  }

  Future<bool> updateStudentSpecificData({
    required String targetUid,
    String? username,
    String? email,
    String? photoURL,
    String? grade,
    String? speciality,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {};
      if (username != null) dataToUpdate['username'] = username;
      if (email != null) dataToUpdate['email'] = email;
      if (photoURL != null) dataToUpdate['photoURL'] = photoURL;
      if (grade != null) dataToUpdate['grade'] = grade;
      if (speciality != null) dataToUpdate['speciality'] = speciality;

      return await _updateDocumentData(studentColl.doc(targetUid), dataToUpdate);
    } catch (e) {
      log("Error in updateStudentSpecificData for uid $targetUid: $e");
      return false;
    }
  }

  Future<String?> updateModuleData({
    required String uidSeed,
    required String name,
    required bool isActive,
    required String speciality,
    required String grade,
    bool isNewModule = false,
  }) async {
    try {
      String targetUid = uidSeed;
      Map<String,dynamic> modulePayload = {
        'name': name, 'isActive': isActive, 'speciality': speciality, 'grade': grade,
        'numberOfStudents': 0,
        'students': {}, 'attendanceTable': {},
      };

      if (isNewModule) {
        int index = 0;
        QuerySnapshot querySnapshot = await modulesColl
            .where('uid', isGreaterThanOrEqualTo: uidSeed)
            .orderBy('uid', descending: true)
            .limit(1)
            .get();
        for (var doc in querySnapshot.docs) {
          String docUid = doc.get('uid') as String;
          if (docUid.startsWith(uidSeed)) {
            int? currentIndex = int.tryParse(docUid.substring(uidSeed.length));
            if (currentIndex != null && currentIndex >= index) {
              index = currentIndex + 1;
            }
          }
        }
        targetUid = '$uidSeed$index';
        modulePayload['uid'] = targetUid;
        await modulesColl.doc(targetUid).set(modulePayload);
        return targetUid;
      } else {
        modulePayload['uid'] = targetUid;
        await modulesColl.doc(targetUid).set(modulePayload);
        return targetUid;
      }
    } catch (e) {
      log("Error in updateModuleData for seed_uid $uidSeed: $e");
      return null;
    }
  }

  Future<bool> updateModuleSpecificData({
    required String uid,
    String? name,
    bool? isActive,
    String? speciality,
    String? grade,
    String? addStudentUid,
    String? studentName,
    String? removeStudentUid,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {};
      if (name != null) dataToUpdate['name'] = name;
      if (isActive != null) dataToUpdate['isActive'] = isActive;
      if (speciality != null) dataToUpdate['speciality'] = speciality;
      if (grade != null) dataToUpdate['grade'] = grade;

      DocumentReference moduleDoc = modulesColl.doc(uid);

      if (addStudentUid != null && studentName != null) {
        dataToUpdate['students.$addStudentUid'] = studentName;
        dataToUpdate['numberOfStudents'] = FieldValue.increment(1);
      }
      if (removeStudentUid != null) {
        dataToUpdate['students.$removeStudentUid'] = FieldValue.delete();
        dataToUpdate['numberOfStudents'] = FieldValue.increment(-1);
      }

      // Only call update if there's something to update, to avoid unnecessary writes
      // or errors if dataToUpdate is empty for FieldValue operations.
      if (dataToUpdate.keys.any((k) => !k.startsWith('students.') && !k.startsWith('numberOfStudents'))) {
         // Contains main field updates
         await moduleDoc.update(Map.fromEntries(dataToUpdate.entries.where((e) => !e.key.startsWith('students.') && e.key != 'numberOfStudents')));
      }
      // Handle student and numberOfStudents updates separately if they exist
      Map<String, dynamic> studentUpdates = Map.fromEntries(dataToUpdate.entries.where((e) => e.key.startsWith('students.') || e.key == 'numberOfStudents'));
      if(studentUpdates.isNotEmpty) {
        await moduleDoc.update(studentUpdates);
      }

      return true;
    } catch (e) {
      log("Error in updateModuleSpecificData for module uid $uid: $e");
      return false;
    }
  }

  Future<bool> updateAttendance(
    String moduleID,
    String date,
    String studentID,
    bool isPresent,
  ) async {
    try {
      await modulesColl.doc(moduleID).update({
        'attendanceTable.$date.$studentID': isPresent,
      });
      return true;
    } catch (e) {
      log("Error in updateAttendance for module $moduleID, student $studentID, date $date: $e");
      return false;
    }
  }

  Future<bool> addToAttendanceTable(
    String moduleID,
    Map<String, dynamic> newAttendanceSession,
  ) async {
    try {
      await modulesColl.doc(moduleID).set(
        {'attendanceTable': newAttendanceSession},
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      log("Error in addToAttendanceTable for module $moduleID: $e");
      return false;
    }
  }

  Future<Map<String, int>> fetchModuleAttendanceData(String moduleId) async {
    try {
      DocumentSnapshot moduleSnapshot = await modulesColl.doc(moduleId).get();
      if (!moduleSnapshot.exists) return {};
      Map<String, dynamic> data = moduleSnapshot.data() as Map<String, dynamic>? ?? {};
      Map<String, dynamic> attendanceTable = data['attendanceTable'] as Map<String, dynamic>? ?? {};
      Map<String, int> attendanceData = {};

      attendanceTable.forEach((date, dateAttendance) {
        if (dateAttendance is Map) {
          int presentCount = dateAttendance.values.where((value) => value == true).length;
          attendanceData[date] = presentCount;
        }
      });
      return attendanceData;
    } catch (e) {
      log("Error in fetchModuleAttendanceData for module $moduleId: $e");
      return {};
    }
  }

  Future<Map<String, int>> fetchModuleStudentAttendancePercentage(
      String moduleId) async {
    try {
      DocumentSnapshot moduleSnapshot = await modulesColl.doc(moduleId).get();
      if (!moduleSnapshot.exists) return {};
      Map<String, dynamic> data = moduleSnapshot.data() as Map<String, dynamic>? ?? {};
      Map<String, dynamic> attendanceTable = data['attendanceTable'] as Map<String, dynamic>? ?? {};
      Map<String, int> studentPresenceCount = {};

      attendanceTable.forEach((date, dateData) {
        if (dateData is Map) {
          dateData.forEach((student, isPresent) {
            if (isPresent is bool) {
              studentPresenceCount.putIfAbsent(student as String, () => 0);
              if (isPresent) {
                studentPresenceCount[student as String] = studentPresenceCount[student]! + 1;
              }
            }
          });
        }
      });
      return studentPresenceCount;
    } catch (e) {
      log("Error in fetchModuleStudentAttendancePercentage for $moduleId: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchModuleStats(String moduleId) async {
    try {
      DocumentSnapshot moduleSnapshot = await modulesColl.doc(moduleId).get();
       if (!moduleSnapshot.exists || moduleSnapshot.data() == null) {
        return {'attendanceData': {}, 'studentPresenceCount': {}};
      }
      Map<String, dynamic> moduleData = moduleSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> attendanceTable = moduleData['attendanceTable'] as Map<String, dynamic>? ?? {};

      Map<String, int> attendanceData = {};
      Map<String, double> studentPercentages = {};
      Map<String, int> studentRawPresenceCount = {};

      if (attendanceTable.isNotEmpty) {
        attendanceTable.forEach((date, dailyAttendance) {
          if (dailyAttendance is Map) {
            int presentCount = 0;
            dailyAttendance.forEach((studentId, isPresent) {
              if (isPresent == true) {
                presentCount++;
                studentRawPresenceCount[studentId as String] = (studentRawPresenceCount[studentId] ?? 0) + 1;
              } else {
                 studentRawPresenceCount.putIfAbsent(studentId as String, () => 0);
              }
            });
            attendanceData[date] = presentCount;
          }
        });

        int totalDates = attendanceTable.length;
        if (totalDates > 0) {
          studentRawPresenceCount.forEach((studentId, presenceCount) {
            studentPercentages[studentId] = (presenceCount / totalDates) * 100.0;
          });
        }
      }
      return {
        'attendanceData': attendanceData,
        'studentPresenceCount': studentPercentages,
      };
    } catch (e) {
      log("Error in fetchModuleStats for $moduleId: $e");
      return {'attendanceData': {}, 'studentPresenceCount': {}};
    }
  }

  Future<List<Module>> getModulesByGradeAndSpeciality(
      String grade, String speciality) async {
    try {
      QuerySnapshot querySnapshot = await modulesColl
          .where('grade', isEqualTo: grade)
          .where('speciality', isEqualTo: speciality)
          .get();
      return querySnapshot.docs.map((doc) => _currentModuleFromSnapshots(doc)).toList();
    } catch (e) {
      log("Error in getModulesByGradeAndSpeciality for $grade, $speciality: $e");
      return [];
    }
  }

  Future<bool> updateModulesWithCriteria({
    required String grade,
    required String speciality,
    required String studentUID,
    required String studentName,
  }) async {
    try {
      QuerySnapshot querySnapshot = await modulesColl
          .where('grade', isEqualTo: grade)
          .where('speciality', isEqualTo: speciality)
          .get();

      for (var doc in querySnapshot.docs) {
        await updateModuleSpecificData(
          uid: doc.id,
          addStudentUid: studentUID,
          studentName: studentName,
        );
      }
      return true;
    } catch (e) {
      log("Error in updateModulesWithCriteria: $e");
      return false;
    }
  }

  AttendifyUser _currentUserFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;
      return AttendifyUser(
        userName: doc["username"] ?? 'N/A',
        userType: doc["userType"] ?? "unknown",
        uid: doc["uid"] ?? snapshot.id,
        email: doc["email"] ?? "N/A",
        photoURL: doc["photoURL"] ?? "",
      );
    } else {
      log("User snapshot does not exist or data is null for ID: ${snapshot.id}");
      return AttendifyUser(userName: 'N/A', userType: "unknown", uid: snapshot.id, email: "N/A", photoURL: "");
    }
  }

  Student _currentStudentFromSnapshots(DocumentSnapshot snapshot) {
     if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;
      return Student(
        userName: doc["username"] ?? 'N/A', userType: doc["userType"] ?? "student",
        uid: doc["uid"] ?? snapshot.id, email: doc["email"] ?? "N/A",
        photoURL: doc["photoURL"] ?? "", grade: doc["grade"] ?? 'N/A',
        speciality: doc["speciality"] ?? 'N/A',
      );
    } else {
      log("Student snapshot does not exist or data is null for ID: ${snapshot.id}");
      return Student(userName: 'N/A', userType: "student", uid: snapshot.id, email: "N/A", photoURL: "", grade: "N/A", speciality: "N/A");
    }
  }

  Module _currentModuleFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;
      return Module(
        uid: doc["uid"] ?? snapshot.id, name: doc["name"] ?? 'N/A',
        speciality: doc["speciality"] ?? 'N/A', grade: doc["grade"] ?? "N/A",
        numberOfStudents: doc["numberOfStudents"] ?? 0,
        isActive: doc["isActive"] ?? false,
        students: Map<String, String>.from(doc["students"] ?? {}),
        attendanceTable: Map<String, dynamic>.from(doc["attendanceTable"] ?? {}),
      );
    } else {
      log("Module snapshot does not exist or data is null for ID: ${snapshot.id}");
      return Module(uid: snapshot.id, name: "N/A", speciality: "N/A", grade: "N/A", numberOfStudents: 0, isActive: false, students: {}, attendanceTable: {});
    }
  }

  Teacher _currentTeacherFromSnapshots(DocumentSnapshot snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> doc = snapshot.data() as Map<String, dynamic>;
      List<String> modules = (doc["modules"] as List<dynamic>?)
                              ?.map((e) => e.toString())
                              .toList() ?? [];
      return Teacher(
        userName: doc["username"] ?? 'N/A', userType: doc["userType"] ?? "teacher",
        uid: doc["uid"] ?? snapshot.id, email: doc["email"] ?? "N/A",
        photoURL: doc["photoURL"] ?? "", modules: modules,
      );
    } else {
       log("Teacher snapshot does not exist or data is null for ID: ${snapshot.id}");
      return Teacher(userName: 'N/A', userType: "teacher", uid: snapshot.id, email: "N/A", photoURL: "", modules: []);
    }
  }

  Stream<Teacher> getTeacherDataStream(String teacherId) {
    return teacherColl.doc(teacherId).snapshots().map(_currentTeacherFromSnapshots);
  }
  Stream<AttendifyUser> getUserDataStream(String userId) {
    return userColl.doc(userId).snapshots().map(_currentUserFromSnapshots);
  }
  Stream<Student> getStudentDataStream(String userId) {
    return studentColl.doc(userId).snapshots().map(_currentStudentFromSnapshots);
  }

  Stream<List<Student>> getStudentsList(List<String> studentUIDs) {
    if (studentUIDs.isEmpty) return Stream.value([]);
    return studentColl
        .where(FieldPath.documentId, whereIn: studentUIDs)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_currentStudentFromSnapshots).toList())
        .handleError((error) {
          log("Error in getStudentsList stream: $error");
          return <Student>[];
        });
  }

  Stream<Module> getModuleStream(String moduleId) {
    return modulesColl.doc(moduleId).snapshots().map(_currentModuleFromSnapshots);
  }

  Stream<List<Module>> getModuleByGradeSpecialityStream(String grade, String speciality) {
    return modulesColl
        .where('grade', isEqualTo: grade)
        .where('speciality', isEqualTo: speciality)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.map(_currentModuleFromSnapshots).toList();
          } else {
            return <Module>[];
          }
        })
        .handleError((error) {
          log("Error in getModuleByGradeSpecialityStream: $error");
          return <Module>[];
        });
  }

  Stream<List<Module>> getModuleDataListStream(String moduleID) {
    return modulesColl.doc(moduleID).snapshots().map(
      (snapshot) => [if(snapshot.exists) _currentModuleFromSnapshots(snapshot)]
    ).handleError((error) {
      log("Error in getModuleDataListStream for $moduleID: $error");
      return <Module>[];
    });
  }

  Stream<List<Module>> getModulesOfTeacher(List<String> moduleUIDs) {
    if (moduleUIDs.isEmpty) return Stream.value([]);
    return modulesColl
        .where(FieldPath.documentId, whereIn: moduleUIDs)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(_currentModuleFromSnapshots).toList();
        })
        .handleError((error) {
          log("Error in getModulesOfTeacher stream: $error");
          return <Module>[];
        });
  }

  Stream<List<Module>> getModulesOfTeacherFromAdmin(List<String> moduleUIDs) {
    if (moduleUIDs.isEmpty) return Stream.value([]);

    List<Stream<List<Module>>> streams = [];
    for (var i = 0; i < moduleUIDs.length; i += 30) {
      var end = (i + 30 < moduleUIDs.length) ? i + 30 : moduleUIDs.length;
      var slice = moduleUIDs.sublist(i, end);

      streams.add(
        modulesColl.where(FieldPath.documentId, whereIn: slice).snapshots().map(
          (snapshot) => snapshot.docs.map(_currentModuleFromSnapshots).toList(),
        ).handleError((error) {
           log("Error in getModulesOfTeacherFromAdmin sub-stream: $error");
           return <Module>[];
        }),
      );
    }
    return StreamGroup.merge(streams);
  }

  Future<bool> removeTeacherById(String id) async {
    try { await teacherColl.doc(id).delete(); return true; }
    catch (e) { log("Error removing teacher $id: $e"); return false; }
  }
  Future<bool> removeStudentById(String id) async {
    try { await studentColl.doc(id).delete(); return true; }
    catch (e) { log("Error removing student $id: $e"); return false; }
  }
  Future<bool> removeModuleById(String id) async {
    try { await modulesColl.doc(id).delete(); return true; }
    catch (e) { log("Error removing module $id: $e"); return false; }
  }

  Future<List<Module>> getAllModules() async {
    try { QuerySnapshot querySnapshot = await modulesColl.get();
      return querySnapshot.docs.map(_currentModuleFromSnapshots).toList();
    } catch (e) { log("Error in getAllModules: $e"); return [];}
  }
  Future<List<Student>> getAllStudents() async {
    try { QuerySnapshot querySnapshot = await studentColl.get();
      return querySnapshot.docs.map(_currentStudentFromSnapshots).toList();
    } catch (e) { log("Error in getAllStudents: $e"); return [];}
  }
  Future<List<Teacher>> getAllTeachers() async {
    try { QuerySnapshot querySnapshot = await teacherColl.get();
      return querySnapshot.docs.map(_currentTeacherFromSnapshots).toList();
    } catch (e) { log("Error in getAllTeachers: $e"); return [];}
  }

  Future<List<String>> getAllTeachersEmails() async {
    try {
      DocumentSnapshot snapshot = await teacherEmailsColl.doc("TeacherEmails").get();
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return List<String>.from(data['emails'] as List<dynamic>? ?? []);
      }
      return [];
    } catch (e) {
      log("Error in getAllTeachersEmails: $e");
      return [];
    }
  }

  Future<List<String>> getAllAdminsEmails() async {
     try {
      DocumentSnapshot snapshot = await adminEmailsColl.doc("AdminEmails").get();
      if (snapshot.exists && snapshot.data() != null) {
         Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return List<String>.from(data['emails'] as List<dynamic>? ?? []);
      }
      return [];
    } catch (e) {
      log("Error in getAllAdminsEmails: $e");
      return [];
    }
  }

  Future<bool> isTeacherEmailRegistered(String email) async {
    try {
      List<String> allTeacherEmails = await getAllTeachersEmails();
      return allTeacherEmails.contains(email);
    } catch (e) {
      log("Error in isTeacherEmailRegistered for $email: $e");
      return false;
    }
  }

  Future<bool> isAdminEmailRegistered(String email) async {
    try {
      List<String> allAdminEmails = await getAllAdminsEmails();
      return allAdminEmails.contains(email);
    } catch (e) {
      log("Error in isAdminEmailRegistered for $email: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getAllTeachersAndEmails() async {
    try {
      final List<Teacher> teachers = await getAllTeachers();
      final List<String> emails = await getAllTeachersEmails();
      return {'teachers': teachers, 'emails': emails};
    } catch (e) {
      log("Error in getAllTeachersAndEmails: $e");
      return {'teachers': [], 'emails': []};
    }
  }
}
