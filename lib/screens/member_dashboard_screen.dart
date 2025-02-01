import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:velitt/widgets/bottom_navbar.dart';
import 'package:logging/logging.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  // Expanded/collapsed states for categories and charts
  final Map<String, bool> _categoryExpanded = {
    'Physical Measurements': true,
    'Body Composition': false,
    'Laboratory Tests': false,
  };

  final Logger _logger = Logger('MemberDashboardScreen');

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

  // This will hold the API parameters data (e.g. for BMI, bodyFat, etc.)
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
    } catch (e) {
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

  /// _buildChart builds a chart widget for a given title.
  /// It first checks if API data is available for the given title (matching the JSON key).
  /// If so, it converts that data into a list of FlSpot objects.
  /// Otherwise, it falls back to hardcoded sample data.
  Widget _buildChart(String title) {
    List<FlSpot> spots = [];
    // Map chart titles to corresponding JSON keys:
    String key;
    switch (title) {
      case 'Weight':
        key = 'bodyWeight';
        break;
      case 'Height':
        key = 'height';
        break;
      case 'Blood Pressure':
        key = 'blood_pressure';
        break;
      case 'Pulse':
        key = 'pulse';
        break;
      case 'Body Fat':
        key = 'bodyFat';
        break;
      case 'Muscle Mass':
        key = 'muscleMass';
        break;
      case 'BMI':
        key = 'BMI';
        break;
      case 'Blood Sugar':
        key = 'glucose';
        break;
      default:
        key = title;
        break;
    }

    // If the key exists in the parameters and has data, create spots.
    if (_parameters.containsKey(key)) {
      var dataList = _parameters[key] as List;
      if (dataList.isNotEmpty) {
        for (var i = 0; i < dataList.length; i++) {
          double value;
          try {
            value = double.parse(dataList[i]['value'].toString());
          } catch (e) {
            value = 0;
          }
          spots.add(FlSpot(i.toDouble(), value));
        }
      } else {
        // If the list exists but is empty, use fallback data.
        spots = const [
          FlSpot(0, 42),
          FlSpot(1, 41.8),
          FlSpot(2, 41.2),
          FlSpot(3, 41),
          FlSpot(4, 41.5),
          FlSpot(5, 43),
        ];
      }
    } else {
      // Use fallback hardcoded data if no API data exists.
      spots = const [
        FlSpot(0, 42),
        FlSpot(1, 41.8),
        FlSpot(2, 41.2),
        FlSpot(3, 41),
        FlSpot(4, 41.5),
        FlSpot(5, 43),
      ];
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
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text('${value.toInt() + 1}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(value.toInt().toString(), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFFE31E24),
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: const Color(0xFFE31E24).withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.white)))
              : Column(
                  children: [
                    // Header Section
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -100,
                            top: -50,
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE31E24),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        'https://placeholder.com/60x60',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Dashboard',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(
                                        'Ejaz Uddin',
                                        style: TextStyle(fontSize: 16, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.settings, color: Colors.white, size: 24),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Charts Section
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildCategory('Physical Measurements', [
                            'Weight',
                            'Height',
                            'Blood Pressure',
                            'Pulse',
                          ]),
                          _buildCategory('Body Composition', [
                            'Body Fat',
                            'Muscle Mass',
                            'BMI',
                          ]),
                          _buildCategory('Laboratory Tests', [
                            'Blood Sugar',
                            'Cholesterol',
                            'Hemoglobin',
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
