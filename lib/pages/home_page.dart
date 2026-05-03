import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/meal.dart';
import 'login_page.dart';
import 'detail_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Meal>> futureMeals;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Panggil API pas halaman pertama kali di-load
    futureMeals = ApiService.fetchMeals();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Nanti kita tambahin logic buat pindah ke Favorite Page di sini
  }

  void _handleLogout() async {
    await AuthService.logout(); // Hapus sesi dari SharedPreferences[cite: 1]
    if (!mounted) return;
    // Balik ke login page dan hapus semua history route sebelumnya[cite: 1]
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResepKu'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout, // Tombol logout wajib ada di AppBar[cite: 1]
          ),
        ],
      ),
      // Tampilan konten berubah tergantung tab yang dipilih
      // Tampilan konten berubah tergantung tab yang dipilih
      body: _selectedIndex == 0 ? _buildHomeContent() : const FavoritePage(),
      
      // Bottom Navigation Bar minimal 2 tab[cite: 1]
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
    return FutureBuilder<List<Meal>>(
      future: futureMeals,
      builder: (context, snapshot) {
        // Tampilkan indikator loading saat fetching data[cite: 1]
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Yah, resepnya kosong.'));
        }

        final meals = snapshot.data!;

        // Gunakan GridView untuk daftar resep[cite: 1]
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 kolom
            childAspectRatio: 0.8, // Biar card-nya agak tinggi
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(idMeal: meal.idMeal)));
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          meal.strMealThumb, // Menampilkan gambar[cite: 1]
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        meal.strMeal, // Menampilkan nama resep[cite: 1]
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
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