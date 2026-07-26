import 'package:flutter/material.dart';

import '../../domain/entities/parent_trip_entity.dart';
import 'parent_ui_constants.dart';

class ParentBusStatusCard extends StatelessWidget {
  const ParentBusStatusCard({required this.trip, super.key});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BusCardHeader(trip: trip),
          const SizedBox(height: 18),
          _LocationRow(
            icon: Icons.location_on_outlined,
            title: 'Current stop',
            value: trip.currentStop,
          ),
          const SizedBox(height: 12),
          _LocationRow(
            icon: Icons.near_me_outlined,
            title: 'Next stop',
            value: trip.nextStop,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: trip.progress.clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: ParentUiColors.orange.withValues(alpha: 0.14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SmallInfoBox(title: 'ETA', value: trip.eta),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallInfoBox(
                  title: 'Stops away',
                  value: '${trip.stopsAway}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusCardHeader extends StatelessWidget {
  const _BusCardHeader({required this.trip});

  final ParentTripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: ParentUiColors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.directions_bus_filled,
            color: ParentUiColors.orange,
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.busNumber,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                trip.childName,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _StatusBadge(label: trip.statusLabel),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ParentUiColors.orange, size: 22),
        const SizedBox(width: 10),
        Text(
          '$title: ',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _SmallInfoBox extends StatelessWidget {
  const _SmallInfoBox({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: ParentUiColors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
