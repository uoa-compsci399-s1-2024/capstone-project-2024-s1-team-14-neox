import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({super.key, required this.result, required this.onConnect});

  final ScanResult result;
  final VoidCallback onConnect;

  String _formatDeviceRemoteId(List<int> data) {
    return data.map((e) => e.toRadixString(16).toUpperCase().padLeft(2, '0')).join(':');
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          result.device.platformName,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "ID: ${_formatDeviceRemoteId(result.advertisementData.manufacturerData.values.firstOrNull ?? [])}",
          style: Theme.of(context).textTheme.bodySmall,
        )
      ],
    );
  }

  Widget _buildConnectButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        onConnect();
      },
      child: const Text('Pair'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(context),
      trailing: _buildConnectButton(context),
    );
  }
}
