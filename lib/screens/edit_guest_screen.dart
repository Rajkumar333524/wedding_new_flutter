import 'package:flutter/material.dart';

import '../models/guest.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import '../services/translator_service.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

class EditGuestScreen extends StatefulWidget {
  final Guest guest;

  const EditGuestScreen({
    super.key,
    required this.guest,
  });

  @override
  State<EditGuestScreen> createState() =>
      _EditGuestScreenState();
}

class _EditGuestScreenState
    extends State<EditGuestScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameEn;
  late final TextEditingController addressEn;
  late final TextEditingController giftEn;
  late final TextEditingController given;

  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();
  final f4 = FocusNode();

  bool loading = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    nameEn = TextEditingController(
      text: widget.guest.nameEn,
    );

    addressEn = TextEditingController(
      text: widget.guest.addressEn,
    );

    giftEn = TextEditingController(
      text: widget.guest.giftEn,
    );

    given = TextEditingController(
      text: widget.guest.given.toString(),
    );
  }

  // ============================================================
  // UPDATE GUEST
  // ============================================================

  Future<void> updateGuest() async {
    if (loading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // ----------------------------------------------------------
      // CLEAN VALUES
      // ----------------------------------------------------------

      final name = nameEn.text.trim();
      final address = addressEn.text.trim();
      final gift = giftEn.text.trim();

      final amount =
          double.tryParse(
                given.text.trim(),
              ) ??
              0;

      // ----------------------------------------------------------
      // TRANSLATE
      // ----------------------------------------------------------

      final nameHi =
          await TranslatorService.smartTranslate(
        name,
      );

      final addressHi =
          await TranslatorService.smartTranslate(
        address,
      );

      final giftHi =
          await TranslatorService.smartTranslate(
        gift,
      );

      // ----------------------------------------------------------
      // CREATE UPDATED GUEST
      // ----------------------------------------------------------

      final updated = Guest(
        // 🔵 Keep existing Hive ID
        localId: widget.guest.localId,

        // 🟢 Keep existing Django ID
        backendId: widget.guest.backendId,

        weddingId: widget.guest.weddingId,

        nameEn: name,
        nameHi: nameHi,

        addressEn: address,
        addressHi: addressHi,

        giftEn: gift,
        giftHi: giftHi,

        given: amount,

        // Keep existing taken amount
        taken: widget.guest.taken,

        type: widget.guest.type,

        date: widget.guest.date,
      );

      // ----------------------------------------------------------
      // LOCAL UPDATE FIRST
      // ----------------------------------------------------------

      await HiveService.updateGuest(
        updated,
      );

      // ----------------------------------------------------------
      // BACKEND UPDATE
      // ----------------------------------------------------------

      if (updated.backendId > 0) {
        await ApiService.updateGuest(
          updated,
        );
      }

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Update failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameEn.dispose();
    addressEn.dispose();
    giftEn.dispose();
    given.dispose();

    f1.dispose();
    f2.dispose();
    f3.dispose();
    f4.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text(
            'Edit Guest',
          ),
          backgroundColor:
              Colors.black.withOpacity(0.25),
          elevation: 0,
        ),

        body: Center(
          child: GlassPanel(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(24),
                decoration: _card(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        '✏️ Update Guest',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _field(
                        'Name',
                        nameEn,
                        f1,
                        f2,
                      ),

                      _field(
                        'Address',
                        addressEn,
                        f2,
                        f3,
                      ),

                      _field(
                        'Gift',
                        giftEn,
                        f3,
                        f4,
                      ),

                      _field(
                        'Given Amount',
                        given,
                        f4,
                        null,
                        number: true,
                        last: true,
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: _goldButton(
                              loading
                                  ? 'Saving...'
                                  : 'Update',
                              Icons.save,
                              loading
                                  ? null
                                  : updateGuest,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _silverButton(
                              'Cancel',
                              Icons.close,
                              () {
                                if (!loading) {
                                  Navigator.pop(
                                    context,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FIELD
  // ============================================================

  Widget _field(
    String label,
    TextEditingController controller,
    FocusNode current,
    FocusNode? next, {
    bool number = false,
    bool last = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        focusNode: current,
        keyboardType: number
            ? TextInputType.number
            : TextInputType.text,
        textInputAction: last
            ? TextInputAction.done
            : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (last) {
            updateGuest();
          } else if (next != null) {
            FocusScope.of(context)
                .requestFocus(next);
          }
        },
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return '$label required';
          }

          if (number &&
              double.tryParse(
                    value.trim(),
                  ) ==
                  null) {
            return 'Enter valid amount';
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
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
  // GOLD BUTTON
  // ============================================================

  Widget _goldButton(
    String text,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        elevation: 18,
        shadowColor: Colors.amberAccent,
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // SILVER BUTTON
  // ============================================================

  Widget _silverButton(
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            const Color(0xFFBDC3C7),
        foregroundColor: Colors.black,
        elevation: 14,
        shadowColor: Colors.white70,
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  BoxDecoration _card() {
    return BoxDecoration(
      color:
          Colors.white.withOpacity(0.92),
      borderRadius:
          BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
    );
  }
}