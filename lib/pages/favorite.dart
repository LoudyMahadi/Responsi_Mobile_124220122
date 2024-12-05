import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Box favoritesBox;
  late Box amiiboBox;
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    favoritesBox = Hive.box('favoritesBox'); // Open favorites box
    amiiboBox = Hive.box('amiiboBox'); // Open amiibo box to get data
  }

  // Function to remove favorite and show Snackbar with amiibo name
  void removeFavorite(String amiiboId) {
    setState(() {
      final amiiboData = amiiboBox.get('amiiboList')
          .firstWhere((amiibo) => amiibo['tail'] == amiiboId, orElse: () => null);
      if (amiiboData != null) {
        final amiiboName = amiiboData['name'];
        favoritesBox.delete(amiiboId); // Remove the favorite from the box

        // Show a Snackbar with the amiibo name
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$amiiboName removed from favorites')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds = favoritesBox.keys.toList(); // Get all IDs from the box

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Amiibo'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
         automaticallyImplyLeading: false,
      ),
      body: favoriteIds.isEmpty
          ? const Center(child: Text('No favorites added yet!'))
          : ListView.builder(
              itemCount: favoriteIds.length, // Item count based on the data
              itemBuilder: (context, index) {
                final amiiboId = favoriteIds[index];
                final amiiboData = amiiboBox.get('amiiboList')
                    .firstWhere((amiibo) => amiibo['tail'] == amiiboId,
                        orElse: () => null); // Get amiibo data from the box

                return amiiboData != null
                    ? Dismissible(
                        key: Key(amiiboId), // Key for Dismissible widget
                        direction: DismissDirection.endToStart, // Swipe left to remove
                        onDismissed: (direction) {
                          removeFavorite(amiiboId); // Remove item from favorites
                        },
                        background: Container(
                          color: Colors.red, // Background color when swiped
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: ListTile(
                          leading: Image.network(amiiboData['image']),
                          title: Text(amiiboData['name']),
                          subtitle: Text("Game Series: ${amiiboData['gameSeries']}"),
                        ),
                      )
                    : SizedBox(); // Show nothing if no data found
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
