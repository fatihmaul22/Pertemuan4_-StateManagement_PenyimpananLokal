import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _favController =
      TextEditingController(); // Untuk Latihan 3[cite: 16]

  @override
  void initState() {
    super.initState();
    final provider = context.read<UserProvider>();
    _nameController = TextEditingController(text: provider.user.name);
    _emailController = TextEditingController(text: provider.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      // Latihan 5: Validasi Keamanan (Cek karakter berbahaya pada nama)[cite: 17]
      if (name.contains('<script>') || name.contains('DROP TABLE')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama mengandung karakter berbahaya!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Latihan 5: Validasi Keamanan (Simulasi email sudah digunakan sistem)[cite: 17]
      // Logika diubah agar error pasti muncul saat mengetikkan f.maulana@students.amikom.ac.id2
      if (email == 'f.maulana@students.amikom.ac.id2') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sudah digunakan sistem!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = context.read<UserProvider>();
      final updatedUser = provider.user.copyWith(
        name: name,
        email: email,
        isLoggedIn: true,
      );
      await provider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (provider.user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Profil'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const Divider(height: 40),

                    // Latihan 3: Daftar Favorit[cite: 16]
                    const Text(
                      'Daftar Favorit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _favController,
                            decoration: const InputDecoration(
                              hintText: 'Tambah favorit baru',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.deepPurple,
                            size: 36,
                          ),
                          onPressed: () {
                            if (_favController.text.isNotEmpty) {
                              provider.addFavorite(_favController.text);
                              _favController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.favorites.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(provider.favorites[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => provider.removeFavorite(
                                provider.favorites[index],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
