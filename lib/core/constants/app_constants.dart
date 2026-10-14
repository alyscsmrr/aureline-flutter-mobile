import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const forest = Color(0xFF244A3D);
const deepForest = Color(0xFF203D32);
const ink = Color(0xFF2C4136);
const sage = Color(0xFF8A9978);
const gold = Color(0xFFB8A47A);
const cream = Color(0xFFFAFAF6);
const paleGreen = Color(0xFFF1F3E9);
const border = Color(0xFFE5E8DB);
const muted = Color(0xFF899580);
const heroImage =
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=2000&q=85';
const roomImages = [
  'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1000&q=85',
  'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=1000&q=85',
  'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1000&q=85',
  'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=1000&q=85',
];

class AppConfig {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';
}
