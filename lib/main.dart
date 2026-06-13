// [KODE LENGKAP YANG SUDAH KITA KUNCI]
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: WarehouseApp()));

class WarehouseApp extends StatefulWidget {
  @override
  _WarehouseAppState createState() => _WarehouseAppState();
}

class _WarehouseAppState extends State<WarehouseApp> with SingleTickerProviderStateMixin {
  final String webAppUrl = "https://script.google.com/macros/s/AKfycbz1y8aIwpttmGMNlcU9YNScm3TZkUwLikHXgMuYzb2NyIV-yRYMSGKPmbQTcUSKcHKh/exec";
  late AnimationController _animCtrl;
  List<String> history = [];
  final List<String> daftarTujuan = ["- Pilih Tujuan -", "Pemakaian gudang B3", "Provide ke site", "Spill team support"];

  List<Map<String, dynamic>> items = [
    {"name": "JUMBO BAG", "stock": 0, "ctrl": TextEditingController(text: "1"), "tujuan": "- Pilih Tujuan -", "color": Colors.blue[50]},
    {"name": "DRUM MOT", "stock": 0, "ctrl": TextEditingController(text: "1"), "tujuan": "- Pilih Tujuan -", "color": Colors.green[50]},
    {"name": "DRUM MCT", "stock": 0, "ctrl": TextEditingController(text: "1"), "tujuan": "- Pilih Tujuan -", "color": Colors.orange[50]},
    {"name": "JERRY CAN", "stock": 0, "ctrl": TextEditingController(text: "1"), "tujuan": "- Pilih Tujuan -", "color": Colors.purple[50]},
    {"name": "IBC", "stock": 0, "ctrl": TextEditingController(text: "1"), "tujuan": "- Pilih Tujuan -", "color": Colors.blue[50]},
    {"name": "DRUM PLASTIC", "stock": 0, "ctrl": TextEditingController(text: "1"), "tujuan": "- Pilih Tujuan -", "color": Colors.green[50]},
    {"name": "METAL BOX", "stock": 0, "ctrl": TextEditingController(text: "1"), "tujuan": "- Pilih Tujuan -", "color": Colors.orange[50]},
    {"name": "PALET", "stock": 0, "ctrl": TextEditingController(text: "1"), "tujuan": "- Pilih Tujuan -", "color": Colors.purple[50]},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: Duration(milliseconds: 800))..repeat(reverse: true);
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(webAppUrl)).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          for (var i = 1; i < data.length; i++) {
            var item = items.firstWhere((it) => it['name'] == data[i][0], orElse: () => {});
            if (item.isNotEmpty) item['stock'] = data[i][1];
          }
        });
      }
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Offline Mode!"))); }
  }

  Future<void> prosesUpdate(Map item, int operasi) async {
    if (operasi == -1 && item['tujuan'] == "- Pilih Tujuan -") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pilih Tujuan Resmi!")));
      return;
    }
    int qty = int.tryParse(item['ctrl'].text) ?? 0;
    int stokLama = item['stock'];
    setState(() {
      item['stock'] += (operasi * qty);
      String tgl = DateFormat('dd/MM').format(DateTime.now());
      String jam = DateFormat('HH:mm').format(DateTime.now());
      history.insert(0, "$tgl|$jam|${operasi == 1 ? "Masuk" : "Keluar"}|$qty|${item['name']}|${operasi == 1 ? "Gudang" : item['tujuan']}");
    });
    try { await http.post(Uri.parse(webAppUrl), body: jsonEncode({"item": item['name'], "stock": item['stock']})); }
    catch (e) { setState(() => item['stock'] = stokLama); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PPLi MANYAR SMELTER"), backgroundColor: Color(0xFF1B5E20), actions: [
        FadeTransition(opacity: _animCtrl, child: Icon(Icons.circle, color: Colors.greenAccent, size: 14)),
        Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Center(child: Text("LIVE", style: TextStyle(fontSize: 10)))),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async { await fetchData(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data terupdate!"))); },
        backgroundColor: Colors.teal, icon: Icon(Icons.sync), label: Text("Sinkron"),
      ),
      body: Column(children: [
        Container(color: Colors.grey[300], padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4), child: Row(children: [
          Expanded(flex: 2, child: Text("ITEM", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("STOK", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("TUJUAN", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("QTY", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("AKSI", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
        ])),
        Expanded(flex: 3, child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            var item = items[i];
            return Card(color: item['color'], child: Row(children: [
              Expanded(flex: 2, child: Padding(padding: EdgeInsets.only(left: 4), child: Text(item['name'], style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))),
              Expanded(flex: 1, child: Text("${item['stock']}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                value: item['tujuan'], isExpanded: true, items: daftarTujuan.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 7)))).toList(),
                onChanged: (v) => setState(() => item['tujuan'] = v!),
              ))),
              Expanded(flex: 1, child: TextField(controller: item['ctrl'], keyboardType: TextInputType.number, style: TextStyle(fontSize: 9), decoration: InputDecoration(contentPadding: EdgeInsets.all(2), border: OutlineInputBorder()))),
              IconButton(constraints: BoxConstraints(), icon: Icon(Icons.remove_circle, color: Colors.red, size: 18), onPressed: () => prosesUpdate(item, -1)),
              IconButton(constraints: BoxConstraints(), icon: Icon(Icons.add_circle, color: Colors.green, size: 18), onPressed: () => prosesUpdate(item, 1)),
            ]));
          },
        )),
        Divider(),
        Expanded(flex: 1, child: ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, i) {
            var p = history[i].split('|');
            Color aksiColor = p[2] == "Masuk" ? Colors.green : Colors.red;
            return Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), child: RichText(text: TextSpan(style: TextStyle(fontSize: 9, color: Colors.black), children: [
              TextSpan(text: "${p[0]} ${p[1]} ", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              TextSpan(text: "${p[4]} ", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: "${p[2]} (${p[3]}) ", style: TextStyle(color: aksiColor, fontWeight: FontWeight.bold)),
              TextSpan(text: "→ ${p[5]}"),
            ])));
          },
        )),
      ]),
    );
  }
}
