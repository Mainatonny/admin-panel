import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../l10n/app_localizations.dart'; // Import localization

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch all users from the backend
  Future<void> _fetchUsers() async {
    try {
      final data = await ApiService.get('users');
      setState(() {
        _users = (data as List).map((json) => User.fromJson(json)).toList();
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching users: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filter users by name or email
  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Navigate to detailed view of a user
  void _showUserDetails(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailsPage(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('user_management')),
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('search_hint'),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            // User List Table
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                              label: Text(AppLocalizations.of(context)
                                  .translate('name'))),
                          DataColumn(
                              label: Text(AppLocalizations.of(context)
                                  .translate('email'))),
                          DataColumn(
                              label: Text(AppLocalizations.of(context)
                                  .translate('role'))),
                          DataColumn(
                              label: Text(AppLocalizations.of(context)
                                  .translate('points'))),
                          DataColumn(
                              label: Text(AppLocalizations.of(context)
                                  .translate('actions'))),
                        ],
                        rows: _filteredUsers.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(Text(user.name)),
                              DataCell(Text(user.email)),
                              DataCell(Text(user.role)),
                              DataCell(Text(user.points.toString())),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  tooltip: AppLocalizations.of(context)
                                      .translate('view_details'),
                                  onPressed: () => _showUserDetails(user),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// Detailed view for a user with controls for membership, blocking, and points management.
class UserDetailsPage extends StatefulWidget {
  final User user;
  const UserDetailsPage({super.key, required this.user});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late User _user;
  bool _isUpdating = false;
  final TextEditingController _pointsController = TextEditingController();
  String _membershipLevel = 'free'; // default value
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _pointsController.text = _user.points.toString();
    // If your User model has membership or block status, load those here.
  }

  // Simulate an API call to update user details.
  Future<void> _updateUser() async {
    setState(() {
      _isUpdating = true;
    });

    final updatedData = {
      'points': int.tryParse(_pointsController.text) ?? _user.points,
      'membership': _membershipLevel,
      'isBlocked': _isBlocked,
    };

    try {
      // Simulate update delay:
      await Future.delayed(const Duration(seconds: 1));
      // Update local model:
      setState(() {
        _user = User(
          id: _user.id,
          name: _user.name,
          email: _user.email,
          role: _user.role,
          points: updatedData['points'] as int,
        );
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('user_updated_successfully')),
        ),
      );
    } catch (error) {
      setState(() {
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('user_update_failed')),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('user_details') +
            " - ${_user.name}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Basic information
            Text(
                AppLocalizations.of(context).translate('name') +
                    ": ${_user.name}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
                AppLocalizations.of(context).translate('email') +
                    ": ${_user.email}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            // Membership Level Management
            Text(AppLocalizations.of(context).translate('membership_level'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _membershipLevel,
              items: <String>['free', 'paid'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _membershipLevel = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            // Points Management
            Text(AppLocalizations.of(context).translate('points'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context).translate('enter_points'),
              ),
            ),
            const SizedBox(height: 16),
            // Blocked status
            Row(
              children: [
                Text(AppLocalizations.of(context).translate('blocked') + ":",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: _isBlocked,
                  onChanged: (val) {
                    setState(() {
                      _isBlocked = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Update Button
            _isUpdating
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updateUser,
                    child: Text(
                        AppLocalizations.of(context).translate('update_user')),
                  ),
          ],
        ),
      ),
    );
  }
}
