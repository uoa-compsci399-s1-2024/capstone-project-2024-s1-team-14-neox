import 'package:flutter/material.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  Widget _buildFaq(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs"),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
          _buildFaq(
            "Why do I need to enter name, date of birth and gender when creating a profile?",
            "This information is only used if you decide to participate in studies and will only be shared with researchers conducting the study that you have signed up for."
          ),
          _buildFaq(
            "Why can't I see my device when pairing?",
            "Ensure that bluetooth is on and the device is within 10 metres. "
            "If you still cannot see the device, try restarting the device."
          ),
          _buildFaq(
            "Can I pair multiple devices to the same profile?",
            "No. You can however have multiple profiles."
          ),
        ],
      ),
    );           
  }
}
