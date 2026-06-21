<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\SizeRecommendation;
use App\Models\StylistSession;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AIController extends Controller
{
    public function recommendSize(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'height_cm' => 'required|integer|min:100|max:250',
            'weight_kg' => 'required|integer|min:30|max:200',
            'body_type' => 'nullable|string|in:slim,average,athletic,broad,stocky',
        ]);

        $size = $this->calculateSize(
            $validated['height_cm'],
            $validated['weight_kg'],
            $validated['body_type'] ?? 'average'
        );

        $recommendation = SizeRecommendation::updateOrCreate(
            ['user_id' => $request->user()->id],
            [
                'height_cm' => $validated['height_cm'],
                'weight_kg' => $validated['weight_kg'],
                'body_type' => $validated['body_type'],
                'recommended_size' => $size,
            ]
        );

        return response()->json([
            'success' => true,
            'data' => [
                'recommended_size' => $size,
                'height_cm' => $validated['height_cm'],
                'weight_kg' => $validated['weight_kg'],
                'body_type' => $validated['body_type'] ?? 'average',
                'tip' => $this->getSizeTip($size),
            ],
        ]);
    }

    public function getOutfitRecommendation(Request $request, Product $product): JsonResponse
    {
        $validated = $request->validate([
            'occasion' => 'required|string|in:business_meeting,date_night,wedding,casual_weekend,office,formal_event,street_style',
        ]);

        $occasion = $validated['occasion'];
        $recommendations = $this->generateOutfitRecommendations($product, $occasion);

        StylistSession::create([
            'user_id' => $request->user()->id,
            'product_id' => $product->id,
            'occasion' => $occasion,
            'recommendations' => $recommendations,
        ]);

        return response()->json([
            'success' => true,
            'data' => $recommendations,
        ]);
    }

    private function calculateSize(int $height, int $weight, string $bodyType): string
    {
        $bmi = $weight / (($height / 100) * ($height / 100));

        return match (true) {
            $bmi < 18.5 => 'S',
            $bmi < 22 => match ($bodyType) {
                'slim' => 'S',
                'athletic' => 'M',
                default => 'M',
            },
            $bmi < 25 => match ($bodyType) {
                'broad' => 'XL',
                'stocky' => 'XL',
                'athletic' => 'L',
                default => 'L',
            },
            $bmi < 30 => match ($bodyType) {
                'broad' => 'XXL',
                'stocky' => 'XXL',
                default => 'XL',
            },
            default => 'XXL',
        };
    }

    private function getSizeTip(string $size): string
    {
        return match ($size) {
            'S' => 'Slim fit styles will complement your frame perfectly.',
            'M' => 'Regular fit will provide a comfortable, classic silhouette.',
            'L' => 'Consider relaxed fit for extra comfort, or regular fit for a tailored look.',
            'XL' => 'Structured pieces with clean lines will create a polished appearance.',
            'XXL' => 'Look for brands that offer extended sizing for the best fit.',
            default => 'Try on different sizes to find your perfect fit.',
        };
    }

    private function generateOutfitRecommendations(Product $product, string $occasion): array
    {
        $category = $product->category->name ?? 'Shirts';

        $outfits = [
            'business_meeting' => [
                'outfit' => 'Power Business Ensemble',
                'colors' => ['Navy', 'Charcoal', 'White'],
                'accessories' => ['Silk Tie', 'Leather Belt', 'Dress Watch', 'Leather Briefcase'],
                'tips' => [
                    'Pair with a structured blazer for authority',
                    'Stick to neutral colors for professionalism',
                    'Ensure shoes are polished and match the belt',
                    'A quality watch adds a finishing touch',
                ],
            ],
            'date_night' => [
                'outfit' => 'Sophisticated Evening Look',
                'colors' => ['Black', 'Burgundy', 'Deep Blue'],
                'accessories' => ['Statement Watch', 'Pocket Square', 'Leather Card Holder'],
                'tips' => [
                    'Dark colors create an elegant evening atmosphere',
                    'A well-fitted piece shows attention to detail',
                    'Subtle cologne completes the look',
                    'Less is more — choose one statement piece',
                ],
            ],
            'wedding' => [
                'outfit' => 'Refined Wedding Guest',
                'colors' => ['Navy', 'Grey', 'Light Blue'],
                'accessories' => ['Silk Tie', 'Cufflinks', 'Pocket Square', 'Dress Shoes'],
                'tips' => [
                    'Avoid white — that\'s for the groom',
                    'A pocket square elevates any suit',
                    'Dress shoes should complement the outfit',
                    'Keep accessories tasteful and coordinated',
                ],
            ],
            'casual_weekend' => [
                'outfit' => 'Relaxed Weekend Style',
                'colors' => ['Earth Tones', 'Pastels', 'White', 'Khaki'],
                'accessories' => ['Sunglasses', 'Casual Watch', 'Canvas Belt'],
                'tips' => [
                    'Comfort meets style on the weekend',
                    'Layer with a lightweight jacket if needed',
                    'Clean sneakers or loafers complete the look',
                    'Roll sleeves for a relaxed vibe',
                ],
            ],
            'office' => [
                'outfit' => 'Smart Office Attire',
                'colors' => ['White', 'Light Blue', 'Grey', 'Navy'],
                'accessories' => ['Leather Belt', 'Classic Watch', 'Laptop Bag'],
                'tips' => [
                    'Smart casual is the modern office standard',
                    'Well-fitted chinos pair perfectly with shirts',
                    'A quality bag keeps you organized and stylish',
                    'Comfortable shoes matter for long work days',
                ],
            ],
            'formal_event' => [
                'outfit' => 'Black Tie Elegance',
                'colors' => ['Black', 'White', 'Midnight Blue'],
                'accessories' => ['Bow Tie', 'Cufflinks', 'Pocket Square', 'Formal Watch'],
                'tips' => [
                    'A well-tailored suit is non-negotiable',
                    'Black shoes must be impeccably polished',
                    'A bow tie adds classic formal elegance',
                    'Keep jewelry minimal and refined',
                ],
            ],
            'street_style' => [
                'outfit' => 'Urban Street Fashion',
                'colors' => ['Black', 'White', 'Olive', 'Rust'],
                'accessories' => ['Crossbody Bag', 'Sneakers', 'Beanie', 'Layering Pieces'],
                'tips' => [
                    'Mix textures for visual interest',
                    'Layering is key to street style',
                    'Statement sneakers can anchor the whole look',
                    'Confidence is the best accessory',
                ],
            ],
        ];

        $base = $outfits[$occasion] ?? $outfits['casual_weekend'];

        return [
            'product' => $product->name,
            'occasion' => str_replace('_', ' ', ucfirst($occasion)),
            'outfit_name' => $base['outfit'],
            'matching_colors' => $base['colors'],
            'suggested_accessories' => $base['accessories'],
            'styling_tips' => $base['tips'],
            'category' => $category,
        ];
    }
}
