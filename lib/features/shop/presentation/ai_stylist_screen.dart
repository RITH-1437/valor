import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/repositories/ai_repository.dart';

class AIStylistScreen extends ConsumerStatefulWidget {
  final int productId;
  final String productName;

  const AIStylistScreen({super.key, required this.productId, required this.productName});

  @override
  ConsumerState<AIStylistScreen> createState() => _AIStylistScreenState();
}

class _AIStylistScreenState extends ConsumerState<AIStylistScreen> {
  String _selectedOccasion = 'business_meeting';
  Map<String, dynamic>? _recommendation;
  bool _isLoading = false;

  final _occasions = [
    {'key': 'business_meeting', 'label': 'Business Meeting', 'icon': Icons.work_outline},
    {'key': 'date_night', 'label': 'Date Night', 'icon': Icons.favorite_outline},
    {'key': 'wedding', 'label': 'Wedding', 'icon': Icons.celebration_outlined},
    {'key': 'casual_weekend', 'label': 'Casual Weekend', 'icon': Icons.weekend_outlined},
    {'key': 'office', 'label': 'Office', 'icon': Icons.business_center_outlined},
    {'key': 'formal_event', 'label': 'Formal Event', 'icon': Icons.dinner_dining_outlined},
    {'key': 'street_style', 'label': 'Street Style', 'icon': Icons.directions_walk_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(title: const Text('AI Stylist')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.productName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Select an occasion for styling recommendations', style: TextStyle(color: AppTheme.gray, fontSize: 14)),
            const SizedBox(height: 20),

            // Occasion grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: _occasions.length,
              itemBuilder: (ctx, i) {
                final occ = _occasions[i];
                final selected = _selectedOccasion == occ['key'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedOccasion = occ['key'] as String),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.gold.withAlpha(30) : AppTheme.darkGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppTheme.gold : Colors.transparent),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(occ['icon'] as IconData, color: selected ? AppTheme.gold : AppTheme.gray, size: 28),
                        const SizedBox(height: 8),
                        Text(occ['label'] as String, style: TextStyle(color: selected ? AppTheme.gold : Colors.white, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _getRecommendation,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: AppTheme.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black))
                    : const Text('Get Styling Tips', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),

            // Results
            if (_recommendation != null) ...[
              const SizedBox(height: 24),
              _buildResultCard('Outfit', _recommendation!['outfit_name'] ?? '', Icons.checkroom),
              _buildColorCard('Matching Colors', List<String>.from(_recommendation!['matching_colors'] ?? [])),
              _buildListCard('Suggested Accessories', List<String>.from(_recommendation!['suggested_accessories'] ?? [])),
              _buildTipsCard('Styling Tips', List<String>.from(_recommendation!['styling_tips'] ?? [])),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _getRecommendation() async {
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(aiRepositoryProvider).getOutfitRecommendation(widget.productId, _selectedOccasion);
      setState(() { _recommendation = result; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildResultCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.gold.withAlpha(30), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppTheme.gold, size: 20)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ]),
        ],
      ),
    );
  }

  Widget _buildColorCard(String title, List<String> colors) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: colors.map((c) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.black, borderRadius: BorderRadius.circular(8)),
          child: Text(c, style: const TextStyle(color: Colors.white, fontSize: 12)),
        )).toList()),
      ]),
    );
  }

  Widget _buildListCard(String title, List<String> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            const Icon(Icons.check, color: AppTheme.gold, size: 14),
            const SizedBox(width: 8),
            Expanded(child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 13))),
          ]),
        )),
      ]),
    );
  }

  Widget _buildTipsCard(String title, List<String> tips) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
        const SizedBox(height: 8),
        ...tips.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(6)),
              child: Center(child: Text('${entry.key + 1}', style: const TextStyle(color: AppTheme.black, fontSize: 10, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(entry.value, style: const TextStyle(color: Colors.white, fontSize: 13))),
          ]),
        )),
      ]),
    );
  }
}
