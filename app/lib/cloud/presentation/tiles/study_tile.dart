import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudyTile extends StatelessWidget {
  final String studyTitle;
  final String studyDescription;
  final DateTime studyStartDate;
  final DateTime studyEndDate;
  
  // TODO pass function to add and delete children, like how you will do for scan in bluetooth bloc
  const StudyTile(
      {super.key,
      required this.studyTitle,
      required this.studyDescription,
      required this.studyStartDate,
      required this.studyEndDate});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: Column(
              children: [
                Text(studyTitle),

                Text("Participating"),

              ],
            ),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 200,
          width: 300,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Text(
                studyTitle,
                style: const TextStyle(
                    fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                studyDescription,
                style: const TextStyle(fontSize: 16.0),
              ),
              Text(
                DateFormat("dd MMMM yyyy").format(studyStartDate) +
                    "~" +
                    DateFormat("dd MMMM yyyy").format(studyEndDate),
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
