import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({super.key, required this.result, required this.onConnect, required this.loading});

  final ScanResult result;
  final VoidCallback onConnect;
  final bool loading;

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
          "ID: ${result.device.remoteId.str}",
          style: Theme.of(context).textTheme.bodySmall,
        )
      ],
    );
  }

  Widget _buildConnectButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        onConnect();
      },
      child: loading ?
        const SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator()
        )
        : const Text('PAIR'),
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
