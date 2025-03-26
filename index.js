const express = require('express');
const db = require('./firebase-config');  // Kết nối Firestore
const app = express();
const cors = require('cors');
app.use(cors());
// API lấy bảng xếp hạng theo độ khó
app.get('/leaderboard/:difficulty', async (req, res) => {
  const difficulty = req.params.difficulty;  // Lấy độ khó từ tham số URL (easy, medium, hard)

  // Kiểm tra độ khó hợp lệ
  if (!['easy', 'medium', 'hard'].includes(difficulty)) {
    return res.status(400).json({ error: 'Invalid difficulty level' });
  }

  try {
    // Lấy dữ liệu từ Firestore
    const snapshot = await db.collection('users').get();

    // Lọc và sắp xếp bảng xếp hạng theo độ khó
    const leaderboard = [];
    snapshot.forEach(doc => {
      const userData = doc.data();
      const times = userData.scores[difficulty];  // Lấy thời gian hoàn thành của chế độ chơi (easy, medium, hard)
      
      // Nếu không có thời gian chơi thì bỏ qua
      if (!times || times.length === 0) return;

      // Lấy thời gian nhanh nhất trong mỗi chế độ
      const bestTime = Math.min(...times);

      leaderboard.push({
        name: userData.name,
        bestTime,
      });
    });

    // Sắp xếp bảng xếp hạng theo thời gian từ ít đến nhiều
    leaderboard.sort((a, b) => a.bestTime - b.bestTime);

    res.json(leaderboard);  // Trả về bảng xếp hạng
  } catch (error) {
    console.error('Error getting leaderboard:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Khởi động server
app.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});
