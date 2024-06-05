import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:capstone_project_2024_s1_team_14_neox/main.dart';
import 'package:capstone_project_2024_s1_team_14_neox/settings/presentation/about_screen.dart';
import 'package:capstone_project_2024_s1_team_14_neox/settings/presentation/faqs_screen.dart';
import 'package:capstone_project_2024_s1_team_14_neox/settings/presentation/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsScreen extends StatefulWidget {
  final TextEditingController _dailyTargetController = TextEditingController();

  SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showDailyTargetDialog(BuildContext context) {
    TextEditingController dailyTargetController = widget._dailyTargetController;
    dailyTargetController.text =
        App.sharedPreferences.getInt("daily_target")!.toString();

    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          title: const Text("Set daily outdoor time target"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dailyTargetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Minutes",
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  App.sharedPreferences.setInt("daily_target", 120);
                  Navigator.pop(innerContext);
                });
              },
              child: const Text("Default"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(innerContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                int? target = int.tryParse(dailyTargetController.text);
                if (target == null || target <= 0) {
                  var scaffold = ScaffoldMessenger.of(context);
                  scaffold.showSnackBar(
                    const SnackBar(content: Text("Invalid value")),
                  );
                  Future.delayed(
                      const Duration(seconds: 2), scaffold.hideCurrentSnackBar);
                  return;
                }

                setState(() {
                  App.sharedPreferences.setInt("daily_target", target);
                  Navigator.pop(innerContext);
                });
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          title: const Text("Delete all data"),
          content: const Text(
              "Are you sure you want to delete all data? This action cannot be undone. Please sync to Neox Cloud to back up data."),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(innerContext),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  AppDb.instance().deleteEverything();
                  App.resetSharedPreferences();
                  Navigator.pop(innerContext);
                });
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSetting(
    String text, {
    Color textColour = Colors.black,
    Widget? icon = const Icon(Icons.arrow_forward_ios,
        color: Color.fromARGB(255, 77, 77, 77)),
    required Function() action,
  }) {
    return InkWell(
        onTap: action,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 15, 12),
          child: Row(
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  color: textColour,
                ),
              ),
              const Spacer(),
              if (icon != null) icon,
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          scrolledUnderElevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildSetting(
                "Daily outdoor time target",
                icon: Text(
                  "${App.sharedPreferences.getInt("daily_target")} minutes",
                  style: const TextStyle(color: Colors.grey),
                ),
                action: () => _showDailyTargetDialog(context),
              ),
              Divider(
                thickness: 4,
                height: 4,
                color: Colors.grey[200],
              ),
              _buildSetting(
                "Frequently asked questions",
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FaqsScreen()),
                  );
                },
              ),
              _buildSetting(
                "Background",
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
              _buildSetting(
                "Privacy policy",
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen()),
                  );
                },
              ),
              _buildSetting(
                "About",
                icon: null,
                action: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Neox Sens",
                    applicationVersion: "v1.0.0",
                    applicationIcon: SvgPicture.asset(
                      "assets/icon_medium.svg",
                      width: 50,
                    ),
                  );
                },
              ),
              Divider(
                thickness: 4,
                height: 4,
                color: Colors.grey[200],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 40, 8, 0),
                child: SizedBox(
                  width: screenWidth,
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showDeleteAllDataDialog(context),
                    child: const Text(
                      'Delete all data',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ));
  }
}
