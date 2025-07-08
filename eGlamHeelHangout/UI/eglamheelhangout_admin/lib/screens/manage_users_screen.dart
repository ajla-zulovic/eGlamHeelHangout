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
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _fetchUsers();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
      _fetchUsers();
    });
  }

  Future<void> _fetchUsers() async {
    try {
      var result = await _userProvider.get(filter: {
        "SearchText": _searchText,
      });
      setState(() {
        _users = result.result;
      });
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
        content: Text("Are you sure you want to promote ${user.firstName} to Administrator?"),
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
        showSuccessDialog(context, "User promoted to admin.");
      } catch (e) {
        showErrorDialog(context, "Failed to promote user: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name or email...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
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
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("First Name")),
                                DataColumn(label: Text("Last Name")),
                                DataColumn(label: Text("Email")),
                                DataColumn(label: Text("Phone")),
                                DataColumn(label: Text("Role")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: _users.map(
                                (user) {
                                  final isAdmin = user.roleName?.toLowerCase().contains("admin") ?? false;

                                  return DataRow(cells: [
                                    DataCell(Text(user.firstName ?? "")),
                                    DataCell(Text(user.lastName ?? "")),
                                    DataCell(Text(user.email ?? "")),
                                    DataCell(Text(user.phoneNumber ?? "")),
                                    DataCell(Text(user.roleName ?? "")),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility),
                                          onPressed: () => _showUserDetails(user),
                                        ),
                                        if (!isAdmin)
                                          IconButton(
                                            icon: const Icon(Icons.upgrade, color: Colors.blue),
                                            tooltip: "Promote to Admin",
                                            onPressed: () => _confirmPromote(user),
                                          ),
                                      ],
                                    )),
                                  ]);
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
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

void showSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Success"),
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
