import 'package:delemon/data/datasources/user_local_datasource.dart';
import 'package:flutter/material.dart';
import 'package:delemon/data/models/user_model.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final UserLocalDataSource _userLocalDataSource = UserLocalDataSource();
  List<UserModel> staffs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStaffs();
  }

  Future<void> _loadStaffs() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      await _userLocalDataSource.printAllUsersToTerminal();
      
      final allUsers = await _userLocalDataSource.getAllUsers();
      print('\n=== STAFF DASHBOARD DEBUG ===');
      print('Total users from getAllUsers: ${allUsers.length}');
      
      for (var user in allUsers) {
        print('User: ${user.name}, Role: ${user.role}, Role Type: ${user.role.runtimeType}');
        print('  Is staff? ${user.role == UserRoleAdapter.staff}');
      }
      
      // Now get staffs specifically
      final fetchedStaffs = await _userLocalDataSource.getAllStaffs();
      print('Staff users from getAllStaffs: ${fetchedStaffs.length}');
      
      for (var staff in fetchedStaffs) {
        print('Staff: ${staff.name} (${staff.email})');
      }
      print('=== END DEBUG ===\n');

      setState(() {
        staffs = fetchedStaffs;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading staffs: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStaffs,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text("Error: $errorMessage"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStaffs,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : staffs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text("No staff members found"),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadStaffs,
                            child: const Text("Refresh"),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Header with count
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Text(
                                "Staff Members (${staffs.length})",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Staff list
                        Expanded(
                          child: ListView.builder(
                            itemCount: staffs.length,
                            itemBuilder: (context, index) {
                              final staff = staffs[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  title: Text(
                                    staff.name,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(staff.email),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      "STAFF",
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}