import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/attendify_student.dart';
import '../../services/providers.dart';

class AllStudentsView extends ConsumerWidget {
  const AllStudentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsyncValue = ref.watch(allStudentsProvider);
    return studentsAsyncValue.when(
      data: (allStudents) {
        return Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'All Students',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: allStudents.length,
                itemBuilder: (context, index) {
                  final student = allStudents[index];
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      color: Colors.blue[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        splashColor: Colors.blue[300],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                          vertical: 5.0,
                        ),
                        title: Text(
                          student.userName,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(error.toString())),
    );
  }
}
