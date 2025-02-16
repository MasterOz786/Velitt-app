import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:velitt/widgets/bottom_navbar.dart';
import 'package:logging/logging.dart';
import 'package:velitt/widgets/header.dart';
import 'package:velitt/state/member_state.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  // Logger for debugging purposes
  final Logger _logger = Logger('MemberDashboardScreen');

  // Category expanded/collapsed states
  final Map<String, bool> _categoryExpanded = {
    'Physical Measurements': true,
    'Body Composition': false,
    'Laboratory Tests': false,
  };

  // Chart expanded/collapsed states
  final Map<String, bool> _chartExpanded = {
    'Weight': true,
    'Height': false,
    'Blood Pressure': false,
    'Pulse': false,
    'Body Fat': false,
    'Muscle Mass': false,
    'BMI': false,
    'Blood Sugar': false,
    'Cholesterol': false,
    'Hemoglobin': false,
  };

  // Holds API parameters data (e.g. for BMI, bodyFat, etc.)
  Map<String, dynamic> _parameters = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _logger.info('Initializing MemberDashboardScreen');
    _fetchParameters();
  }

  Future<void> _fetchParameters() async {
    _logger.fine('Fetching parameters from API');
    try {
      // Note: If testing on an emulator, use 10.0.2.2 instead of localhost.
      final response = await http.get(
        Uri.parse('http://localhost/api/members.php/parameters/121'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _parameters = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e, s) {
      _logger.severe('Error fetching parameters', e, s);
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        // Already on dashboard
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Widget _buildCategory(String title, List<String> charts) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _categoryExpanded[title] = !(_categoryExpanded[title] ?? false);
              // If collapsing, hide all charts in that category.
              if (!(_categoryExpanded[title] ?? false)) {
                for (var chart in charts) {
                  _chartExpanded[chart] = false;
                }
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE31E24),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  _categoryExpanded[title] ?? false
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (_categoryExpanded[title] ?? false)
          Column(
            children: charts.map((chart) => _buildChart(chart)).toList(),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Converts API data into chart spots or uses fallback sample data.
  Widget _buildChart(String title) {
    List<FlSpot> spots = [];
    // Map chart titles to corresponding JSON keys:
    String key;
    switch (title) {
      case 'Weight':
        key = 'bodyweight';
        break;
      case 'Height':
        key = 'height';
        break;
      case 'BMI':
        key = 'BMI';
        break;
      case 'Body Fat':
        key = 'bodyFat';
        break;
      case 'Blood Pressure':
        key = 'blood_pressure';
        break;
      case 'Fat Free Body Weight':
        key = 'FFBweight';
        break;
      case 'Body Water':
        key = 'bodywater';
        break;
      case 'Muscle Mass':
        key = 'musclemass';
        break;
      case 'Protein':
        key = 'protein';
        break;
      case 'Pulse':
        key = 'pulse';
        break;
      case 'Glucose':
        key = 'glucose';
        break;
      case 'Cholesterol':
        key = 'cholesterol';
        break;
      default:
        key = title;
        break;
    }

    // Generate chart spots from API data if available, otherwise use fallback
    if (_parameters.containsKey(key)) {
      var dataList = _parameters[key] as List;
      if (dataList.isNotEmpty) {
        for (var i = 0; i < dataList.length; i++) {
          double value;
          try {
            // If blood pressure data is in a list format
            if (dataList[i]['value'] is List) {
              value = double.parse(dataList[i]['value'][0].toString());
            } else {
              value = double.parse(dataList[i]['value'].toString());
            }
          } catch (e) {
            _logger.warning('Error parsing value for $key at index $i: $e');
            value = 0;
          }
          spots.add(FlSpot(i.toDouble(), value));
        }
      } else {
        spots = _fallbackSpots();
      }
    } else {
      spots = _fallbackSpots();
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _chartExpanded[title] = !(_chartExpanded[title] ?? false);
            });
          },
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE31E24),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Icon(
                  _chartExpanded[title] ?? false
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (_chartExpanded[title] ?? false)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '${value.toInt() + 1}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFFE31E24),
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFE31E24).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<FlSpot> _fallbackSpots() {
    return const [
      FlSpot(0, 42),
      FlSpot(1, 41.8),
      FlSpot(2, 41.2),
      FlSpot(3, 41),
      FlSpot(4, 41.5),
      FlSpot(5, 43),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final MemberState memberState = Provider.of<MemberState>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : Column(
                  children: [
                    HeaderWidget(
                      title: 'Dashboard',
                      memberName: memberState.memberName ?? 'None',
                      // profileImage: memberState.profileImage ?? 'https://via.placeholder.com/160',
                      profileImage: 'https://via.placeholder.com/160',
                    ),
                    // Charts Section
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildCategory('Physical Measurements', [
                            'Weight',
                            'Height',
                          ]),
                          _buildCategory('Body Composition', [
                            'BMI',
                            'Body Fat',
                            'Fat Free Body Weight',
                            'Body Water',
                            'Muscle Mass',
                            'Protein',
                            'Waist Circumference',
                          ]),
                          _buildCategory('Laboratory Tests', [
                            'Blood Pressure',
                            'Pulse',
                            'Glucose'
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1, onTap: _handleNavigation),
    );
  }
}
