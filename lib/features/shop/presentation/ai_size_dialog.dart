import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_ai_provider.dart';

class AISizeDialog extends ConsumerStatefulWidget {
  const AISizeDialog({super.key});

  @override
  ConsumerState<AISizeDialog> createState() => _AISizeDialogState();
}

class _AISizeDialogState extends ConsumerState<AISizeDialog> {
  final _heightCtrl = TextEditingController(text: '175');
  final _weightCtrl = TextEditingController(text: '70');
  String _bodyType = 'average';
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.checkroom, color: AppTheme.gold, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('AI Size Recommendation', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
                  IconButton(icon: const Icon(Icons.close, color: AppTheme.gray), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _field('Height (cm)', _heightCtrl, TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field('Weight (kg)', _weightCtrl, TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Body Type', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['slim', 'average', 'athletic', 'broad', 'stocky'].map((type) {
                  final selected = _bodyType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _bodyType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.gold : AppTheme.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? AppTheme.gold : const Color(0xFF374151)),
                      ),
                      child: Text(type.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? AppTheme.black : Colors.white)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (_result != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.black, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      const Text('Your Recommended Size', style: TextStyle(color: AppTheme.gray, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(_result!['recommended_size'], style: const TextStyle(color: AppTheme.gold, fontSize: 48, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(_result!['tip'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _getRecommendation,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: AppTheme.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black))
                      : const Text('Get Recommendation', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getRecommendation() async {
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(aiRepositoryProvider).recommendSize(
        heightCm: int.parse(_heightCtrl.text),
        weightKg: int.parse(_weightCtrl.text),
        bodyType: _bodyType,
      );
      if (mounted) setState(() { _result = result; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _field(String label, TextEditingController ctrl, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.gray, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            filled: true,
            fillColor: AppTheme.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
        ),
      ],
    );
  }
}
