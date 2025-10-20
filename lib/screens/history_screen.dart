// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Ride History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your completed rides will appear here',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final completedRides = userProvider.user.tripHistory
        .where((trip) => trip.endTime != null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: completedRides.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: completedRides.length,
        itemBuilder: (context, index) {
          final trip = completedRides[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(trip.startTime),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$${trip.cost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance',
                            style: TextStyle(
                              color: AppColors.textDark.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${trip.distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duration',
                            style: TextStyle(
                              color: AppColors.textDark.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatDuration(trip.duration),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scooter ID',
                            style: TextStyle(
                              color: AppColors.textDark.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            trip.scooterId,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (trip.endTime != null) ...[
                    SizedBox(height: 8),
                    Divider(),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'End Time',
                          style: TextStyle(
                            color: AppColors.textDark.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDate(trip.endTime!),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}