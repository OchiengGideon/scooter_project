import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatelessWidget {
  final List<Trip> rides = [
    Trip(
      id: '1',
      startTime: DateTime.now().subtract(Duration(days: 1)),
      endTime: DateTime.now().subtract(Duration(days: 1, hours: 0, minutes: 15)),
      distance: 2.3,
      cost: 2.30,
      scooterId: 'SCOOT-123',
    ),
    Trip(
      id: '2',
      startTime: DateTime.now().subtract(Duration(days: 2)),
      endTime: DateTime.now().subtract(Duration(days: 2, hours: 0, minutes: 12)),
      distance: 1.7,
      cost: 1.70,
      scooterId: 'SCOOT-456',
    ),
    Trip(
      id: '3',
      startTime: DateTime.now().subtract(Duration(days: 4)),
      endTime: DateTime.now().subtract(Duration(days: 4, hours: 0, minutes: 18)),
      distance: 3.1,
      cost: 3.10,
      scooterId: 'SCOOT-789',
    ),
  ];

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final trip = rides[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                          color: AppColors.error,
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
                            ),
                          ),
                          Text(
                            '${trip.distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
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
                            ),
                          ),
                          Text(
                            _formatDuration(trip.duration),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
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
                            ),
                          ),
                          Text(
                            trip.scooterId,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}