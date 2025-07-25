import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_providers.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late UserProvider _userProvider;
  List<User> _users = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _fetchUsers();
    _searchController.addListener(() => _fetchUsers());
  }

  Future<void> _fetchUsers() async {
    try {
      var result = await _userProvider.get(filter: {
        "SearchText": _searchController.text,
      });
      setState(() => _users = result.result);
    } catch (e) {
      showErrorDialog(context, "Failed to fetch users: $e");
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("User Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("First Name: ${user.firstName ?? ''}"),
            Text("Last Name: ${user.lastName ?? ''}"),
            Text("Username: ${user.username ?? ''}"),
            Text("Email: ${user.email ?? ''}"),
            Text("Phone: ${user.phoneNumber ?? ''}"),
            Text("Role(s): ${user.roleName ?? 'Unknown'}"),
            Text("Address: ${user.address ?? ''}"),
            Text("Date of Birth: ${user.dateOfBirth?.toLocal().toString().split(' ')[0] ?? ''}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  void _confirmPromote(User user) async {
    final shouldPromote = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Promotion"),
        content: Text("Promote ${user.firstName} to Admin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (shouldPromote == true) {
      try {
        await _userProvider.promoteToAdmin(user.userId!);
        _fetchUsers();
        _showSnackBar('User promoted to admin.', Colors.green);
      } catch (e) {
        _showSnackBar('You cannot demote yourself.', Colors.red);
      }
    }
  }

  void _confirmDemote(User user) async {
    final shouldDemote = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Demotion"),
        content: Text("Remove Admin from ${user.firstName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (shouldDemote == true) {
      try {
        await _userProvider.demoteFromAdmin(user.userId!);
        _fetchUsers();
        _showSnackBar('User demoted to user.', Colors.green);
      } catch (e) {
        _showSnackBar('Failed to demote user: ${e.toString()}', Colors.red);
      }
    }
  }

  void _confirmDelete(User user) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Delete ${user.firstName} ${user.lastName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _userProvider.deleteUser(user.userId!);
        _fetchUsers();
        _showSnackBar('User deleted.', Colors.green);
      } catch (e) {
        _showSnackBar('Failed to delete user: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(centerTitle: true, automaticallyImplyLeading: false),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Search Users", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search by name or email...",
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
  child: _users.isEmpty
      ? const Center(child: Text("No users found."))
      : Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
  scrollDirection: Axis.vertical,
  child: Align(
    alignment: Alignment.centerLeft,
    child: SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 32,
        dataRowHeight: 56,
        columns: const [
          DataColumn(label: Expanded(child: Text("First Name"))),
          DataColumn(label: Expanded(child: Text("Last Name"))),
          DataColumn(label: Expanded(child: Text("Email"))),
          DataColumn(label: Expanded(child: Text("Phone"))),
          DataColumn(label: Expanded(child: Text("Role"))),
          DataColumn(label: Expanded(child: Text("Actions"))),
        ],
        rows: _users.map((user) {
          final isAdmin = user.roleName?.toLowerCase().contains("admin") ?? false;
          return DataRow(cells: [
            DataCell(Text(user.firstName ?? "")),
            DataCell(Text(user.lastName ?? "")),
            DataCell(Text(user.email ?? "")),
            DataCell(Text(user.phoneNumber ?? "")),
            DataCell(Text(user.roleName ?? "")),
            DataCell(Row(
              children: [
                Tooltip(
                  message: 'View user details',
                  child: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.grey),
                    onPressed: () => _showUserDetails(user),
                  ),
                ),
                if (!isAdmin)
                  Tooltip(
                    message: 'Promote to Admin',
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.grey),
                      onPressed: () => _confirmPromote(user),
                    ),
                  ),
                if (isAdmin)
                  Tooltip(
                    message: 'Demote from Admin',
                    child: IconButton(
                      icon: const Icon(Icons.arrow_downward, color: Colors.grey),
                      onPressed: () => _confirmDemote(user),
                    ),
                  ),
                Tooltip(
                  message: 'Delete user',
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => _confirmDelete(user),
                  ),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    ),
  ),
),

          ),
        ),
)

        ],
      ),
    ),
  );
}

}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Error"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
