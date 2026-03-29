import 'package:attendify/utils/functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utils Functions Tests', () {
    group('capitalizeFirst', () {
      test('should capitalize the first letter of a string', () {
        expect(capitalizeFirst('hello'), 'Hello');
        expect(capitalizeFirst('world'), 'World');
      });

      test('should return the same string if it has 1 or 0 characters', () {
        expect(capitalizeFirst('a'), 'a');
        expect(capitalizeFirst(''), '');
      });

      test('should work with already capitalized strings', () {
        expect(capitalizeFirst('Hello'), 'Hello');
      });
    });

    group('capitalizeWords', () {
      test('should capitalize the first letter of every word', () {
        expect(capitalizeWords('hello world'), 'Hello World');
        expect(capitalizeWords('java script is cool'), 'Java Script Is Cool');
      });

      test('should lowercase other letters in the word', () {
        expect(capitalizeWords('hELLO wORLD'), 'Hello World');
      });

      test('should return null if input is null', () {
        expect(capitalizeWords(null), isNull);
      });

      test('should return empty string if input is empty', () {
        expect(capitalizeWords(''), '');
      });

      test('should handle multiple spaces', () {
        expect(capitalizeWords('hello  world'), 'Hello  World');
      });
    });
  });
}
