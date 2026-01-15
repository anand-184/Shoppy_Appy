import 'package:flutter/material.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  // Data list - will be populated by API call
  List<Map<String, String>> _subAdmins = [];
  bool _isLoading = true;

  final Color chocolate = const Color(0xFF915F41);
  final Color darkBrown = const Color(0xFF5F372B);
  final Color backgroundColor = const Color(0xFFFDF8F5);

  @override
  void initState() {
    super.initState();
    _fetchSubAdmins();
  }

  // BLANK FUNCTION FOR BACKEND API FETCH
  Future<void> _fetchSubAdmins() async {
    setState(() => _isLoading = true);
    
    // TODO: Add your Supabase or Backend API call here
    // Example: final response = await Supabase.instance.client.from('admins').select();
    
    await Future.delayed(const Duration(seconds: 1)); // Simulating network delay

    setState(() {
      _subAdmins = [
        {"name": "John Doe", "role": "Marketing Admin", "email": "john@shoppy.com"},
        {"name": "Alice Johnson", "role": "Operations Admin", "email": "alice@shoppy.com"},
        {"name": "Bob Smith", "role": "Finance Admin", "email": "bob@shoppy.com"},
        {"name": "Charlie Brown", "role": "Catalog Admin", "email": "charlie@shoppy.com"},
      ];
      _isLoading = false;
    });
  }

  // BLANK FUNCTION FOR BACKEND API ADD
  Future<void> _saveAdminToBackend(String name, String email, String role) async {
    // TODO: Add your POST/Insert API call here
    // Example: await Supabase.instance.client.from('admins').insert({'name': name, ...});
    
    print("Saving to backend: $name, $email, $role");
    
    // Refresh the list after adding
    _fetchSubAdmins();
  }

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final subAdminTypeController = TextEditingController();

    String selectedRole = 'Operations Admin';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Sub Admin", style: TextStyle(color: darkBrown)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: "Full Name")),
            const SizedBox(height: 10),
            TextField(controller: emailController, decoration: const InputDecoration(hintText: "Email")),
            const SizedBox(height: 10),
            TextField(controller: subAdminTypeController, decoration: const InputDecoration(hintText: "Sub Admin Type")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _saveAdminToBackend(nameController.text, emailController.text, selectedRole);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: chocolate),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditAdminDialog(Map<String, String> admin) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final subAdminTypeController = TextEditingController();

    String selectedRole = 'Operations Admin';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Admin Details", style: TextStyle(color: darkBrown)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: "Full Name")),
            const SizedBox(height: 10),
            TextField(controller: emailController, decoration: const InputDecoration(hintText: "Email")),
            const SizedBox(height: 10),
            TextField(controller: subAdminTypeController, decoration: const InputDecoration(hintText: "Sub Admin Type")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _saveAdminToBackend(nameController.text, emailController.text, selectedRole);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: chocolate),
            child: const Text("Done"),
          ),
        ],
      ),
    );



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110.0),
        child: FloatingActionButton(
          onPressed: _showAddAdminDialog,
          backgroundColor: chocolate,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: chocolate))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _subAdmins.length,
              itemBuilder: (context, index) {
                final admin = _subAdmins[index];
                return _buildAdminCard(admin);
              },
            ),
          ),
    );
  }

  Widget _buildAdminCard(Map<String, String> admin) {
    IconData iconData;
    switch (admin['role']) {
      case 'Operations Admin':
        iconData = Icons.people_rounded;
        break;
      case 'Finance Admin':
        iconData = Icons.payments_rounded;
        break;
      case 'Catalog Admin':
        iconData = Icons.dashboard_rounded;
        break;
      case 'Support Admin':
        iconData = Icons.settings_rounded;
        break;
      case 'Marketing Admin':
        iconData = Icons.campaign_rounded;
        break;
      default:
        iconData = Icons.person_rounded;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: chocolate.withOpacity(0.1),
          child: Icon(iconData, color: chocolate, size: 30),
        ),
        title: Text(admin['role']!, style: TextStyle(fontWeight: FontWeight.bold, color: darkBrown)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(admin['name']!, style: TextStyle(color: chocolate, fontSize: 13, fontWeight: FontWeight.w600)),
            Text(admin['email']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Remove', style: TextStyle(color: Colors.red))),
          ],
          onSelected: (val) {
            if (val == 'edit') {
              _showEditAdminDialog(admin);
            } else if (val == 'delete') {

              // Implement delete logic here
            }
          },
        ),
      ),
    );
  }
  void deleteAdmin(int index) {
    setState(() {

      _subAdmins.removeAt(index);
    });
  }
}
