import 'package:doodle/screens/create_room_screen.dart';
import 'package:doodle/screens/join_room_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Create/Join a room to play",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateRoomScreen(),
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    Size(
                      MediaQuery.of(context).size.width / 2.5,
                      50,
                    ),
                  ),
                ),
                child: const Text(
                  "Create",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const JoinRoomScreen(),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    Size(
                      MediaQuery.of(context).size.width / 2.5,
                      50,
                    ),
                  ),
                ),
                child: const Text(
                  "Join",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
