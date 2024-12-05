import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class AmiiboDetailPage extends StatefulWidget {
  final String head;

  const AmiiboDetailPage({Key? key, required this.head}) : super(key: key);

  @override
  _AmiiboDetailPageState createState() => _AmiiboDetailPageState();
}

class _AmiiboDetailPageState extends State<AmiiboDetailPage> {
  late Map<String, dynamic> amiibo;
  bool _isLoading = true;
  late Box favoritesBox;

  @override
  void initState() {
    super.initState();
    fetchAmiiboDetails();
    favoritesBox = Hive.box('favoritesBox'); 
  }

  Future<void> fetchAmiiboDetails() async {
    final url = Uri.parse('https://www.amiiboapi.com/api/amiibo/?head=${widget.head}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          amiibo = data['amiibo'][0];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load amiibo details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  bool isFavorite(String amiiboId) {
    return favoritesBox.get(amiiboId, defaultValue: false);
  }

  void toggleFavorite(String amiiboId) {
    setState(() {
      if (isFavorite(amiiboId)) {
        favoritesBox.delete(amiiboId);  
      } else {
        favoritesBox.put(amiiboId, true);  
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amiibo Details'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite(amiibo['tail']) ? Icons.favorite : Icons.favorite_border,
              color: isFavorite(amiibo['tail']) ? Colors.red : Colors.white,
            ),
            onPressed: () {
              toggleFavorite(amiibo['tail']);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  amiibo['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10), 
                          child: Image.network(
                            amiibo['image'],
                            width: double.infinity,
                            fit: BoxFit.contain,  
                          ),
                        )
                      : const Center(child: Icon(Icons.image, size: 100)),
                  const SizedBox(height: 16),
                  Text(
                    amiibo['character'] ?? 'Character Unknown',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Name: ${amiibo['name'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Game Series: ${amiibo['gameSeries'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Amiibo Series: ${amiibo['amiiboSeries'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Type: ${amiibo['type'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Release Dates:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('NA: ${amiibo['release']?['na'] ?? 'Not Available'}'),
                  Text('JP: ${amiibo['release']?['jp'] ?? 'Not Available'}'),
                  Text('EU: ${amiibo['release']?['eu'] ?? 'Not Available'}'),
                  Text('AU: ${amiibo['release']?['au'] ?? 'Not Available'}'),
                ],
              ),
            ),
    );
  }
}
