class BarChartBar {
  final int x;
  final int y;
  final DateTime time;

  BarChartBar({
    required this.x,
    required this.y,
    required this.time,
  });

  @override
  String toString() {
    // TODO: implement toString
    return "$x $y $time \n ";
  }
}