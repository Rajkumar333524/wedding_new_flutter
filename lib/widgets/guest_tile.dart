import 'package:flutter/material.dart';
import '../models/guest.dart';

class GuestTile extends StatelessWidget {
  final Guest guest;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GuestTile({
    super.key,
    required this.guest,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final total = guest.given - guest.taken;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // 🧑 Name + Address
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.nameHi,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  guest.addressHi,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),

          // 💰 Given / Taken
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text("₹${guest.given}", style: const TextStyle(color: Colors.green)),
                Text("₹${guest.taken}", style: const TextStyle(color: Colors.orange)),
              ],
            ),
          ),

          // ⚖ Balance
          Expanded(
            flex: 1,
            child: Text(
              "₹$total",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: total >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ),

          // ✏🗑 Actions
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
