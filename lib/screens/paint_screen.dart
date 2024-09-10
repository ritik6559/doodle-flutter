import 'dart:async';

import 'package:doodle/models/my_custom_painter.dart';
import 'package:doodle/models/touch_points.dart';
import 'package:doodle/secrets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  List<Widget> textBlankWdget = [];
  ScrollController _scrollController = ScrollController();
  List<Map> messages = [];
  TextEditingController _commentsController = TextEditingController();
  int guessedUserCounter = 0;
  int _start = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer time) {
        if (_start == 0) {
          _socket.emit('change-turn', dataOfRoom['name']);
          setState(() {
            _timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void renderTextBlank(String text) {
    textBlankWdget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWdget.add(
        const Text(
          '_',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      );
    }
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
              renderTextBlank(
                roomData['word'],
              );
              print(
                roomData['word'],
              );
              dataOfRoom = roomData;
            });

            if (roomData['isJoin'] != true) {
              startTimer();
            }
          },
        );
      },
    );

    _socket.on(
      'points',
      (point) {
        if (point['details'] != null) {
          setState(
            () {
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
            },
          );
        }
      },
    );

    _socket.on(
      'color-change',
      (color) {
        int value =
            int.parse(color, radix: 16); // converting hexa decimal to intger
        Color otherColor = Color(value);
        setState(
          () {
            setState(() {
              selectedColor = otherColor;
            });
          },
        );
      },
    );

    _socket.on(
      'stroke-change',
      (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      },
    );

    _socket.on(
      'clear-screen',
      (data) {
        setState(() {
          points.clear();
        });
      },
    );

    _socket.on(
      'msg',
      (msgData) {
        setState(() {
          messages.add(msgData);
          guessedUserCounter = msgData['guessedUserCtr'];
        });

        if (guessedUserCounter == dataOfRoom['players'].length - 1) {
          _socket.emit('change-turn', dataOfRoom['name']);
        }

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 40,
          duration: const Duration(
            milliseconds: 200,
          ),
          curve: Curves.easeInOut,
        );
      },
    );

    _socket.on(
      'change-turn',
      (data) {
        String oldWord = dataOfRoom['word'];
        showDialog(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {
                dataOfRoom = data;
                renderTextBlank(data['word']);
                guessedUserCounter = 0;
                _start = 60;
                points.clear();
              });
              Navigator.of(context).pop();
              _timer.cancel();
              startTimer();
            });

            return AlertDialog(
              title: Center(
                child: Text(
                  'word was $oldWord',
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
          title: const Text(
            "Choose Color",
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                String colorString = color.toString();
                String valueString = colorString
                    .split('(0x')[1]
                    .split(')')[0]; // it will give us the hex code
                print(colorString);
                print(valueString);
                Map map = {
                  'color': valueString,
                  'roomName': dataOfRoom['name'],
                };
                _socket.emit('color-change', map);
              },
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: dataOfRoom != null
          ? dataOfRoom['isJoin'] != true ? Stack(
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
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            selectColor();
                          },
                          icon: Icon(
                            Icons.color_lens,
                            color: selectedColor,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: strokeWidth,
                            onChanged: (value) {
                              Map map = {
                                'stroke': value,
                                'roomName': dataOfRoom['name'],
                              };
                              _socket.emit('stroke-change', map);
                            },
                            activeColor: selectedColor,
                            min: 1.0,
                            max: 10,
                            label: "Strokewidth: $strokeWidth",
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _socket.emit('clear-screen', dataOfRoom['name']);
                          },
                          icon: Icon(
                            Icons.layers_clear,
                            color: selectedColor,
                          ),
                        ),
                      ],
                    ),
                    dataOfRoom['turn']['nickname'] != widget.data['nickname']
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: textBlankWdget,
                          )
                        : Text(
                            dataOfRoom['word'],
                            style: const TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var message = messages[index].values;
                          return ListTile(
                            title: Text(
                              message.elementAt(0),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              message.elementAt(1),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                dataOfRoom['turn']['nickname'] != widget.data['nickname']
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: TextField(
                            autocorrect: false,
                            controller: _commentsController,
                            onSubmitted: (value) {
                              print("value:- ${value.trim()}");
                              if (value.trim().isNotEmpty) {
                                Map map = {
                                  'username': widget.data['nickname'],
                                  'msg': _commentsController.text.trim(),
                                  'word': dataOfRoom['word'],
                                  'roomName': widget.data['name'],
                                  'guessedUserCtr': guessedUserCounter,
                                  'totalTime': 60,
                                  'timeTaken': 60 - _start,
                                };
                                _socket.emit('msg', map);
                                _commentsController.clear();
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              filled: true,
                              fillColor: const Color(0xffF5F5FA),
                              hintText: 'Your guess',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ) : WaitingLobby()
          : const Center(
              child: CircularProgressIndicator()
            ) ,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,
          child: Text(
            '$_start',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }
}
