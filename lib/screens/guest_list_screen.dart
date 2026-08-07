import 'dart:ui';
import 'package:flutter/material.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

import '../models/guest.dart';
import '../models/wedding.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';

import 'guest_form_screen.dart';
import 'edit_guest_screen.dart';
import '../widgets/summary_card.dart';

class GuestListScreen extends StatefulWidget {
  final Wedding wedding;
  const GuestListScreen({super.key, required this.wedding});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  List<Guest> guests = [];
  List<Guest> filtered = [];
  bool loading = true;

  final TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  // 🧠 FINAL OFFLINE-FIRST + SAFE SYNC
  Future<void> _loadGuests() async {
    if (!mounted) return;

    setState(() => loading = true);

    // 1️⃣ SHOW LOCAL DATA FIRST
    final local = HiveService.getGuestsByWedding(widget.wedding.id);
    setState(() {
      guests = local;
      filtered = local;
      loading = false;
    });

    // 2️⃣ GET SERVER DATA & OVERWRITE LOCAL
    try {
      final remote = await ApiService.getGuests(widget.wedding.id);

      for (final g in remote) {
        await HiveService.updateGuest(g); // 🔥 Always overwrite
      }

      final merged = HiveService.getGuestsByWedding(widget.wedding.id);

      if (!mounted) return;
      setState(() {
        guests = merged;
        filtered = merged;
      });
    } catch (e) {
      debugPrint("Sync error: $e");
    }
  }

  void _filter(String text) {
    final q = text.toLowerCase();
    setState(() {
      filtered = guests.where((g) {
        return "${g.nameEn} ${g.nameHi} ${g.addressEn} ${g.addressHi}"
            .toLowerCase()
            .contains(q);
      }).toList();
    });
  }

  double get totalAmount => filtered.fold(0, (t, g) => t + g.given);

  Future<void> _openEdit(Guest g) async {
    final ok = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditGuestScreen(guest: g)),
    );
    if (ok == true) _loadGuests();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _topBar(),

        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFD4AF37),
          elevation: 14,
          icon: const Icon(Icons.person_add, color: Colors.black),
          label: const Text("नया मेहमान", style: TextStyle(color: Colors.black)),
          onPressed: () async {
            final ok = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GuestFormScreen(wedding: widget.wedding),
              ),
            );
            if (ok == true) _loadGuests();
          },
        ),

        body: Center(
          child: GlassPanel(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _searchBar(),
                _summary(),
                const SizedBox(height: 8),
                _tableHeader(),

                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : _tableBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── UI ─────────

  PreferredSizeWidget _topBar() => AppBar(
        backgroundColor: Colors.black.withOpacity(0.25),
        elevation: 0,
        title: const Text("मेहमान सूची"),
        centerTitle: true,
      );

  Widget _searchBar() => Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          controller: search,
          onChanged: _filter,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: "नाम / पता खोजें",
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );

  Widget _summary() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            SummaryCard(
              title: "कुल मेहमान",
              value: filtered.length.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
            SummaryCard(
              title: "कुल राशि",
              value: "₹${totalAmount.toStringAsFixed(0)}",
              icon: Icons.currency_rupee,
              color: Colors.green,
            ),
          ],
        ),
      );

  Widget _tableHeader() => Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: _card(),
        child: const Row(
          children: [
            Expanded(child: Text("नाम")),
            Expanded(child: Text("पता")),
            Expanded(child: Text("सगुन")),
            Expanded(child: Text("₹ दिया")),
            SizedBox(width: 60),
          ],
        ),
      );

  Widget _tableBody() => ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final g = filtered[i];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: _card(),
            child: Row(
              children: [
                Expanded(child: Text(g.nameHi)),
                Expanded(child: Text(g.addressHi)),
                Expanded(child: Text(g.giftHi)),
                Expanded(child: Text("₹${g.given}")),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _openEdit(g),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await HiveService.deleteGuest(g.id);
                    await ApiService.deleteGuest(g.id);
                    _loadGuests();
                  },
                ),
              ],
            ),
          );
        },
      );

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))
        ],
      );
}
