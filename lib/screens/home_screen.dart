import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Latihan 1: Toggle Dark Mode di AppBar[cite: 16]
          Row(
            children: [
              Icon(provider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              Switch(
                value: provider.isDarkMode,
                onChanged: (value) => context.read<UserProvider>().toggleTheme(value),
              ),
            ],
          )
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, size: 80, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 24),
                    Text(
                      provider.user.isLoggedIn
                          ? 'Selamat datang, ${provider.user.name}!'
                          : 'Selamat datang, Tamu!',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Latihan 2: Menampilkan Counter Kunjungan[cite: 16]
                    Text(
                      'Aplikasi dibuka sebanyak: ${provider.visitCount} kali',
                      style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 16),
                    if (provider.user.isLoggedIn) ...[
                      Text('Email: ${provider.user.email}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('Lihat Profil'),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Login / Daftar'),
                      ),
                    ]
                  ],
                ),
              ),
            ),
    );
  }
}