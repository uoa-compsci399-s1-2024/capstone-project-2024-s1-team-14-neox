import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy policy"),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
"""We collect personal information from you, including information about your:
• name
• date of birth
• gender
• device sensor readings and associated timestamps

We collect your personal information in order to:
• aid research in the studies that you have signed up for.

Besides our staff, we share this information with:
• researchers conducting your registered studies in order to help understand and prevent the development of myopia in young children.

You have the right to ask for a copy of any personal information we hold about you, and to ask for it to be corrected if you think it is wrong. If you'd like to ask for a copy of your information, or to have it corrected, please contact John Phillips (j.phillips@auckland.ac.nz) and Phil Turnbull (p.turnbull@auckland.ac.nz), or The University of Auckland, Building 505, 85 Park Road, Grafton, Auckland, 1023, New Zealand.
""",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );           
  }
}
