import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/Minefield.dart';
// import 'package:audioplayers/audioplayers.dart';

class MinefieldController {
  final Minefield minefield;
  bool gameOver = false;
  bool gameWon = false;
  int elapsedTime = 0;
  int countdown = 3;
  Timer? gameTimer;
  Timer? countdownTimer;
  bool showCountdown = true;
  String currentDifficulty;

  MinefieldController(this.minefield, this.currentDifficulty);

  void startCountdown(Function updateUI, Function startGameTimer) {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        countdown--;
        updateUI();
      } else {
        showCountdown = false;
        countdownTimer?.cancel();
        startGameTimer();
      }
    });
  }

  void startGameTimer(Function updateUI) {
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      elapsedTime++;
      updateUI();
    });
  }

  void stopGameTimer() {
    gameTimer?.cancel();
  }

  void revealCell(int x, int y, Function updateUI, Function saveScore) {
    if (gameOver || gameWon) return;

    final cell = minefield.board[x][y];

    if (cell.hasMine) {
      gameOver = true;
      stopGameTimer();
      revealAllMines();
      cell.isRevealed = true;
      updateUI();
      return;
    }

    if (!cell.isRevealed && !cell.isFlagged) {
      cell.isRevealed = true;

      if (cell.number == 0) {
        minefield.revealAdjacentCells(x, y);
      }

      if (minefield.isWin()) {
        gameWon = true;
        stopGameTimer();
        saveScore();
      }

      updateUI();
    }
  }

  void revealAllMines() {
    for (int x = 0; x < minefield.rows; x++) {
      for (int y = 0; y < minefield.cols; y++) {
        final cell = minefield.board[x][y];
        if (cell.hasMine) {
          cell.isRevealed = true;
        }
      }
    }
  }

  void toggleFlag(int x, int y, Function updateUI) {
    if (!gameOver && !gameWon) {
      final cell = minefield.board[x][y];
      if (!cell.isRevealed) {
        cell.isFlagged = !cell.isFlagged;
        updateUI();
      }
    }
  }

  void resetGame(Function updateUI, Function startCountdown) {
    stopGameTimer();
    gameOver = false;
    gameWon = false;
    elapsedTime = 0;
    countdown = 3;
    showCountdown = true;
    minefield.initializeBoard();
    minefield.placeMines();
    minefield.calculateNumbers();
    startCountdown();
    updateUI();
  }

  Future<void> saveCompletionTimeToFirestore() async {
    if (gameWon) {
      String difficulty = currentDifficulty;
      var user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        try {
          await docRef.update({
            'scores.$difficulty': FieldValue.arrayUnion([elapsedTime]),
          });
        } catch (e) {
          print("Error saving time: $e");
        }
      }
    }
  }
}
