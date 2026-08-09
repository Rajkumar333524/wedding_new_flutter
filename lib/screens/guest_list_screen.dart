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

  const GuestListScreen({
    super.key,
    required this.wedding,
  });

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

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD GUESTS
  // ============================================================

  Future<void> _loadGuests() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    // ------------------------------------------------------------
    // 1. SHOW LOCAL DATA FIRST
    // ------------------------------------------------------------

    final local = HiveService.getGuestsByWedding(
      widget.wedding.id,
    );

    if (mounted) {
      setState(() {
        guests = local;
        filtered = local;
        loading = false;
      });
    }

    // ------------------------------------------------------------
    // 2. GET SERVER DATA
    // ------------------------------------------------------------

    try {
      final remote = await ApiService.getGuests(
        widget.wedding.id,
      );

      // Save/update remote data locally
      for (final guest in remote) {
        await HiveService.updateGuest(guest);
      }

      final merged = HiveService.getGuestsByWedding(
        widget.wedding.id,
      );

      if (!mounted) return;

      setState(() {
        guests = merged;
        filtered = merged;
      });
    } catch (e) {
      debugPrint(
        'Guest sync error: $e',
      );
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _filter(String text) {
    final q = text.trim().toLowerCase();

    setState(() {
      filtered = guests.where((guest) {
        return '${guest.nameEn} '
                '${guest.nameHi} '
                '${guest.addressEn} '
                '${guest.addressHi}'
            .toLowerCase()
            .contains(q);
      }).toList();
    });
  }

  // ============================================================
  // TOTAL AMOUNT
  // ============================================================

  double get totalAmount {
    return filtered.fold(
      0.0,
      (total, guest) => total + guest.given,
    );
  }

  // ============================================================
  // OPEN EDIT
  // ============================================================

  Future<void> _openEdit(Guest guest) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditGuestScreen(
          guest: guest,
        ),
      ),
    );

    if (result == true) {
      await _loadGuests();
    }
  }

  // ============================================================
  // DELETE GUEST
  // ============================================================

  Future<void> _deleteGuest(Guest guest) async {
    try {
      // Delete from local Hive using LOCAL ID
      await HiveService.deleteGuest(
        guest.localId,
      );

      // Delete from Django using BACKEND ID
      if (guest.backendId > 0) {
        await ApiService.deleteGuest(
          guest.backendId,
        );
      }

      await _loadGuests();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Delete failed: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: _topBar(),

        floatingActionButton:
            FloatingActionButton.extended(
          backgroundColor:
              const Color(0xFFD4AF37),
          elevation: 14,
          icon: const Icon(
            Icons.person_add,
            color: Colors.black,
          ),
          label: const Text(
            'नया मेहमान',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GuestFormScreen(
                  wedding: widget.wedding,
                ),
              ),
            );

            if (result == true) {
              await _loadGuests();
            }
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
                      ? const Center(
                          child:
                              CircularProgressIndicator(),
                        )
                      : _tableBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  PreferredSizeWidget _topBar() {
    return AppBar(
      backgroundColor:
          Colors.black.withOpacity(0.25),
      elevation: 0,
      title: const Text(
        'मेहमान सूची',
      ),
      centerTitle: true,
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: search,
        onChanged: _filter,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search,
          ),
          hintText: 'नाम / पता खोजें',
          filled: true,
          fillColor:
              Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summary() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Row(
        children: [
          SummaryCard(
            title: 'कुल मेहमान',
            value: filtered.length.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),

          SummaryCard(
            title: 'कुल राशि',
            value:
                '₹${totalAmount.toStringAsFixed(0)}',
            icon: Icons.currency_rupee,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _tableHeader() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: _card(),
      child: const Row(
        children: [
          Expanded(
            child: Text('नाम'),
          ),
          Expanded(
            child: Text('पता'),
          ),
          Expanded(
            child: Text('सगुन'),
          ),
          Expanded(
            child: Text('₹ दिया'),
          ),
          SizedBox(
            width: 100,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE BODY
  // ============================================================

  Widget _tableBody() {
    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'कोई मेहमान नहीं मिला',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final guest = filtered[i];

        return Container(
          margin:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          padding:
              const EdgeInsets.all(10),
          decoration: _card(),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  guest.nameHi.isNotEmpty
                      ? guest.nameHi
                      : guest.nameEn,
                ),
              ),

              Expanded(
                child: Text(
                  guest.addressHi.isNotEmpty
                      ? guest.addressHi
                      : guest.addressEn,
                ),
              ),

              Expanded(
                child: Text(
                  guest.giftHi.isNotEmpty
                      ? guest.giftHi
                      : guest.giftEn,
                ),
              ),

              Expanded(
                child: Text(
                  '₹${guest.given.toStringAsFixed(0)}',
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                onPressed: () =>
                    _openEdit(guest),
              ),

              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () =>
                    _deleteGuest(guest),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius:
          BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    );
  }
}