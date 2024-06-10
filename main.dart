import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const IpReputationScreen(),
    );
  }
}

class IpReputationScreen extends StatefulWidget {
  const IpReputationScreen({Key? key}) : super(key: key);

  @override
  _IpReputationScreenState createState() => _IpReputationScreenState();
}

class _IpReputationScreenState extends State<IpReputationScreen> {
  String _ipAddress = '';
  String _isp = '';
  int _fraudScore = -1;
  bool _isLoading = false;

  void _getIpAddressReputation() async {
    setState(() {
      _isLoading = true;
    });

    final ipUrl = 'https://api.ipify.org?format=json';
    final ipResponse = await http.get(Uri.parse(ipUrl));
    
    if (ipResponse.statusCode == 200) {
      final ipData = json.decode(ipResponse.body);
      final ipAddress = ipData['ip'];

      setState(() {
        _ipAddress = ipAddress;
      });

      final apiKey = 'A2oDMO3NlJL29RIlSMgv6D2zvykXIVos'; 
      final reputationUrl = 'https://ipqualityscore.com/api/json/ip/$apiKey/$ipAddress';
      final reputationResponse = await http.get(Uri.parse(reputationUrl));
      
      if (reputationResponse.statusCode == 200) {
        final reputationData = json.decode(reputationResponse.body);
        setState(() {
          _isp = reputationData['ISP'] ?? 'Unknown';
          _fraudScore = reputationData['fraud_score'] ?? -1;
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Reputation Checker'),
      ),
      body: Center(
        child: _isLoading
          ? const CircularProgressIndicator()
          : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _getIpAddressReputation,
                child: const Text('GET IP address reputation'),
              ),
              if (_ipAddress.isNotEmpty) Text('IP Address: $_ipAddress'),
              if (_isp.isNotEmpty) Text('ISP: $_isp'),
              if (_fraudScore != -1) Text('Fraud Score: $_fraudScore'),
            ],
          ),
      ),
    );
  }
}
