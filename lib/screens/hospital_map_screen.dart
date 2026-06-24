import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';

class HospitalMapScreen extends StatelessWidget {
  const HospitalMapScreen({super.key});

  final double hospitalLat = 12.9716; // Example: Bangalore
  final double hospitalLng = 77.5946;

  Future<void> _launchNavigation(BuildContext context) async {
    final Uri url = Uri.parse('google.navigation:q=$hospitalLat,$hospitalLng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback to web browser map if native app not found
      final Uri webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$hospitalLat,$hospitalLng');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map applications')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Location', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(hospitalLat, hospitalLng),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hospitaleasy',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(hospitalLat, hospitalLng),
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () => _launchNavigation(context),
              icon: const Icon(Icons.navigation),
              label: const Text('Navigate to Hospital'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
