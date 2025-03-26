import 'dart:math';

class Minefield {
  final int rows;
  final int cols;
  final int mineCount;
  late List<List<Cell>> board;

  Minefield(this.rows, this.cols, this.mineCount) {
    initializeBoard();
    placeMines();
    calculateNumbers();
  }

  void initializeBoard() {
    board = List.generate(rows, (_) => List.generate(cols, (_) => Cell()));
  }

  void revealAdjacentCells(int x, int y) {
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        final nx = x + dx;
        final ny = y + dy;

        if (nx >= 0 &&
            nx < rows &&
            ny >= 0 &&
            ny < cols &&
            !board[nx][ny].isRevealed &&
            !board[nx][ny].hasMine) {
          board[nx][ny].isRevealed = true;

          if (board[nx][ny].number == 0) {
            revealAdjacentCells(nx, ny); // Đệ quy mở các ô trống lân cận
          }
        }
      }
    }
  }

  bool isWin() {
    for (var row in board) {
      for (var cell in row) {
        if (!cell.hasMine && !cell.isRevealed) {
          return false;
        }
      }
    }
    return true;
  }

  void placeMines() {
    int placed = 0;
    while (placed < mineCount) {
      int x = Random().nextInt(rows);
      int y = Random().nextInt(cols);
      if (!board[x][y].hasMine) {
        board[x][y].hasMine = true;
        placed++;
      }
    }
  }

  void calculateNumbers() {
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < cols; y++) {
        if (board[x][y].hasMine) continue;
        board[x][y].number = countMinesAround(x, y);
      }
    }
  }

  int countMinesAround(int x, int y) {
    int count = 0;
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        int nx = x + dx, ny = y + dy;
        if (isInBounds(nx, ny) && board[nx][ny].hasMine) {
          count++;
        }
      }
    }
    return count;
  }

  bool isInBounds(int x, int y) => x >= 0 && y >= 0 && x < rows && y < cols;
}

class Cell {
  bool hasMine = false; // Ô có mìn hay không
  int number = 0; // Số lượng mìn xung quanh
  bool isRevealed = false; // Ô đã được mở hay chưa
  bool isFlagged = false; // Ô có cắm cờ hay không
}
