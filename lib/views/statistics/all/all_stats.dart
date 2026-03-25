import 'package:attendify/shared/error_pages.dart';
import 'package:attendify/views/statistics/all/all_modules_stats.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllStats extends StatelessWidget {
  final String statType;

  const AllStats({super.key, required this.statType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "All $statType statistics ",
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              switch (statType) {
                case "modules":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllModulesStats(),
                    ),
                  );
                  break;
                case "teachers":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Container(),
                    ),
                  );
                  break;
                case "students":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Container(),
                    ),
                  );
                  break;
                default:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ErrorPages(
                        title: "Error 404: Not Found",
                        message: "No Statistic data available for this type",
                      ),
                    ),
                  );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              foregroundColor: Colors.blue[100],
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            child: const Text("Show"),
          ),
        ],
      ),
    );
  }
}
