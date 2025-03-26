import 'package:flutter/material.dart';

void main() {
  runApp(MinesweeperGame());
}

class MinesweeperGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
    );
  }
}

class Character {
  int x; // Row position
  int y; // Column position

  Character({required this.x, required this.y});
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 8;
  static const double cellSize = 50.0;

  Character character = Character(x: 0, y: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minesweeper with Character"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Board
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                  ),
                  itemBuilder: (context, index) {
                    int row = index ~/ gridSize;
                    int col = index % gridSize;
                    return CellWidget(row: row, col: col);
                  },
                  itemCount: gridSize * gridSize,
                ),
                // Character
                Positioned(
                  top: character.x * cellSize,
                  left: character.y * cellSize,
                  child: CharacterWidget(),
                ),
              ],
            ),
          ),
          // Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_upward),
                  onPressed: () => moveCharacter('up'),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_downward),
                  onPressed: () => moveCharacter('down'),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => moveCharacter('left'),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () => moveCharacter('right'),
                ),
                IconButton(
                  icon: Icon(Icons.flag),
                  onPressed: interactWithCell,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void moveCharacter(String direction) {
    setState(() {
      switch (direction) {
        case 'up':
          if (character.x > 0) character.x--;
          break;
        case 'down':
          if (character.x < gridSize - 1) character.x++;
          break;
        case 'left':
          if (character.y > 0) character.y--;
          break;
        case 'right':
          if (character.y < gridSize - 1) character.y++;
          break;
      }
    });
  }

  void interactWithCell() {
    // Example interaction: Print character's position
    print("Interacting with cell at (${character.x}, ${character.y})");
  }
}

class CellWidget extends StatelessWidget {
  final int row;
  final int col;

  const CellWidget({Key? key, required this.row, required this.col})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(""), // You can add content here
      ),
    );
  }
}

class CharacterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
