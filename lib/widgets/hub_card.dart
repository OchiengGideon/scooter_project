import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HubCard extends StatelessWidget {
  final String name;
  final int availableScooters;
  final String distance;

  const HubCard({
    super.key,
    required this.name,
    required this.availableScooters,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.electric_scooter,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$availableScooters scooters available',
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              distance,
              style: TextStyle(
                color: AppColors.textDark.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}