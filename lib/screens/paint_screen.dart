import 'package:doodle/models/my_custom_painter.dart';
import 'package:doodle/models/touch_points.dart';
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
  Map dataOfRoom = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 4;

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
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    //listen to socket
    _socket.onConnect(
      (data) {
        _socket.on(
          'updateRoom',
          (roomData) {
            setState(() {
              dataOfRoom = roomData;
            });

            if (roomData['isJoin'] != true) {
              // start the timer
            }
          },
        );
      },
    );

    _socket.on(
      'points',
      (point) {
        if (point['details'] != null) {
          setState(() {
            points.add(
              TouchPoints(
                points: Offset(
                  (point['details']['dx']).toDouble(),
                  (point['details']['dy']).toDouble(),
                ),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth,
              ),
            );
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                height: height * 0.55,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    _socket.emit(
                      'paint',
                      {
                        'details': {
                          'dx': details.localPosition.dx,
                          'dy': details.localPosition.dy,
                        },
                        'roomName': widget.data['name']
                      },
                    );
                  },
                  onPanStart: (details) {
                    _socket.emit(
                      'paint',
                      {
                        'details': {
                          'dx': details.localPosition.dx,
                          'dy': details.localPosition.dy,
                        },
                        'roomName': widget.data['name']
                      },
                    );
                  },
                  onPanEnd: (details) {
                    _socket.emit(
                      'paint',
                      {
                        'details': null,
                        'roomName': widget.data['name'],
                      },
                    );
                  },
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(
                          20,
                        ),
                      ),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: MyCustomPainter(pointsList: points),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
