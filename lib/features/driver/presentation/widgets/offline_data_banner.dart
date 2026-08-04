import 'package:flutter/material.dart';

/// Shown whenever [DriverRouteLoaded.isOffline] is true, so a driver (or
/// anyone reviewing the app) can never mistake the offline/demo fallback
/// data for what's actually in Firestore.
class OfflineDataBanner extends StatelessWidget {
  const OfflineDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "You're offline — showing demo data until connection is restored.",
              style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
