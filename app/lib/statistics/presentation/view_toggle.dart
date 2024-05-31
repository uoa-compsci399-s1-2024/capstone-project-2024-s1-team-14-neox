import 'package:capstone_project_2024_s1_team_14_neox/statistics/cubit/statistics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewToggle extends StatelessWidget {
  final double width;
  final double height;
  final bool detailedView;
  const ViewToggle({
    super.key,
    required this.width,
    required this.height,
    required this.detailedView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.all(8),
      child: Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Daily",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    "Monhtly",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeIn,
            alignment:
                detailedView ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: width * 0.55,
              height: height,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                detailedView ? "Daily" : "Monthly",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
