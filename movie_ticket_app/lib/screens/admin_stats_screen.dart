import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; 
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  @override
  void initState() {
    super.initState();
    
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      Future.microtask(() => Provider.of<AdminProvider>(context, listen: false).fetchStats(token));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê Hệ thống')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.stats;
          
          if (stats == null) {
            return const Center(child: Text('Chưa có dữ liệu.'));
          }

          final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

          return RefreshIndicator(
            onRefresh: () async {
              final token = Provider.of<AuthProvider>(context, listen: false).token!;
              await provider.fetchStats(token);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                
                _buildRevenueCard(currencyFormatter.format(stats['totalRevenue'] ?? 0)),
                const SizedBox(height: 24),

                
                const Text('Doanh thu 7 ngày qua', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildBarChart(stats['dailyRevenue']),
                const SizedBox(height: 24),

                
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(), 
                  children: [
                    _buildStatCard('Vé đã bán', stats['totalSeatsSold'].toString(), Icons.confirmation_num, Colors.orange),
                    _buildStatCard('Khách hàng', stats['totalUsers'].toString(), Icons.people, Colors.blue),
                    _buildStatCard('Phim đang chiếu', stats['totalMovies'].toString(), Icons.movie, Colors.purple),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  
  Widget _buildRevenueCard(String amount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryColor, Colors.redAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text('TỔNG DOANH THU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  
  Widget _buildBarChart(List<dynamic>? dailyData) {
    if (dailyData == null || dailyData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: AppConstants.cardColor, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('Chưa có dữ liệu biểu đồ')),
      );
    }

    
    List<BarChartGroupData> barGroups = [];
    double maxRevenue = 0;

    for (int i = 0; i < dailyData.length; i++) {
      double revenue = (dailyData[i]['revenue'] ?? 0).toDouble();
      
      if (revenue > maxRevenue) maxRevenue = revenue;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: revenue,
              color: AppConstants.primaryColor,
              width: 16, 
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxRevenue * 1.2, 
                color: Colors.grey.withOpacity(0.1),
              ),
            )
          ],
        ),
      );
    }

    
    if (maxRevenue == 0) maxRevenue = 100000;

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          alignment: BarChartAlignment.spaceAround,
          maxY: maxRevenue * 1.2, 
          gridData: const FlGridData(show: false), 
          borderData: FlBorderData(show: false), 
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < dailyData.length) {
                    
                    String dateStr = dailyData[index]['_id'];
                    DateTime date = DateTime.parse(dateStr);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey[900], 
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(rod.toY),
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}