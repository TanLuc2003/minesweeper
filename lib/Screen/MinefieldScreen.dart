import 'package:flutter/material.dart';
import '../controller/MinefieldController.dart';
import '../model/Minefield.dart';

class MinefieldScreen extends StatefulWidget {
  final Minefield minefield;

  final String difficulty;

  MinefieldScreen(this.minefield, this.difficulty);

  @override
  _MinefieldScreenState createState() => _MinefieldScreenState();
}

class _MinefieldScreenState extends State<MinefieldScreen> {
  late MinefieldController controller;

  @override
  void initState() {
    super.initState();
    controller = MinefieldController(widget.minefield, widget.difficulty);
    controller.startCountdown(updateUI, startGameTimer);
  }

  void updateUI() {
    setState(() {});
  }

  void startGameTimer() {
    controller.startGameTimer(updateUI);
  }

  void saveScore() {
    controller.saveCompletionTimeToFirestore();
  }

  @override
  Widget build(BuildContext context) {
    // Đặt số lượng hàng và cột dựa trên cấu hình trò chơi
    final boardSize = widget.minefield.rows; // Số hàng = số cột (ma trận vuông)

    // Kích thước của mỗi ô
    final cellSize = 40.0; // Kích thước cố định cho mỗi ô (có thể điều chỉnh)

    // Tổng kích thước của bảng (ma trận vuông)
    final gridSize = cellSize * boardSize;
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.gameOver
            ? "Thua òi"
            : (controller.gameWon ? "Thắng gòi!" : "Minesweeper")),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Time: ${controller.elapsedTime} s",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: controller.showCountdown
          ? Center(
              child: Text(
                "${controller.countdown}",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
            )
          : Stack(
              children: [
                Center(
                  child: Container(
                    width: gridSize, // Đảm bảo chiều rộng của lưới
                    height: gridSize, // Đảm bảo chiều cao của lưới
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(), // Tắt cuộn
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: boardSize,
                        mainAxisSpacing: 2, // Khoảng cách dọc giữa các ô
                        crossAxisSpacing: 2,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: boardSize * boardSize,
                      itemBuilder: (context, index) {
                        int x = index ~/ widget.minefield.cols;
                        int y = index % widget.minefield.cols;
                        final cell = widget.minefield.board[x][y];
                        return GestureDetector(
                          onTap: () =>
                              controller.revealCell(x, y, updateUI, saveScore),
                          onLongPress: () =>
                              controller.toggleFlag(x, y, updateUI),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: cell.isRevealed
                                  ? (cell.hasMine
                                      ? Colors.red
                                      : Colors.orange[200])
                                  : Colors.pink[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: cell.isRevealed
                                  ? (cell.hasMine
                                      ? Text("💣",
                                          style: TextStyle(fontSize: 20))
                                      : (cell.number > 0
                                          ? Text(cell.number.toString())
                                          : null))
                                  : (cell.isFlagged
                                      ? Text("🚩",
                                          style: TextStyle(fontSize: 20))
                                      : null),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (controller.gameOver || controller.gameWon)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.gameOver ? "Game Over" : "You Win!",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color:
                                controller.gameOver ? Colors.red : Colors.green,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            controller.resetGame(updateUI, () {
                              controller.startCountdown(
                                  updateUI, startGameTimer);
                            });
                          },
                          child: Text("Chơi lại"),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    controller.stopGameTimer();
    controller.countdownTimer?.cancel();
    super.dispose();
  }
}
