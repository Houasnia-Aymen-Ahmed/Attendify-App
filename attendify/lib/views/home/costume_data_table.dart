import 'package:flutter/material.dart';

class CostomeDataTable extends StatelessWidget {
  final List<DataColumn> cols;
  final List<DataRow> rows;
  const CostomeDataTable({super.key, required this.cols, required this.rows});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: cols,
      rows: rows,
    );
  }
}
