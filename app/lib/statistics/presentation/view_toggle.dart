import 'package:capstone_project_2024_s1_team_14_neox/statistics/cubit/statistics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewToggle extends StatefulWidget {
  final double width;
  final double height;
  // ValueChanged<int> animateToPage;
  ViewToggle(
      {super.key,
      required this.width,
      required this.height /*,
      required this.animateToPage*/
      });

  @override
  State<ViewToggle> createState() => _ViewToggleState();
}

class _ViewToggleState extends State<ViewToggle> {
  bool detailedView = true;
  void _changeAnimation() {
    print("focus view toggled in viewToggle");
    setState(() {
      detailedView = !detailedView;
    });
    // widget.animateToPage(detailedView ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: EdgeInsets.all(8),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {

              _changeAnimation();
              context.read<StatisticsCubit>().onFocusViewToggle();
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Detailed",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Overview",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            alignment:
                detailedView ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: widget.width * 0.55,
              height: widget.height,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                detailedView ? "Detailed" : "Overview",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
