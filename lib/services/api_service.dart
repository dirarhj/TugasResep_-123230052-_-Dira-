import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<Meal>> fetchMeals() async {
    // Endpoint nge-filter berdasarkan kategori Seafood
    final response = await http.get(Uri.parse('$baseUrl/filter.php?c=Seafood'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List meals = data['meals'];
      return meals.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Gagal nge-load resep nih, bro');
    }
  }

  // Tambahin ini di bawah fungsi fetchMeals()
  static Future<Map<String, dynamic>> fetchMealDetail(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // Endpoint detail balikin array 'meals', kita ambil index 0 karena isinya pasti cuma 1 resep
      return data['meals'][0]; 
    } else {
      throw Exception('Duh, gagal narik detail resep nih.');
    }
  }
}