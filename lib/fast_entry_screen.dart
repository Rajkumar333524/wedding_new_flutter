import 'package:flutter/material.dart';

class FastEntryScreen extends StatefulWidget {
  final int weddingId;

  const FastEntryScreen({
    super.key,
    required this.weddingId,
  });

  @override
  State<FastEntryScreen> createState() => _FastEntryScreenState();
}

class _FastEntryScreenState extends State<FastEntryScreen> {
  // ================= Controllers =================

  final nameController = TextEditingController();
  final villageController = TextEditingController();
  final mobileController = TextEditingController();
  final amountController = TextEditingController();
  final giftController = TextEditingController();
  final remarkController = TextEditingController();

  // ================= Focus Nodes =================

  final nameFocus = FocusNode();
  final villageFocus = FocusNode();
  final mobileFocus = FocusNode();
  final amountFocus = FocusNode();
  final giftFocus = FocusNode();
  final remarkFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        nameFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    villageController.dispose();
    mobileController.dispose();
    amountController.dispose();
    giftController.dispose();
    remarkController.dispose();

    nameFocus.dispose();
    villageFocus.dispose();
    mobileFocus.dispose();
    amountFocus.dispose();
    giftFocus.dispose();
    remarkFocus.dispose();

    super.dispose();
  }

  void clearForm() {
    nameController.clear();
    villageController.clear();
    mobileController.clear();
    amountController.clear();
    giftController.clear();
    remarkController.clear();

    nameFocus.requestFocus();
  }

  Future<void> saveGuest() async {
    if (nameController.text.trim().isEmpty) {
      nameFocus.requestFocus();
      return;
    }

    // TODO:
    // Yahan ApiService.addGuest() call hoga.
    // Abhi UI test kar rahe hain.

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Guest Saved Successfully"),
        duration: Duration(seconds: 1),
      ),
    );

    clearForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: const Text("Fast Guest Entry"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            TextField(
              autofocus: true,
              controller: nameController,
              focusNode: nameFocus,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Guest Name",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                villageFocus.requestFocus();
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: villageController,
              focusNode: villageFocus,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Village",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                mobileFocus.requestFocus();
              },
            ),

            const SizedBox(height: 12),

            TextField(
              maxLength: 10,
              controller: mobileController,
              focusNode: mobileFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Mobile",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                amountFocus.requestFocus();
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: amountController,
              focusNode: amountFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                giftFocus.requestFocus();
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: giftController,
              focusNode: giftFocus,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: "Gift",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                remarkFocus.requestFocus();
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: remarkController,
              focusNode: remarkFocus,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: "Remark",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) async {
                await saveGuest();
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Guest",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () async {
                  await saveGuest();
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
