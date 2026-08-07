import 'package:flutter/material.dart';
import '../rituals/ritual_service.dart';



class PaupujiRegisterScreen extends StatefulWidget {
  const PaupujiRegisterScreen({super.key});

  @override
  State<PaupujiRegisterScreen> createState() => _PaupujiRegisterScreenState();
}

class _PaupujiRegisterScreenState extends State<PaupujiRegisterScreen> {

  List<Map<String, dynamic>> rows = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    rows = await RitualService.loadPaupuji();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paupuji Register")),
      body: ListView.builder(
        itemCount: rows.length,
        itemBuilder: (c, i) {
          final r = rows[i];
          return ListTile(
            title: Text(r['name']),
            subtitle: Text("${r['item']}  ₹${r['money']}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await RitualService.deletePaupuji(i);
                load();
              },
            ),
          );
        },
      ),
    );
  }
}
