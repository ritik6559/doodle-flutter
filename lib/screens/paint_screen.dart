import 'package:doodle/secrets.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map data;
  final String screenFrom;
  const PaintScreen({
    super.key,
    required this.data,
    required this.screenFrom,
  });

  @override
  State<PaintScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PaintScreen> {
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    _socket = IO.io('http://$ip:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-gae',widget.data);
    }

    //listen to socket
    _socket.onConnect((data) {
      print(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
