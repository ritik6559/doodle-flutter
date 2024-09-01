import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PainScreen extends StatefulWidget {
  const PainScreen({super.key});

  @override
  State<PainScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PainScreen> {
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {}

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
