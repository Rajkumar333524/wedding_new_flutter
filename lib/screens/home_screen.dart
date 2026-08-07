import 'package:flutter/material.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

import '../services/api_service.dart';
import '../models/wedding.dart';
import 'wedding_list_screen.dart';
import 'add_wedding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Wedding> weddings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await ApiService.getWeddings();
    if (!mounted) return;
    setState(() {
      weddings = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.30),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Wedding Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loadData,
            ),
          ],
        ),

        body: Center(
          child: GlassPanel(
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        // 📊 STATS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statCard("Total", weddings.length.toString(),
                                Icons.favorite, Colors.pink),
                            _statCard("Active", weddings.length.toString(),
                                Icons.people, Colors.blue),
                            _statCard("Completed", "0",
                                Icons.done_all, Colors.green),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 🧭 MAIN ACTION BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: _glassButton(
                                icon: Icons.list,
                                label: "All Weddings",
                                color: const Color(0xFF6A1B9A),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const WeddingListScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _glassButton(
                                icon: Icons.add_circle,
                                label: "New Wedding",
                                color: const Color(0xFFD4AF37), // Gold
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AddWeddingScreen(),
                                    ),
                                  ).then((_) => loadData());
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 🧾 RECENT WEDDINGS
                        Expanded(
                          child: ListView.builder(
                            itemCount: weddings.length,
                            itemBuilder: (context, i) {
                              return _recentCard(weddings[i]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ==================== UI COMPONENTS ====================

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 104,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 18, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _recentCard(Wedding w) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 12),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.favorite, color: Colors.pink),
        title: Text(
          "${w.brideNameHi} ❤ ${w.groomNameHi}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(w.location),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WeddingListScreen()),
          );
        },
      ),
    );
  }
}
