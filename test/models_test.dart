import 'package:attendify/models/attendify_student.dart';
import 'package:attendify/models/attendify_teacher.dart';
import 'package:attendify/models/module_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Models Tests', () {
    group('Student Model', () {
      test('should create a Student from JSON', () {
        final json = {
          'uid': '123',
          'email': 'student@test.com',
          'userName': 'Test Student',
          'userType': 'student',
          'photoURL': 'http://photo.com',
          'grade': '1st',
          'speciality': 'CS',
        };

        final student = Student.fromJson(json);

        expect(student.uid, '123');
        expect(student.email, 'student@test.com');
        expect(student.userName, 'Test Student');
        expect(student.userType, 'student');
        expect(student.photoURL, 'http://photo.com');
        expect(student.grade, '1st');
        expect(student.speciality, 'CS');
      });
    });

    group('Teacher Model', () {
      test('should create a Teacher from JSON', () {
        final json = {
          'uid': '456',
          'email': 'teacher@test.com',
          'userName': 'Test Teacher',
          'userType': 'teacher',
          'photoURL': 'http://photo.com',
          'modules': ['Math', 'Physics'],
        };

        final teacher = Teacher.fromJson(json);

        expect(teacher.uid, '456');
        expect(teacher.email, 'teacher@test.com');
        expect(teacher.userName, 'Test Teacher');
        expect(teacher.userType, 'teacher');
        expect(teacher.photoURL, 'http://photo.com');
        expect(teacher.modules, containsAll(['Math', 'Physics']));
      });
    });

    group('Module Model', () {
      test('should create a Module from JSON', () {
        final json = {
          'uid': 'mod123',
          'name': 'Test Module',
          'isActive': true,
          'speciality': 'CS',
          'grade': '1st',
          'numberOfStudents': 2,
          'students': {'s1': 'Student One', 's2': 'Student Two'},
          'attendanceTable': {
            '2023-10-01': {'s1': true, 's2': false}
          },
        };

        final module = Module.fromJson(json);

        expect(module.uid, 'mod123');
        expect(module.name, 'Test Module');
        expect(module.isActive, isTrue);
        expect(module.speciality, 'CS');
        expect(module.grade, '1st');
        expect(module.numberOfStudents, 2);
        expect(module.students['s1'], 'Student One');
        expect(module.attendanceTable['2023-10-01']['s1'], isTrue);
      });
    });
  });
}
