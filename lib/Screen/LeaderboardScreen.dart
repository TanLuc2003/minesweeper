import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Hàm gọi API lấy bảng xếp hạng cho từng độ khó
Future<List<Map<String, dynamic>>> getLeaderboard(String difficulty) async {
  final response = await http.get(
    Uri.parse('http://192.168.3.22:3000/leaderboard/$difficulty'),
  );

  if (response.statusCode == 200) {
    // Nếu API trả về kết quả thành công, parse dữ liệu JSON
    List<dynamic> leaderboardData = jsonDecode(response.body);
    return leaderboardData.map((item) {
      return {
        'name': item['name'],
        'bestTime': item['bestTime'],
      };
    }).toList();
  } else {
    throw Exception('Failed to load leaderboard');
  }
}

class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Có 3 tab cho 3 độ khó
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bảng Xếp Hạng'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Easy'),
              Tab(text: 'Medium'),
              Tab(text: 'Hard'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Bảng xếp hạng cho độ khó Easy
            _buildLeaderboard('easy'),
            // Bảng xếp hạng cho độ khó Medium
            _buildLeaderboard('medium'),
            // Bảng xếp hạng cho độ khó Hard
            _buildLeaderboard('hard'),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị bảng xếp hạng cho từng độ khó
  Widget _buildLeaderboard(String difficulty) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getLeaderboard(difficulty),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Có lỗi xảy ra!'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Không có dữ liệu bảng xếp hạng.'));
        } else {
          final leaderboard = snapshot.data!;
          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(leaderboard[index]['name']),
                subtitle:
                    Text('Thời gian: ${leaderboard[index]['bestTime']} giây'),
              );
            },
          );
        }
      },
    );
  }
}
