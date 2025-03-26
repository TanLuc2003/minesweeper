import 'package:flutter/material.dart';
import 'package:mine_sweeper_games/Screen/LeaderboardScreen.dart';
import 'package:mine_sweeper_games/Screen/LoginScreen.dart';
import 'package:mine_sweeper_games/Screen/ProfileScreen.dart';
import 'MinefieldScreen.dart';
import '../model/Minefield.dart';
import 'package:mine_sweeper_games/Controller/LoginController.dart';

enum Difficulty { easy, medium, hard }

final difficultySettings = {
  Difficulty.easy: DifficultyConfig(8, 8, 10),
  Difficulty.medium: DifficultyConfig(12, 12, 20),
  Difficulty.hard: DifficultyConfig(16, 16, 40),
};

class DifficultySelectionScreen extends StatelessWidget {
  final LoginController controller = LoginController();

  DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn Chế Độ",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Thêm nút Profile vào AppBar
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                // Đăng xuất khi chọn "Đăng xuất"
                controller.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                ); // Quay lại màn hình login
              } else if (value == 'profile') {
                // Chuyển đến màn hình Profile khi chọn "Profile"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              } else if (value == 'Rank') {
                // Chuyển đến màn hình Profile khi chọn "Profile"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderboardPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.account_circle, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Rank',
                  child: Row(
                    children: [
                      Icon(Icons.leaderboard, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Rank'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Đăng xuất'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDifficultyButton(
            context,
            "Dễ",
            Icons.accessibility_new,
            Difficulty.easy,
            Colors.green,
          ),
          const SizedBox(height: 10), // Khoảng cách giữa các nút
          _buildDifficultyButton(
            context,
            "Trung Bình",
            Icons.adjust,
            Difficulty.medium,
            Colors.orange,
          ),
          const SizedBox(height: 10), // Khoảng cách giữa các nút
          _buildDifficultyButton(
            context,
            "Khó",
            Icons.error_outline,
            Difficulty.hard,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String label,
    IconData icon,
    Difficulty difficulty,
    Color color,
  ) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: InkWell(
          onTap: () {
            _startGame(context, difficulty);
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.2),
          child: Container(
            width: 500,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, Difficulty difficulty) {
    final config = difficultySettings[difficulty]!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MinefieldScreen(
          Minefield(config.rows, config.cols, config.mineCount),
          difficulty.toString().split('.').last, // Truyền độ khó vào controller
        ),
      ),
    );
  }
}

class DifficultyConfig {
  final int rows;
  final int cols;
  final int mineCount;

  DifficultyConfig(this.rows, this.cols, this.mineCount);
}
