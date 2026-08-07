import 'package:flutter/material.dart';
import '../rituals/ritual_service.dart';

class GroomRegisterScreen extends StatefulWidget {
  const GroomRegisterScreen({super.key});

  @override
  State<GroomRegisterScreen> createState() => _GroomRegisterScreenState();
}

class _GroomRegisterScreenState extends State<GroomRegisterScreen> {

  List<Map<String, dynamic>> rows = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    rows = await RitualService.loadGroom();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Groom Gifts Register")),
      body: ListView.builder(
        itemCount: rows.length,
        itemBuilder: (c, i) {
          final r = rows[i];
          return ListTile(
            title: Text(r['name']),
            subtitle: Text("${r['gift']}  ₹${r['money']}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await RitualService.deleteGroom(i);
                load();
              },
            ),
          );
        },
      ),
    );
  }
}
