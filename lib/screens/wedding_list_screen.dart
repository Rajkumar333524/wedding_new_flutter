import 'package:flutter/material.dart';
import '../premium/export_screen.dart';
import '../rituals/ritual_home_screen.dart';
import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';
import '../models/wedding.dart';
import '../services/api_service.dart';
import '../services/export_service.dart';
import '../widgets/wedding_card.dart';
import 'guest_list_screen.dart';

class WeddingListScreen extends StatefulWidget {
  const WeddingListScreen({super.key});

  @override
  State<WeddingListScreen> createState() => _WeddingListScreenState();
}

class _WeddingListScreenState extends State<WeddingListScreen> {
  List<Wedding> weddings = [];
  List<Wedding> filtered = [];

  final TextEditingController search = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    try {
      final data = await ApiService.getWeddings();
      if (!mounted) return;
      weddings = data;
      filtered = data;
    } catch (e) {
      debugPrint("Wedding load error: $e");
    }

    if (mounted) setState(() => loading = false);
  }

  void _filter(String text) {
    final t = text.toLowerCase();
    setState(() {
      filtered = weddings.where((w) {
        final name = "${w.groomNameHi} ${w.brideNameHi}".toLowerCase();
        return name.contains(t);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text("नया विवाह"),
          onPressed: () async {
            await Navigator.pushNamed(context, '/add-wedding');
            _load();
          },
        ),

        bottomNavigationBar: _footer(),

        body: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: 800,
              height: 400,
              child: GlassPanel(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [

                          // HEADER
                          Container(
                            height: 60, // 🔧 reduced
                            alignment: Alignment.center,
                            child: const Text(
                              "शुभ विवाह रजिस्टर",
                              style: TextStyle(
                                fontSize: 16, // 🔧 reduced
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFE0A3),
                                shadows: [
                                  Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 3)
                                ],
                              ),
                            ),
                          ),

                          const Divider(height: 1),

                          // ACTION BUTTONS
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4), // 🔧 reduced
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _btn(Icons.refresh, "Reload", _load),
                                  _btn(Icons.auto_awesome, "Rituals", () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RitualHomeScreen()));
                                  }),
                                  _btn(Icons.workspace_premium, "Export", () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen()));
                                  }),
                                  _btn(Icons.table_chart, "Excel", () {
                                    ExportService.exportWeddingsToExcel(weddings);
                                  }),
                                  _btn(Icons.picture_as_pdf, "PDF", () {
                                    if (weddings.isNotEmpty) {
                                      ExportService.exportWeddingPdf(weddings.first);
                                    }
                                  }),
                                  _btn(Icons.print, "Print", () {
                                    if (weddings.isNotEmpty) {
                                      ExportService.printWedding(weddings.first);
                                    }
                                  }),
                                ],
                              ),
                            ),
                          ),

                          // SEARCH
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: search,
                              onChanged: _filter,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search, size: 12), // 🔧 reduced
                                hintText: "विवाह खोजें...",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 6), // 🔧 reduced
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 4), // 🔧 reduced

                          // SUMMARY
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _info("कुल विवाह", weddings.length.toString()),
                                _info("दिखाये गये", filtered.length.toString()),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4), // 🔧 reduced

                          // LIST
                          Expanded(
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                itemCount: filtered.length,
                                itemBuilder: (context, i) {
                                  final w = filtered[i];
                                  return SizedBox(
                                    height: 28, // 🔥 PERFECT COMPACT HEIGHT
                                    child: WeddingCard(
                                      wedding: w,
                                      onOpen: () async {
                                        await Navigator.push(context, MaterialPageRoute(builder: (_) => GuestListScreen(wedding: w)));
                                        _load();
                                      },
                                      onDelete: () async {
                                        await ApiService.deleteWedding(w.id);
                                        _load();
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(IconData i, String t, VoidCallback f) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton.icon(
          icon: Icon(i, size: 14), // 🔧 reduced
          label: Text(t, style: const TextStyle(fontSize: 11)), // 🔧 reduced
          onPressed: f,
          style: ElevatedButton.styleFrom(
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), // 🔧 reduced
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );

  Widget _info(String t, String v) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // 🔧 reduced
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xffD4AF37), Color(0xffC0C0C0)]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Column(children: [
          Text(t, style: const TextStyle(fontSize: 10)), // 🔧 reduced
          Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), // 🔧 reduced
        ]),
      );

  Widget _footer() => Container(
        height: 34, // 🔧 reduced
        color: Colors.brown.shade700,
        child: const Center(
          child: Text("Wedding Register App • Powered by You", style: TextStyle(color: Colors.white)),
        ),
      );
}
