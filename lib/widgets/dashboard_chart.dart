import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardChart extends StatelessWidget {
  final int doneCount;
  final int activeCount;
  final bool isCompact;

  const DashboardChart({
    super.key,
    required this.doneCount,
    required this.activeCount,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if chart is empty
    final bool isEmpty = doneCount == 0 && activeCount == 03;
    final total = activeCount + doneCount;
    
    // Dimensi responsif - Increased for better visibility
    final double centerRadius = isCompact ? 35 : 75; // Increased from 20/60
    final double sectionRadius = isCompact ? 25 : 55; // Increased from 18/45
    final double centerSize = isCompact ? 70 : 150; // Increased from 40/100
    
    final double fontSizeBig = isCompact ? 24 : 48; // Increased from 16/36
    final double fontSizeSmall = isCompact ? 12 : 16;
    final double iconSize = isCompact ? 14 : 20;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.grey.shade700;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Column(
      children: [
        // Chart Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_rounded, color: Theme.of(context).colorScheme.secondary, size: iconSize),
            const SizedBox(width: 4),
            Text(
              'Ringkasan Tugas',
              style: TextStyle(
                fontSize: isCompact ? 11 : 16, // Smaller font
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        SizedBox(height: isCompact ? 4 : 20),
        
        // Chart
        SizedBox(
          height: isCompact ? 140 : 280, // Increased height
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated Pie Chart
              PieChart(
                PieChartData(
                  sectionsSpace: isCompact ? 0 : 4,
                  centerSpaceRadius: centerRadius,
                  startDegreeOffset: -90,
                  sections: isEmpty
                      ? [
                          PieChartSectionData(
                            color: Colors.grey.shade200,
                            value: 1,
                            title: '',
                            radius: sectionRadius - (isCompact ? 5 : 10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          )
                        ]
                      : [
                          // Active tasks section
                          PieChartSectionData(
                            color: Theme.of(context).colorScheme.secondary, // Coral (Active)
                            value: activeCount.toDouble(),
                            title: '',
                            radius: sectionRadius,
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo.shade300,
                                Colors.indigo.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            badgeWidget: _buildBadge(
                              '${((activeCount / total) * 100).toStringAsFixed(0)}%',
                              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              Theme.of(context).colorScheme.secondary,
                              isCompact,
                            ),
                            badgePositionPercentageOffset: 1.4, // Push badge out slightly more
                          ),
                          // Done tasks section
                          PieChartSectionData(
                            color: Theme.of(context).colorScheme.tertiary, // Teal (Done)
                            value: doneCount.toDouble(),
                            title: '',
                            radius: sectionRadius,
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade300,
                                Colors.green.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            badgeWidget: _buildBadge(
                              '${((doneCount / total) * 100).toStringAsFixed(0)}%',
                              Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                              Theme.of(context).colorScheme.tertiary,
                              isCompact,
                            ),
                            badgePositionPercentageOffset: 1.4,
                          ),
                        ],
                ),
              ),
              
              // Center content with glassmorphism effect
              Container(
                width: centerSize,
                height: centerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.1),
                      blurRadius: isCompact ? 5 : 20,
                      spreadRadius: isCompact ? 1 : 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      total.toString(),
                      style: TextStyle(
                        fontSize: fontSizeBig,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade700,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: fontSizeSmall,
                        color: subTextColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        SizedBox(height: isCompact ? 4 : 20),
        
        // Legend - stacked if compact to save width
        if (isCompact)
          Column(
            children: [
              _buildLegendItem(context, 'Aktif', Colors.indigo.shade400, activeCount),
              const SizedBox(height: 4),
              _buildLegendItem(context, 'Selesai', Colors.green.shade400, doneCount),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, 'Aktif', Theme.of(context).colorScheme.secondary, activeCount),
              const SizedBox(width: 24),
              _buildLegendItem(context, 'Selesai', Theme.of(context).colorScheme.tertiary, doneCount),
            ],
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor, bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 3 : 8,
        vertical: isCompact ? 1 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isCompact ? 6 : 12),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.2),
            blurRadius: isCompact ? 2 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isCompact ? 8 : 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCompact ? 10 : 16,
          height: isCompact ? 10 : 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: isCompact ? 10 : 13,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
