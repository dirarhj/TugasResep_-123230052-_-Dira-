import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'detail_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Panggil box yang udah kita open di main.dart
    final favoriteBox = Hive.box('favorites');

    return ValueListenableBuilder(
      valueListenable: favoriteBox.listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return const Center(child: Text('Belum ada resep favorit nih.'));
        }

        // Ambil semua value dari Hive dan ubah jadi list
        final favorites = box.values.toList();

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final meal = favorites[index];
            
            return GestureDetector(
              onTap: () {
                // Kalo diklik, passing idMeal ke Detail Page
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => DetailPage(idMeal: meal['idMeal']))
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Stack( // Pakai Stack biar tombol X (hapus) bisa numpuk di atas gambar
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              meal['strMealThumb'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            meal['strMeal'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    // Tombol hapus dari favorit di pojok kanan atas
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          box.delete(meal['idMeal']); // Hapus data dari Hive[cite: 1]
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dihapus dari Favorit')),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.close, size: 18, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}