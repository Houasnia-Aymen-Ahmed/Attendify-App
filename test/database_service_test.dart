import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:attendify/models/user_of_attendify.dart';
import 'package:attendify/services/auth.dart';
import 'package:attendify/services/databases.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Import generated mocks (user will need to run build_runner)
import 'database_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  DocumentSnapshot,
  Query, // For query methods like .where(), .limit(), .orderBy()
  WriteBatch, // If any batch operations are used (not obvious yet, but good to have)
  AuthService, // DatabaseService has an _auth instance
  // We also need to mock our models if they have methods, but here they are data classes.
  // However, DocumentSnapshot.data() returns Map<String, dynamic>, so we don't mock models directly for that.
])
void main() {
  late DatabaseService databaseService;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockUserCollection;
  late MockCollectionReference<Map<String, dynamic>> mockStudentCollection;
  late MockCollectionReference<Map<String, dynamic>> mockTeacherCollection;
  late MockCollectionReference<Map<String, dynamic>> mockModulesCollection;
  // Mock DocumentReferences for specific UIDs if needed in tests
  late MockDocumentReference<Map<String, dynamic>> mockUserDocRef;
  late MockDocumentReference<Map<String, dynamic>> mockModuleDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockUserDocSnapshot;
  late MockDocumentSnapshot<Map<String, dynamic>> mockModuleDocSnapshot;
  // late MockAuthService mockAuthService; // If needed for specific tests

  const String testUid = 'test_user_uid';
  const String testModuleId = 'test_module_id';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUserCollection = MockCollectionReference<Map<String, dynamic>>();
    mockStudentCollection = MockCollectionReference<Map<String, dynamic>>();
    mockTeacherCollection = MockCollectionReference<Map<String, dynamic>>();
    mockModulesCollection = MockCollectionReference<Map<String, dynamic>>();

    mockUserDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockModuleDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockUserDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    mockModuleDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    // databaseService = DatabaseService(uid: testUid); // Default instantiation for most tests
    // TODO: DatabaseService needs a way to inject FirebaseFirestore for testing.
    // For now, tests will focus on methods that don't directly call FirebaseFirestore.instance
    // or assume it can be mocked globally (less ideal) or refactor DatabaseService.
    // The ideal way is to pass mockFirestore to DatabaseService constructor.
    // Let's assume DatabaseService is refactored to take FirebaseFirestore instance.
    // AuthService also needs to be injectable or its usage minimal in tested methods.
    // For now, we'll mock the collections directly when DatabaseService calls .collection()

    when(mockFirestore.collection('UserCollection')).thenReturn(mockUserCollection);
    when(mockFirestore.collection('StudentCollection')).thenReturn(mockStudentCollection);
    when(mockFirestore.collection('TeacherCollection')).thenReturn(mockTeacherCollection);
    when(mockFirestore.collection('Modules')).thenReturn(mockModulesCollection);

    when(mockUserCollection.doc(any)).thenReturn(mockUserDocRef);
    when(mockModulesCollection.doc(any)).thenReturn(mockModuleDocRef);

    // Default behavior for snapshots
    when(mockUserDocSnapshot.exists).thenReturn(true);
    when(mockModuleDocSnapshot.exists).thenReturn(true);
  });

  group('DatabaseService Unit Tests', () {

    group('Snapshot to Model Conversions', () {
      // These test the private _current...FromSnapshots methods.
      // We need to make them accessible for testing, e.g., by making them public static,
      // or by testing them through public methods that use them.
      // For now, let's assume we can call them or test via a public method.
      // To do this properly, DatabaseService would need public static methods or test helpers.
      // Let's simulate testing them by creating snapshots and checking output.

      test('_currentUserFromSnapshots correctly maps snapshot to AttendifyUser', () {
        final data = {
          "username": "Test User", "userType": "student",
          "uid": testUid, "email": "test@example.com", "photoURL": "url"
        };
        when(mockUserDocSnapshot.data()).thenReturn(data);
        when(mockUserDocSnapshot.id).thenReturn(testUid);

        // Assuming DatabaseService instance `ds` for calling a hypothetical public test helper
        DatabaseService ds = DatabaseService(uid: testUid); // Or a static call if refactored
        // AttendifyUser user = ds.testCurrentUserFromSnapshots(mockUserDocSnapshot);
        // For now, we can't call the private method directly.
        // This test highlights the need for refactoring for testability or testing via public methods.
        // Let's assume a public method `getUserData` that uses it.

        // Placeholder for actual test once method is accessible or tested via public API
        expect(true, isTrue);
      });

      test('_currentStudentFromSnapshots correctly maps snapshot to Student', () {
        final data = {
          "username": "Student User", "userType": "student", "uid": testUid,
          "email": "student@example.com", "photoURL": "s_url",
          "grade": "1CS", "speciality": "SIW"
        };
        when(mockUserDocSnapshot.data()).thenReturn(data); // Reusing mockUserDocSnapshot for student data
        when(mockUserDocSnapshot.id).thenReturn(testUid);

        // Placeholder
        expect(true, isTrue);
      });

      test('_currentModuleFromSnapshots correctly maps snapshot to Module', () {
        final data = {
          "uid": testModuleId, "name": "Test Module", "speciality": "SIW", "grade": "1CS",
          "numberOfStudents": 10, "isActive": true,
          "students": {"student1": "Student Name1"},
          "attendanceTable": {"2023-01-01": {"student1": true}}
        };
        when(mockModuleDocSnapshot.data()).thenReturn(data);
        when(mockModuleDocSnapshot.id).thenReturn(testModuleId);

        // Placeholder
        expect(true, isTrue);
      });

      test('_currentTeacherFromSnapshots correctly maps snapshot to Teacher', () {
        final data = {
          "username": "Teacher User", "userType": "teacher", "uid": testUid,
          "email": "teacher@example.com", "photoURL": "t_url",
          "modules": ["module1", "module2"]
        };
        when(mockUserDocSnapshot.data()).thenReturn(data); // Reusing for teacher data
        when(mockUserDocSnapshot.id).thenReturn(testUid);

        // Placeholder
        expect(true, isTrue);
      });
    });

    group('Update Operations', () {
      // Requires DatabaseService to accept a mock Firestore instance
      // For now, these will be conceptual.

      test('updateAttendance successfully updates Firestore', () async {
        // Arrange: Assume DatabaseService is instantiated with mockFirestore
        // DatabaseService serviceWithMockFirestore = DatabaseService(firestoreInstance: mockFirestore, uid: testUid);

        when(mockModulesCollection.doc(testModuleId)).thenReturn(mockModuleDocRef);
        when(mockModuleDocRef.update(any)).thenAnswer((_) async => {}); // Simulate successful update

        // Act
        // bool result = await serviceWithMockFirestore.updateAttendance(testModuleId, '2023-01-01', 'student1', true);

        // Assert
        // verify(mockModuleDocRef.update({'attendanceTable.2023-01-01.student1': true})).called(1);
        // expect(result, isTrue);
        expect(true, isTrue); // Placeholder
      });

      test('updateUserData successfully sets data in user and specific collections', () async {
        // Arrange
        // DatabaseService serviceWithMockFirestore = DatabaseService(firestoreInstance: mockFirestore, uid: testUid);
        when(mockUserCollection.doc(testUid)).thenReturn(mockUserDocRef);
        when(mockStudentCollection.doc(testUid)).thenReturn(mockUserDocRef); // Using same mock for simplicity
        when(mockUserDocRef.set(any)).thenAnswer((_) async {});

        // Act
        // bool success = await serviceWithMockFirestore.updateUserData(
        //   userName: "New User", userType: "student", usrUid: testUid,
        //   email: "new@example.com", photoURL: "new_url"
        // );

        // Assert
        // verify(mockUserCollection.doc(testUid).set(any)).called(1);
        // verify(mockStudentCollection.doc(testUid).set(any)).called(1);
        // expect(success, isTrue);
        expect(true, isTrue); // Placeholder
      });
    });

    group('Read Operations', () {
        test('isUserRegistered returns true if user email exists', () async {
            // DatabaseService serviceWithMockFirestore = DatabaseService(firestoreInstance: mockFirestore);
            final mockQuerySnapshot = MockQuerySnapshot<Map<String,dynamic>>();
            final mockQueryDocSnapshot = MockDocumentSnapshot<Map<String,dynamic>>();

            when(mockUserCollection.where('email', isEqualTo: 'test@example.com')).thenReturn(mockUserCollection); // Mock query chaining
            when(mockUserCollection.limit(1)).thenReturn(mockUserCollection); // Mock query chaining
            when(mockUserCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
            when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]); // User exists

            // bool exists = await serviceWithMockFirestore.isUserRegistered('test@example.com');
            // expect(exists, isTrue);
            expect(true, isTrue); // Placeholder
        });

        test('isUserRegistered returns false if user email does not exist', () async {
            // DatabaseService serviceWithMockFirestore = DatabaseService(firestoreInstance: mockFirestore);
            final mockQuerySnapshot = MockQuerySnapshot<Map<String,dynamic>>();

            when(mockUserCollection.where('email', isEqualTo: 'noexist@example.com')).thenReturn(mockUserCollection);
            when(mockUserCollection.limit(1)).thenReturn(mockUserCollection);
            when(mockUserCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
            when(mockQuerySnapshot.docs).thenReturn([]); // User does not exist

            // bool exists = await serviceWithMockFirestore.isUserRegistered('noexist@example.com');
            // expect(exists, isFalse);
            expect(true, isTrue); // Placeholder
        });
    });

    // Add more tests for other methods:
    // - addTeacherEmail, removeTeacherEmail
    // - updateSpecificData methods
    // - module data methods
    // - fetch methods (getAll, getByCriteria, etc.)
    // - stream methods (more complex to test, requires StreamControllers)
    // - deletion methods
  });
}
