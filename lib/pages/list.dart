import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsi_124220122/pages/detail_page.dart';
import 'package:responsi_124220122/pages/favorite.dart';

class AmiiboListPage extends StatefulWidget {
  @override
  _AmiiboListPageState createState() => _AmiiboListPageState();
}

class _AmiiboListPageState extends State<AmiiboListPage> {
  List<dynamic> amiiboList = [];
  bool isLoading = true;
  late Box favoritesBox;
  late Box amiiboBox;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FavoritesPage(),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    favoritesBox = Hive.box('favoritesBox');
    amiiboBox = Hive.box('amiiboBox'); 
    fetchAmiiboData();
  }

  Future<void> fetchAmiiboData() async {
    if (amiiboBox.isNotEmpty) {
      setState(() {
        amiiboList = amiiboBox.get('amiiboList', defaultValue: []);
        isLoading = false;
      });
    } else {
      final String url = 'https://www.amiiboapi.com/api/amiibo/';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            amiiboList = data['amiibo'];
            isLoading = false;
          });
          amiiboBox.put('amiiboList', amiiboList);
        } else {
          throw Exception('Failed to load data. Status code: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("Error fetching data: $e");
      }
    }
  }

  bool isFavorite(String amiiboId) {
    return favoritesBox.get(amiiboId, defaultValue: false);
  }

  void toggleFavorite(String amiiboId, String amiiboName) {
    setState(() {
      if (isFavorite(amiiboId)) {
        favoritesBox.delete(amiiboId);
      } else {
        favoritesBox.put(amiiboId, true);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite(amiiboId) 
            ? '$amiiboName added to favorites!' 
            : '$amiiboName removed from favorites!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nintendo Amiibo List'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: amiiboList.length,
              itemBuilder: (context, index) {
                final amiibo = amiiboList[index];
                final amiiboId = amiibo['tail'];
                final amiiboName = amiibo['name'];

                return ListTile(
                  leading: Image.network(
                    amiibo['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(amiiboName),
                  subtitle: Text("Game Series: ${amiibo['gameSeries']}"),
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite(amiiboId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFavorite(amiiboId) ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      toggleFavorite(amiiboId, amiiboName);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AmiiboDetailPage(head: amiibo['head']),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 248, 255, 246),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 2, 47, 39),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
