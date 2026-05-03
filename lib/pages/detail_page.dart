import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/api_service.dart';

class DetailPage extends StatefulWidget {
  final String idMeal;

  // Menerima passing idMeal dari Home Page[cite: 1]
  const DetailPage({super.key, required this.idMeal});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Map<String, dynamic>> futureMealDetail;
  final _favoriteBox = Hive.box('favorites');
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Selalu fetch ulang data detail resep tiap page dibuka[cite: 1]
    futureMealDetail = ApiService.fetchMealDetail(widget.idMeal);
    _checkFavorite();
  }

  void _checkFavorite() {
    // Cek apakah id resep ini udah ada di Hive
    setState(() {
      _isFavorite = _favoriteBox.containsKey(widget.idMeal);
    });
  }

  void _toggleFavorite(Map<String, dynamic> mealData) {
    setState(() {
      if (_isFavorite) {
        // Hapus dari favorit jika udah ada[cite: 1]
        _favoriteBox.delete(widget.idMeal);
        _isFavorite = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dihapus dari Favorit')),
        );
      } else {
        // Simpan ke favorit, kita simpan Map datanya biar gampang ditampilin nanti
        _favoriteBox.put(widget.idMeal, {
          'idMeal': mealData['idMeal'],
          'strMeal': mealData['strMeal'],
          'strMealThumb': mealData['strMealThumb'],
        });
        _isFavorite = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disimpan ke Favorit')),
        );
      }
    });
  }

  // Helper buat ngegabungin Ingredient + Measure yang dipisah di API
  List<String> _getIngredients(Map<String, dynamic> data) {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      String? ingredient = data['strIngredient$i'];
      String? measure = data['strMeasure$i'];
      
      // Kalau datanya nggak kosong, masukin ke list
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add('${measure ?? ''} $ingredient'.trim());
      }
    }
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Resep'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureMealDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data nggak ketemu.'));
          }

          final meal = snapshot.data!;
          final ingredients = _getIngredients(meal);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Menampilkan Foto Resep[cite: 1]
                Image.network(
                  meal['strMealThumb'],
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Menampilkan Nama Resep[cite: 1]
                      Text(
                        meal['strMeal'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Menampilkan Kategori dan Asal Negara[cite: 1]
                      Row(
                        children: [
                          Chip(label: Text(meal['strCategory'] ?? 'N/A')),
                          const SizedBox(width: 8),
                          Chip(label: Text(meal['strArea'] ?? 'N/A')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Tombol Add/Remove Favorite, tampilan berubah sesuai state[cite: 1]
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFavorite ? Colors.red : Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                          label: Text(
                            _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () => _toggleFavorite(meal),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Text('Bahan-bahan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Menampilkan Daftar Bahan[cite: 1]
                      ...ingredients.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      )),
                      
                      const SizedBox(height: 24),
                      const Text('Cara Memasak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Menampilkan Instruksi Memasak[cite: 1]
                      Text(meal['strInstructions'] ?? 'Instruksi tidak tersedia.', style: const TextStyle(height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}