// search_screen.dart
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State {
  TextEditingController _controller = TextEditingController();
  String _searchText = '';
  List _users = [
    'User 1',
    'User 2',
    'User 3',
    'User 4',
    'User 5',
  ];
  List _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers.addAll(_users);
    _controller.addListener(() {
      setState(() {
        _searchText = _controller.text;
        _filterUsers();
      });
    });
  }

  void _filterUsers() {
    _filteredUsers = _users.where((user) {
      return user.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value;
              _filterUsers();
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Perform search action based on _searchText
              print('Searching for: $_searchText');
              // Example: Navigate to a new screen to display search results
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchResultScreen(users: _filteredUsers),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredUsers.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_filteredUsers[index]),
            onTap: () {
              // Example action when tapping on a user in the list
              print('Tapped on user: ${_filteredUsers[index]}');
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SearchResultScreen extends StatelessWidget {
  final List users;

  const SearchResultScreen({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(users[index]),
            onTap: () {
              // Example action when tapping on a user in the search results
              print('Tapped on user in search results: ${users[index]}');
            },
          );
        },
      ),
    );
  }
}
