import 'package:flutter/material.dart';
import 'package:mine_sweeper_games/Controller/LoginController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mine_sweeper_games/Screen/DifficultySelection%20.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = LoginController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange.shade300, // Nền  cam đào
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade200,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videogame_asset, color: Colors.yellowAccent, size: 28),
            const SizedBox(width: 8),
            Text(
              "Minesweeper",
              style: TextStyle(
                fontFamily: 'PressStart2P', // Font pixel
                color: Colors.yellowAccent,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.yellowAccent,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.deepOrange.shade300,
          ),
          child: StreamBuilder<User?>(
            stream: controller.userStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 192, 192, 106),
                    strokeWidth: 3,
                  ),
                );
              }

              if (snapshot.hasData) {
                User user = snapshot.data!;
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get()
                    .then((docSnapshot) {
                  if (docSnapshot.exists) {
                    String userName = docSnapshot['name'];
                    showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController nameController =
                            TextEditingController(text: userName);
                        return AlertDialog(
                          backgroundColor: Colors.deepOrange.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Nhập tên của bạn',
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              color: Color.fromARGB(255, 192, 192, 106),
                              fontSize: 14,
                            ),
                          ),
                          content: TextField(
                            controller: nameController,
                            style: const TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: "Nhập tên của bạn",
                              hintStyle: TextStyle(
                                fontFamily: 'PressStart2P',
                                fontSize: 12,
                                color: Colors.yellowAccent.shade100,
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                String newName = nameController.text;
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({'name': newName});
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Lưu",
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  color: Color.fromARGB(255, 192, 192, 106),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DifficultySelectionScreen(),
                    ),
                  );
                });

                return const SizedBox.shrink();
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo_Google.jpg', // Logo gg
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.signInWithGoogle();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade200,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        shape: const BeveledRectangleBorder(), // Góc pixel
                      ),
                      child: const Text(
                        "Đăng nhập bằng Google",
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
