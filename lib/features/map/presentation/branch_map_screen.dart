import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';

class BranchModel {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String hours;
  final double lat;
  final double lng;
  final String image;
  BranchModel({required this.id, required this.name, required this.address, required this.phone, required this.hours, required this.lat, required this.lng, required this.image});
}

final branchDataProvider = Provider<List<BranchModel>>((ref) => [
  BranchModel(id: 1, name: 'VALOR Downtown', address: '123 Fashion Avenue, Downtown', phone: '+1-555-0101', hours: 'Mon-Sat: 10AM-9PM, Sun: 11AM-6PM', lat: 40.7128, lng: -74.0060, image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800'),
  BranchModel(id: 2, name: 'VALOR Midtown', address: '456 Style Boulevard, Midtown', phone: '+1-555-0102', hours: 'Mon-Sat: 10AM-8PM, Sun: 12PM-5PM', lat: 40.7580, lng: -73.9855, image: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800'),
  BranchModel(id: 3, name: 'VALOR SoHo', address: '789 Trend Street, SoHo', phone: '+1-555-0103', hours: 'Mon-Sun: 10AM-8PM', lat: 40.7233, lng: -74.0030, image: 'https://images.unsplash.com/photo-1534452203293-494d7ddbf7e0?w=800'),
  BranchModel(id: 4, name: 'VALOR Brooklyn', address: '321 Urban Lane, Brooklyn', phone: '+1-555-0104', hours: 'Mon-Sat: 10AM-9PM, Sun: 10AM-6PM', lat: 40.6782, lng: -73.9442, image: 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=800'),
]);

class BranchMapScreen extends ConsumerStatefulWidget {
  const BranchMapScreen({super.key});

  @override
  ConsumerState<BranchMapScreen> createState() => _BranchMapScreenState();
}

class _BranchMapScreenState extends ConsumerState<BranchMapScreen> {
  final MapController _mapController = MapController();
  int? _selectedBranchId;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _showBranchSheet(BranchModel branch) {
    setState(() => _selectedBranchId = branch.id);
    _mapController.move(LatLng(branch.lat, branch.lng), 15);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkGray,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _BranchSheet(branch: branch),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branches = ref.watch(branchDataProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Find a Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_outlined),
            onPressed: () {
              if (branches.isNotEmpty) {
                _mapController.move(LatLng(branches.first.lat, branches.first.lng), 14);
              }
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(40.730, -73.995),
          initialZoom: 12,
          onTap: (_, _) => setState(() => _selectedBranchId = null),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.valor.app',
          ),
          MarkerLayer(
            markers: branches.map((b) => Marker(
              point: LatLng(b.lat, b.lng),
              width: 80,
              height: 80,
              child: GestureDetector(
                onTap: () => _showBranchSheet(b),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.black.withAlpha(200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(b.name.replaceAll('VALOR ', ''), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 4),
                    Icon(Icons.location_on, color: _selectedBranchId == b.id ? AppTheme.gold : Colors.red, size: 32),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _BranchSheet extends StatelessWidget {
  final BranchModel branch;
  const _BranchSheet({required this.branch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: branch.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: AppTheme.black, child: const Icon(Icons.store, color: AppTheme.gray)),
                  errorWidget: (_, _, _) => Container(color: AppTheme.black, child: const Icon(Icons.store, color: AppTheme.gray)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(branch.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(branch.address, style: const TextStyle(fontSize: 13, color: AppTheme.gray)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _infoRow(Icons.phone_outlined, branch.phone),
          const SizedBox(height: 12),
          _infoRow(Icons.access_time_rounded, branch.hours),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchDirections(context),
              icon: const Icon(Icons.directions_outlined),
              label: const Text('Get Directions'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.gold, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppTheme.gray))),
      ],
    );
  }

  void _launchDirections(BuildContext context) {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${branch.lat},${branch.lng}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Directions link copied!')));
  }
}
