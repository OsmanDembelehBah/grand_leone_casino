import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/db_helper.dart';
import '../models/order_model.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  List<DrinkOrder> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await DBHelper().getOrders();
    setState(() {
      _orders = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      );
    }

    int totalServed = _orders.fold(0, (sum, o) => sum + o.quantity);
    int vipCount = _orders.where((o) => o.customerType == 'VIP' || o.customerType == 'High Roller').fold(0, (sum, o) => sum + o.quantity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('SUPERVISOR ANALYTICS', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.deepOrange), onPressed: _fetchData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _metricCard('Total Served', '$totalServed', Icons.local_bar, Colors.deepOrange)),
                  const SizedBox(width: 12),
                  Expanded(child: _metricCard('VIP Drinks', '$vipCount', Icons.stars, Colors.amber)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Guest Breakdown Ratio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: totalServed == 0
                    ? const Center(child: Text('No shift orders recorded yet.'))
                    : PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(color: Colors.deepOrange, value: vipCount.toDouble(), title: 'VIP ($vipCount)', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            PieChartSectionData(color: Colors.blueAccent, value: (totalServed - vipCount).toDouble(), title: 'Std (${totalServed - vipCount})', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              const Text('Live Shift Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orders.length,
                itemBuilder: (context, i) {
                  final o = _orders[i];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Color(0xFFFFF3E0), child: Icon(Icons.local_bar, color: Colors.deepOrange)),
                      title: Text('${o.drinkName} x${o.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Guest: ${o.customerName} | By: ${o.bartenderName}\n${o.timestamp}', style: const TextStyle(fontSize: 11)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }
}
