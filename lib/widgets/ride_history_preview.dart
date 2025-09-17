import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RideHistoryPreview extends StatelessWidget {
  final List<Map<String, dynamic>> rides;

  const RideHistoryPreview({Key? key, required this.rides}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Rides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full history
              },
              child: Text('See All'),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...rides.map((ride) => Card(
          margin: EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.electric_scooter,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              ride['date'],
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Distance: ${ride['distance']}',
            ),
            trailing: Text(
              ride['cost'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }
}