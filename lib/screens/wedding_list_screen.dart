import 'package:flutter/material.dart';

import '../premium/export_screen.dart';
import '../rituals/ritual_home_screen.dart';
import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';
import '../models/wedding.dart';
import '../services/api_service.dart';
import '../services/export_service.dart';
import '../widgets/wedding_card.dart';

import '../widgets/action_button.dart';
import '../widgets/info_card.dart';
import '../widgets/search_box.dart';

import 'guest_list_screen.dart';

class WeddingListScreen extends StatefulWidget {
  const WeddingListScreen({super.key});

  @override
  State<WeddingListScreen> createState() => _WeddingListScreenState();
}

class _WeddingListScreenState extends State<WeddingListScreen> {
  List<Wedding> weddings = [];
  List<Wedding> filtered = [];

  final TextEditingController searchController = TextEditingController();
  bool loading = true;

  String currentUser = "Admin";
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadWeddings();
  }
    @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  Future<void>  loadWeddings() async {
     setState(() {
      loading = true;
    });

    try {
        weddings = await ApiService.getWeddings();

      filtered = weddings;

    } catch (e) {
     debugPrint(e.toString());

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content: Text(
              "Failed to load weddings\n$e",
            ),
          ),

        );

      }

    }

    if (mounted) {

      setState(() {
        loading = false;
      });

    }

  }

   void searchWedding(String value) {

    final text = value.toLowerCase();

    setState(() {

      filtered = weddings.where((item) {

        return item.groomNameHi
                .toLowerCase()
                .contains(text) ||

            item.brideNameHi
                .toLowerCase()
                .contains(text);

      }).toList();

    });

  }
    int get totalWedding {

    return weddings.length;

  }
     int get showingWedding {

    return filtered.length;

  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text("नया विवाह"),
          onPressed: () async {
            await Navigator.pushNamed(context, '/add-wedding');
            loadWeddings();
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
                    ? const Center( child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                        "Loading Wedding Data...",
                      ),
                    ],
                  ),
                )
                    : Column(
                        children: [

                          // HEADER
                         Container(
                          padding: const EdgeInsets.symmetric(
                           horizontal: 15,
                           vertical: 10,
                          ),
                           child: Row(
                           children: [

                            const Icon(
                                Icons.favorite,
                             color: Colors.red,
                             size: 32,
                            ),

                           const SizedBox(width: 12),

                           const Expanded(
                           child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                          Text(
                         "Wedding Register Pro",
                         style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                         color: Color(0xFFFFE0A3),
                        ),
                      ),

                       Text(
                       "Professional Wedding Management",
                       style: TextStyle(
                       fontSize: 12,
                       color: Colors.white70,
                      ),
                    ),

                  ],
               ),
            ),

             Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [

              Text(
              currentUser,
              style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            "${now.day}/${now.month}/${now.year}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),

        ],
      )

    ],
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
                                  ActionButton(
                                  icon: Icons.refresh,
                                   title: "Reload",
                                    onPressed: loadWeddings,
                                   ),
                                  ActionButton(
                                    icon: Icons.auto_awesome,
                                    title: "Rituals",
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RitualHomeScreen()));
                                    },
                                  ),
                                  ActionButton(
                                    icon: Icons.workspace_premium,
                                    title: "Export",
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen()));
                                    },
                                  ),
                                  ActionButton(
                                    icon: Icons.table_chart,
                                    title: "Excel",
                                    onPressed: () {
                                      ExportService.exportWeddingsToExcel(weddings);
                                    },
                                  ),
                                  ActionButton(
                                    icon: Icons.picture_as_pdf,
                                    title: "PDF",
                                    onPressed: () {
                                      if (weddings.isNotEmpty) {
                                        ExportService.exportWeddingPdf(weddings.first);
                                      }
                                    },
                                  ),
                                  ActionButton(
                                    icon: Icons.print,
                                    title: "Print",
                                    onPressed: () {
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
                            child: SearchBox(
                              controller: searchController,
                              onChanged:  searchWedding,
                              hint: "विवाह खोजें...",
                            ),
                          ),

                          const SizedBox(height: 4), // 🔧 reduced

                          // SUMMARY
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                 InfoCard(
                                  title: "Total Wedding",
                                  value: totalWedding.toString(),
                                   icon: Icons.favorite,
                                    color: Colors.red,
                                     ),
                                     const SizedBox(width: 10),
                                     InfoCard(
                                      title: "Showing",
                                       value: showingWedding.toString(),
                                       icon: Icons.visibility,
                                        color: Colors.green,
                                     ),
                              ],
                            ),
                          ),

                          // LIST
                          Expanded(
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: filtered.isEmpty
                             ? const Center(
                              child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                             Icon(
                             Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                          ),
                             SizedBox(height: 10),
                             Text(
                             "No Wedding Found",
                              style: TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ],
                     ),
                   )
                   : ListView.builder(
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
                                        loadWeddings();
                                      },
                                      onDelete: () async {
                                        await ApiService.deleteWedding(w.id);
                                        loadWeddings();
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
          child: Text("Wedding Register Pro v2 • Developed by Raj Kumar Pal", style: TextStyle(color: Colors.white)),
        ),
      );
}
