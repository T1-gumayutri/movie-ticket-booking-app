import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  @override
  void initState() {
    super.initState();
    // Vừa vào màn hình là tự động gọi API lấy danh sách user
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      Future.microtask(() => Provider.of<AdminProvider>(context, listen: false).fetchUsers(token));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Người dùng')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.users.isEmpty) {
            return const Center(child: Text('Không có dữ liệu người dùng.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.users.length,
            itemBuilder: (context, index) {
              final user = provider.users[index];
              final isAdmin = user['role'] == 'admin';

              return Card(
                color: AppConstants.cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdmin ? AppConstants.primaryColor : Colors.grey[700],
                    child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                  ),
                  title: Text(user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email'] ?? ''),
                  trailing: isAdmin
                      ? const Text('ADMIN', style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold))
                      : IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, user['_id'], user['name']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cảnh báo'),
        content: Text('Xóa vĩnh viễn tài khoản "$userName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = Provider.of<AuthProvider>(context, listen: false).token!;
              final success = await Provider.of<AdminProvider>(context, listen: false).deleteUser(userId, token);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa thành công')));
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}