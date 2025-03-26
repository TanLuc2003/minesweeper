import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Tải dữ liệu người dùng từ Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'];
          _avatarUrl = user.photoURL;
        });
      }
    }
  }

  // Cập nhật tên trong Firestore
  Future<void> _updateName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Tên đã được cập nhật")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hiển thị avatar nếu có
            _avatarUrl != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_avatarUrl!),
                  )
                : const CircleAvatar(
                    radius: 50, child: Icon(Icons.account_circle, size: 50)),

            const SizedBox(height: 16),
            // Ô nhập tên
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên người chơi'),
            ),
            const SizedBox(height: 16),
            // Nút cập nhật tên
            ElevatedButton(
              onPressed: _updateName,
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }
}
