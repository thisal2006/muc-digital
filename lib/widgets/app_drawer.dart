import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          UserAccountsDrawerHeader(
            accountName: Text('MUC Digital'),
            accountEmail: Text('Maharagama Urban Council'),
            currentAccountPicture: CircleAvatar(child: Icon(Icons.eco)),
            decoration: BoxDecoration(color: Color(0xFF2E7D32)),
          ),
          ListTile(leading: Icon(Icons.person), title: Text('Profile')),
          ListTile(leading: Icon(Icons.history), title: Text('Booking History')),
          ListTile(leading: Icon(Icons.report), title: Text('My Complaints'), trailing: Badge(label: Text('2'))),
          ListTile(leading: Icon(Icons.emergency), title: Text('Emergency')),
          ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
          Divider(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
