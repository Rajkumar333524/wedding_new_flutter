import 'package:flutter/material.dart';
import '../models/wedding.dart';

class WeddingCard extends StatelessWidget {
  final Wedding wedding;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const WeddingCard({
    super.key,
    required this.wedding,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28, // 🔒 Fixed list item height
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // 🟦 Names Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      "${wedding.groomNameHi}  &  ${wedding.brideNameHi}",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Text(
                      "${wedding.groomNameEn} & ${wedding.brideNameEn}",
                      style: const TextStyle(fontSize: 9, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // 📅 Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                wedding.date,
                style: const TextStyle(fontSize: 9),
              ),
            ),

            // 👥 Open Button
            IconButton(
              onPressed: onOpen,
              icon: const Icon(Icons.people, size: 14),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxWidth: 28),
            ),

            // 🗑 Delete Button
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, size: 14, color: Colors.red),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxWidth: 28),
            ),
          ],
        ),
      ),
    );
  }
}
