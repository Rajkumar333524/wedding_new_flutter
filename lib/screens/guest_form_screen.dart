import 'package:flutter/material.dart';

import '../models/guest.dart';
import '../models/wedding.dart';
import '../services/api_service.dart';
import '../services/translator_service.dart';
import '../services/hive_service.dart';

import '../ui/background_wrapper.dart';
import '../ui/glass_panel.dart';

class GuestFormScreen extends StatefulWidget {
  final Wedding wedding;

  const GuestFormScreen({
    super.key,
    required this.wedding,
  });

  @override
  State<GuestFormScreen> createState() =>
      _GuestFormScreenState();
}

class _GuestFormScreenState
    extends State<GuestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  bool showShubhLabhText = false;

  final nameEnCtrl = TextEditingController();
  final addressEnCtrl = TextEditingController();
  final giftEnCtrl = TextEditingController();
  final givenCtrl = TextEditingController();

  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();
  final f4 = FocusNode();

  bool saving = false;

  // ============================================================
  // SAVE GUEST
  // ============================================================

  Future<void> saveGuest() async {
    if (saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      // ----------------------------------------------------------
      // CLEAN INPUT
      // ----------------------------------------------------------

      final nameEn = nameEnCtrl.text.trim();
      final addressEn = addressEnCtrl.text.trim();
      final giftEn = giftEnCtrl.text.trim();

      final given =
          double.tryParse(
                givenCtrl.text.trim(),
              ) ??
              0;

      // ----------------------------------------------------------
      // TRANSLATION
      // ----------------------------------------------------------

      final nameHi =
          await TranslatorService.smartTranslate(
        nameEn,
      );

      final addressHi =
          await TranslatorService.smartTranslate(
        addressEn,
      );

      final giftHi =
          await TranslatorService.smartTranslate(
        giftEn,
      );

      // ----------------------------------------------------------
      // CREATE LOCAL GUEST
      // ----------------------------------------------------------

      final localId =
          DateTime.now().millisecondsSinceEpoch;

      final guest = Guest(
        localId: localId,

        // New guest doesn't have a backend ID yet.
        backendId: 0,

        weddingId: widget.wedding.id,

        nameEn: nameEn,
        nameHi: nameHi,

        addressEn: addressEn,
        addressHi: addressHi,

        giftEn: giftEn,
        giftHi: giftHi,

        given: given,

        // New guest starts with zero taken amount.
        taken: 0,

        type: 'Given',

        date: DateTime.now(),
      );

      // ----------------------------------------------------------
      // SAVE LOCAL FIRST
      // ----------------------------------------------------------

      await HiveService.addGuest(guest);

      // ----------------------------------------------------------
      // BACKEND SYNC
      // ----------------------------------------------------------

      try {
         final syncedGuest = await ApiService.addGuest(guest);

        await HiveService.updateGuest(syncedGuest);
      } catch (e) {
        // Keep local data if backend is unavailable.
        debugPrint(
          'Guest backend sync failed: $e',
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameEnCtrl.dispose();
    addressEnCtrl.dispose();
    giftEnCtrl.dispose();
    givenCtrl.dispose();

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

        appBar: _religiousHeader(),

        body: Center(
          child: GlassPanel(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(22),
                decoration: _card(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'मेहमान जानकारी',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // NAME
                      _field(
                        'Name (नाम)',
                        nameEnCtrl,
                        f1,
                        f2,
                      ),

                      // ADDRESS
                      _field(
                        'Address (पता)',
                        addressEnCtrl,
                        f2,
                        f3,
                      ),

                      // GIFT
                      _field(
                        'Gift (सगुन)',
                        giftEnCtrl,
                        f3,
                        f4,
                      ),

                      // GIVEN
                      _field(
                        'Given ₹',
                        givenCtrl,
                        f4,
                        null,
                        number: true,
                        isLast: true,
                      ),

                      const SizedBox(height: 24),

                      // SAVE BUTTON
                      saving
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child:
                                  ElevatedButton(
                                style:
                                    _btnStyle(),
                                onPressed:
                                    saveGuest,
                                child:
                                    const Text(
                                  'Save Guest',
                                  style:
                                      TextStyle(
                                    fontSize: 16,
                                  ),
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
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  PreferredSizeWidget _religiousHeader() {
    return PreferredSize(
      preferredSize:
          const Size.fromHeight(55),
      child: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: showShubhLabhText
              ? const Center(
                  child: Text(
                    '🕉 श्री गणेशाय नमः',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  // ============================================================
  // FORM FIELD
  // ============================================================

  Widget _field(
    String label,
    TextEditingController controller,
    FocusNode current,
    FocusNode? next, {
    bool number = false,
    bool isLast = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        focusNode: current,
        keyboardType: number
            ? TextInputType.number
            : TextInputType.text,
        textInputAction: isLast
            ? TextInputAction.done
            : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (isLast) {
            saveGuest();
          } else if (next != null) {
            FocusScope.of(context)
                .requestFocus(next);
          }
        },
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Required';
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
        decoration: _input(label),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _input(
    String label,
  ) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor:
          Colors.white.withOpacity(0.88),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
    );
  }

  // ============================================================
  // BUTTON STYLE
  // ============================================================

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor:
          const Color(0xff1976d2),
      padding:
          const EdgeInsets.symmetric(
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      elevation: 10,
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  BoxDecoration _card() {
    return BoxDecoration(
      color:
          Colors.white.withOpacity(0.88),
      borderRadius:
          BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 15,
        ),
      ],
    );
  }
}