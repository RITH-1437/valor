<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\ProductColor;
use App\Models\ProductImage;
use App\Models\ProductSize;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    private array $sizeOptions = ['S', 'M', 'L', 'XL', 'XXL'];
    private array $colorPalette = [
        ['name' => 'Black', 'hex_code' => '#000000'],
        ['name' => 'White', 'hex_code' => '#FFFFFF'],
        ['name' => 'Navy', 'hex_code' => '#1B2A4A'],
        ['name' => 'Charcoal', 'hex_code' => '#36454F'],
        ['name' => 'Grey', 'hex_code' => '#808080'],
        ['name' => 'Camel', 'hex_code' => '#C19A6B'],
        ['name' => 'Burgundy', 'hex_code' => '#800020'],
        ['name' => 'Olive', 'hex_code' => '#556B2F'],
        ['name' => 'Tan', 'hex_code' => '#D2B48C'],
        ['name' => 'Brown', 'hex_code' => '#6B4423'],
    ];

    private function imageUrl(string $slug): string
    {
        return "https://picsum.photos/seed/{$slug}/600/800";
    }

    private function imagePoolUrl(int $index): string
    {
        return "https://picsum.photos/seed/product{$index}/600/800";
    }

    public function run(): void
    {
        $categories = Category::pluck('id', 'slug')->toArray();

        $products = $this->getProductData($categories);

        foreach ($products as $data) {
            $data['image'] = $this->imageUrl($data['slug']);
            $product = Product::create($data);

            // Add 2-3 images per product
            $baseIdx = abs(crc32($data['sku'])) % 50;
            $imageCount = rand(2, 3);
            for ($idx = 0; $idx < $imageCount; $idx++) {
                ProductImage::create([
                    'product_id' => $product->id,
                    'image' => $this->imagePoolUrl($baseIdx + $idx),
                    'sort_order' => $idx,
                ]);
            }

            // Add sizes (clothing items get full range, shoes get numeric)
            $isShoe = in_array($data['category_id'], [$categories['shoes'] ?? 0]);
            $sizes = $isShoe ? ['40', '41', '42', '43', '44', '45'] : $this->sizeOptions;
            foreach ($sizes as $size) {
                ProductSize::create(['product_id' => $product->id, 'size' => $size]);
            }

            // Add 2-3 colors
            $colorCount = rand(2, 3);
            $shuffled = $this->colorPalette;
            shuffle($shuffled);
            foreach (array_slice($shuffled, 0, $colorCount) as $color) {
                ProductColor::create([
                    'product_id' => $product->id,
                    'name' => $color['name'],
                    'hex_code' => $color['hex_code'],
                ]);
            }
        }
    }

    private function getProductData(array $c): array
    {
        return [
            // T-SHIRTS (6)
            [
                'category_id' => $c['t-shirts'], 'name' => 'Premium Pima Cotton Crew Neck', 'slug' => 'premium-pima-cotton-crew-neck',
                'description' => 'Crafted from 100% Peruvian Pima cotton, this crew neck t-shirt offers unmatched softness and durability. A wardrobe essential for the discerning gentleman.',
                'short_description' => 'Ultra-soft Pima cotton crew neck', 'price' => 89.00, 'discount_price' => null, 'stock' => 120, 'sku' => 'VL-TS-001',
                'image' => 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['t-shirts'], 'name' => 'Italian Linen V-Neck', 'slug' => 'italian-linen-v-neck',
                'description' => 'Breathable Italian linen t-shirt with a relaxed V-neckline. Perfect for warm weather and casual elegance.',
                'short_description' => 'Breathable Italian linen V-neck', 'price' => 120.00, 'discount_price' => 95.00, 'stock' => 85, 'sku' => 'VL-TS-002',
                'image' => 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['t-shirts'], 'name' => 'Merino Wool Henley', 'slug' => 'merino-wool-henley',
                'description' => 'Fine merino wool henley with three-button placket. Temperature regulating and naturally odor-resistant.',
                'short_description' => 'Fine merino wool henley', 'price' => 145.00, 'discount_price' => null, 'stock' => 60, 'sku' => 'VL-TS-003',
                'image' => 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['t-shirts'], 'name' => 'Organic Cotton Pocket Tee', 'slug' => 'organic-cotton-pocket-tee',
                'description' => 'Sustainably sourced organic cotton with a chest pocket detail. Relaxed fit for everyday comfort.',
                'short_description' => 'Organic cotton pocket tee', 'price' => 65.00, 'discount_price' => null, 'stock' => 150, 'sku' => 'VL-TS-004',
                'image' => 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['t-shirts'], 'name' => 'Striped Breton Top', 'slug' => 'striped-breton-top',
                'description' => 'Classic Breton stripe pattern in navy and white. A timeless nautical-inspired piece.',
                'short_description' => 'Classic Breton stripe pattern', 'price' => 95.00, 'discount_price' => 75.00, 'stock' => 90, 'sku' => 'VL-TS-005',
                'image' => 'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=600', 'is_featured' => true, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['t-shirts'], 'name' => 'Cashmere Blend T-Shirt', 'slug' => 'cashmere-blend-t-shirt',
                'description' => 'Luxurious cashmere-cotton blend that drapes beautifully. The ultimate elevated basic.',
                'short_description' => 'Luxurious cashmere-cotton blend', 'price' => 195.00, 'discount_price' => null, 'stock' => 40, 'sku' => 'VL-TS-006',
                'image' => 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],

            // SHIRTS (7)
            [
                'category_id' => $c['shirts'], 'name' => 'Classic White Dress Shirt', 'slug' => 'classic-white-dress-shirt',
                'description' => 'The cornerstone of every gentleman\'s wardrobe. Egyptian cotton with a spread collar and French cuffs.',
                'short_description' => 'Egyptian cotton dress shirt', 'price' => 195.00, 'discount_price' => 145.00, 'stock' => 120, 'sku' => 'VL-SH-001',
                'image' => 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['shirts'], 'name' => 'Oxford Button-Down', 'slug' => 'oxford-button-down',
                'description' => 'Classic oxford cloth button-down in a versatile blue. Slightly relaxed for smart-casual wear.',
                'short_description' => 'Classic oxford cloth button-down', 'price' => 145.00, 'discount_price' => null, 'stock' => 100, 'sku' => 'VL-SH-002',
                'image' => 'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['shirts'], 'name' => 'Linen Camp Collar Shirt', 'slug' => 'linen-camp-collar-shirt',
                'description' => 'Relaxed camp collar shirt in pure French linen. Ideal for resort and summer evenings.',
                'short_description' => 'French linen camp collar', 'price' => 165.00, 'discount_price' => null, 'stock' => 75, 'sku' => 'VL-SH-003',
                'image' => 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['shirts'], 'name' => 'Flannel Check Shirt', 'slug' => 'flannel-check-shirt',
                'description' => 'Brushed cotton flannel in a classic check pattern. Warm and comfortable for layering.',
                'short_description' => 'Brushed cotton flannel check', 'price' => 135.00, 'discount_price' => 110.00, 'stock' => 80, 'sku' => 'VL-SH-004',
                'image' => 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['shirts'], 'name' => 'Slim Fit Denim Shirt', 'slug' => 'slim-fit-denim-shirt',
                'description' => 'Japanese selvedge denim shirt with a tailored slim fit. A modern workwear classic.',
                'short_description' => 'Japanese selvedge denim shirt', 'price' => 175.00, 'discount_price' => null, 'stock' => 65, 'sku' => 'VL-SH-005',
                'image' => 'https://images.unsplash.com/photo-1617127365659-c47b8641b0b0?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['shirts'], 'name' => 'Silk Polo Shirt', 'slug' => 'silk-polo-shirt',
                'description' => 'Silk-blend polo with a refined ribbed collar. Bridges casual and formal with effortless style.',
                'short_description' => 'Silk-blend polo shirt', 'price' => 225.00, 'discount_price' => null, 'stock' => 50, 'sku' => 'VL-SH-006',
                'image' => 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['shirts'], 'name' => ' Chambray Work Shirt', 'slug' => 'chambray-work-shirt',
                'description' => 'Soft chambray with dual chest pockets. A rugged yet refined everyday shirt.',
                'short_description' => 'Soft chambray work shirt', 'price' => 125.00, 'discount_price' => null, 'stock' => 95, 'sku' => 'VL-SH-007',
                'image' => 'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],

            // PANTS (6)
            [
                'category_id' => $c['pants'], 'name' => 'Slim Fit Tapered Trousers', 'slug' => 'slim-fit-tapered-trousers',
                'description' => 'Modern slim-fit trousers in stretch wool-blend. Flat front with tapered leg for a sharp silhouette.',
                'short_description' => 'Stretch wool-blend tapered trousers', 'price' => 295.00, 'discount_price' => null, 'stock' => 85, 'sku' => 'VL-PT-001',
                'image' => 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['pants'], 'name' => 'Italian Chinos', 'slug' => 'italian-chinos',
                'description' => 'Garment-dyed Italian cotton chinos. A smart-casual essential with a relaxed tapered fit.',
                'short_description' => 'Garment-dyed Italian chinos', 'price' => 185.00, 'discount_price' => 155.00, 'stock' => 110, 'sku' => 'VL-PT-002',
                'image' => 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['pants'], 'name' => 'Wool Dress Pants', 'slug' => 'wool-dress-pants',
                'description' => 'Italian wool flannel dress pants with a classic straight leg. Perfect for the boardroom.',
                'short_description' => 'Italian wool flannel dress pants', 'price' => 345.00, 'discount_price' => null, 'stock' => 55, 'sku' => 'VL-PT-003',
                'image' => 'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['pants'], 'name' => 'Cargo Jogger Pants', 'slug' => 'cargo-jogger-pants',
                'description' => 'Technical cargo joggers with elastic cuffs. Utility meets modern comfort.',
                'short_description' => 'Technical cargo joggers', 'price' => 155.00, 'discount_price' => null, 'stock' => 90, 'sku' => 'VL-PT-004',
                'image' => 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['pants'], 'name' => 'Linen Summer Pants', 'slug' => 'linen-summer-pants',
                'description' => 'Lightweight pure linen pants with an elastic waistband. Effortless summer style.',
                'short_description' => 'Lightweight pure linen pants', 'price' => 175.00, 'discount_price' => 140.00, 'stock' => 70, 'sku' => 'VL-PT-005',
                'image' => 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['pants'], 'name' => 'Pleated Wide Leg Trousers', 'slug' => 'pleated-wide-leg-trousers',
                'description' => 'Double-pleated wide leg trousers in wool-mohair blend. A bold statement piece.',
                'short_description' => 'Double-pleated wide leg trousers', 'price' => 385.00, 'discount_price' => null, 'stock' => 35, 'sku' => 'VL-PT-006',
                'image' => 'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],

            // JEANS (5)
            [
                'category_id' => $c['jeans'], 'name' => 'Slim Selvedge Denim', 'slug' => 'slim-selvedge-denim',
                'description' => 'Japanese selvedge denim in a modern slim fit. Raw unwashed for a personalized fade over time.',
                'short_description' => 'Japanese selvedge slim jeans', 'price' => 245.00, 'discount_price' => null, 'stock' => 80, 'sku' => 'VL-JN-001',
                'image' => 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600', 'is_featured' => true, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['jeans'], 'name' => 'Classic Straight Jeans', 'slug' => 'classic-straight-jeans',
                'description' => 'Heritage straight-leg jeans in medium wash. A timeless American classic.',
                'short_description' => 'Heritage straight-leg jeans', 'price' => 195.00, 'discount_price' => 165.00, 'stock' => 100, 'sku' => 'VL-JN-002',
                'image' => 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['jeans'], 'name' => 'Black Stretch Skinny Jeans', 'slug' => 'black-stretch-skinny-jeans',
                'description' => 'Jet black stretch denim with a skinny silhouette. Versatile day-to-night styling.',
                'short_description' => 'Jet black stretch skinny jeans', 'price' => 185.00, 'discount_price' => null, 'stock' => 95, 'sku' => 'VL-JN-003',
                'image' => 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['jeans'], 'name' => 'Relaxed Fit Carpenter Jeans', 'slug' => 'relaxed-fit-carpenter-jeans',
                'description' => 'Workwear-inspired carpenter jeans with hammer loop. Durable and comfortable.',
                'short_description' => 'Workwear carpenter jeans', 'price' => 165.00, 'discount_price' => null, 'stock' => 60, 'sku' => 'VL-JN-004',
                'image' => 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['jeans'], 'name' => 'Japanese Denim Tapered', 'slug' => 'japanese-denim-tapered',
                'description' => 'Premium Japanese denim with a tapered leg. Indigo blue with natural fading.',
                'short_description' => 'Premium Japanese tapered denim', 'price' => 275.00, 'discount_price' => null, 'stock' => 45, 'sku' => 'VL-JN-005',
                'image' => 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],

            // SHOES (6)
            [
                'category_id' => $c['shoes'], 'name' => 'Italian Leather Oxford Shoes', 'slug' => 'italian-leather-oxford-shoes',
                'description' => 'Handcrafted in Tuscany from full-grain calfskin. Cap-toe design with Goodyear welt construction.',
                'short_description' => 'Handcrafted Tuscan Oxfords', 'price' => 650.00, 'discount_price' => null, 'stock' => 28, 'sku' => 'VL-SHO-001',
                'image' => 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['shoes'], 'name' => 'Suede Chelsea Boots', 'slug' => 'suede-chelsea-boots',
                'description' => 'Italian suede Chelsea boots with elastic side panels. A modern classic.',
                'short_description' => 'Italian suede Chelsea boots', 'price' => 495.00, 'discount_price' => 425.00, 'stock' => 35, 'sku' => 'VL-SHO-002',
                'image' => 'https://images.unsplash.com/photo-1614252235316-8c857f0c8b7b?w=600', 'is_featured' => true, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['shoes'], 'name' => 'Minimal Leather Sneakers', 'slug' => 'minimal-leather-sneakers',
                'description' => 'Clean minimalist sneakers in smooth white leather. Premium comfort meets understated luxury.',
                'short_description' => 'Minimal white leather sneakers', 'price' => 345.00, 'discount_price' => null, 'stock' => 70, 'sku' => 'VL-SHO-003',
                'image' => 'https://images.unsplash.com/photo-1560243563-062bfc001d68?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['shoes'], 'name' => 'Suede Loafers', 'slug' => 'suede-loafers',
                'description' => 'Venetian-style suede loafers with hand-stitched detailing. Effortless sophistication.',
                'short_description' => 'Venetian suede loafers', 'price' => 395.00, 'discount_price' => null, 'stock' => 40, 'sku' => 'VL-SHO-004',
                'image' => 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['shoes'], 'name' => 'Desert Boots', 'slug' => 'desert-boots',
                'description' => 'Classic crepe-sole desert boots in premium suede. A timeless casual staple.',
                'short_description' => 'Premium suede desert boots', 'price' => 285.00, 'discount_price' => null, 'stock' => 55, 'sku' => 'VL-SHO-005',
                'image' => 'https://images.unsplash.com/photo-1614252235316-8c857f0c8b7b?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['shoes'], 'name' => 'Running Sneakers', 'slug' => 'running-sneakers',
                'description' => 'Performance running sneakers with responsive cushioning and breathable mesh upper.',
                'short_description' => 'Performance running sneakers', 'price' => 225.00, 'discount_price' => 185.00, 'stock' => 85, 'sku' => 'VL-SHO-006',
                'image' => 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],

            // ACCESSORIES (7)
            [
                'category_id' => $c['accessories'], 'name' => 'Silk Knit Tie', 'slug' => 'silk-knit-tie',
                'description' => 'Seven-fold silk tie, hand-rolled in Italy. Subtle woven texture adds depth to any ensemble.',
                'short_description' => 'Italian seven-fold silk tie', 'price' => 145.00, 'discount_price' => 95.00, 'stock' => 200, 'sku' => 'VL-AC-001',
                'image' => 'https://images.unsplash.com/photo-1589756823695-278bc923f962?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['accessories'], 'name' => 'Leather Messenger Bag', 'slug' => 'leather-messenger-bag',
                'description' => 'Full-grain Italian leather messenger with padded laptop compartment and brass hardware.',
                'short_description' => 'Italian leather messenger bag', 'price' => 750.00, 'discount_price' => 595.00, 'stock' => 22, 'sku' => 'VL-AC-002',
                'image' => 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 'is_featured' => true, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['accessories'], 'name' => 'Aviator Sunglasses', 'slug' => 'aviator-sunglasses',
                'description' => 'Gold-toned metal frames with gradient blue-green lenses. UV400 protection.',
                'short_description' => 'Gold aviator sunglasses', 'price' => 350.00, 'discount_price' => 275.00, 'stock' => 75, 'sku' => 'VL-AC-003',
                'image' => 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['accessories'], 'name' => 'Italian Leather Belt', 'slug' => 'italian-leather-belt',
                'description' => 'Full-grain Italian leather belt with brushed silver buckle. Reversible black/brown.',
                'short_description' => 'Reversible Italian leather belt', 'price' => 165.00, 'discount_price' => null, 'stock' => 130, 'sku' => 'VL-AC-004',
                'image' => 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['accessories'], 'name' => 'Leather Card Holder', 'slug' => 'leather-card-holder',
                'description' => 'Slim card holder in Saffiano leather with four card slots. RFID blocking.',
                'short_description' => 'Saffiano leather card holder', 'price' => 95.00, 'discount_price' => null, 'stock' => 180, 'sku' => 'VL-AC-005',
                'image' => 'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['accessories'], 'name' => 'Cashmere Scarf', 'slug' => 'cashmere-scarf',
                'description' => 'Pure Mongolian cashmere scarf in a generous size. Unmatched warmth and softness.',
                'short_description' => 'Pure Mongolian cashmere scarf', 'price' => 245.00, 'discount_price' => null, 'stock' => 60, 'sku' => 'VL-AC-006',
                'image' => 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['accessories'], 'name' => 'Woven Straw Hat', 'slug' => 'woven-straw-hat',
                'description' => 'Handwoven Italian straw hat with grosgrain ribbon. Summer essential.',
                'short_description' => 'Italian woven straw hat', 'price' => 135.00, 'discount_price' => null, 'stock' => 45, 'sku' => 'VL-AC-007',
                'image' => 'https://images.unsplash.com/photo-1521369909029-2afed882baee?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],

            // WATCHES (4)
            [
                'category_id' => $c['watches'], 'name' => 'Automatic Dive Watch', 'slug' => 'automatic-dive-watch',
                'description' => 'Swiss automatic movement with 300m water resistance. Ceramic bezel and sapphire crystal.',
                'short_description' => 'Swiss automatic dive watch', 'price' => 1250.00, 'discount_price' => null, 'stock' => 15, 'sku' => 'VL-WT-001',
                'image' => 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=600', 'is_featured' => true, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['watches'], 'name' => 'Minimalist Dress Watch', 'slug' => 'minimalist-dress-watch',
                'description' => 'Ultra-thin quartz movement with leather strap. Clean dial design for formal occasions.',
                'short_description' => 'Ultra-thin dress watch', 'price' => 495.00, 'discount_price' => null, 'stock' => 30, 'sku' => 'VL-WT-002',
                'image' => 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['watches'], 'name' => 'Chronograph Sport Watch', 'slug' => 'chronograph-sport-watch',
                'description' => 'Tachymeter bezel with chronograph complication. Stainless steel bracelet.',
                'short_description' => 'Stainless steel chronograph', 'price' => 895.00, 'discount_price' => 750.00, 'stock' => 20, 'sku' => 'VL-WT-003',
                'image' => 'https://images.unsplash.com/photo-1526045431048-f857369baa09?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['watches'], 'name' => 'Field Watch', 'slug' => 'field-watch',
                'description' => 'Military-inspired field watch with canvas strap. Luminous hands and 100m water resistance.',
                'short_description' => 'Military-inspired field watch', 'price' => 345.00, 'discount_price' => null, 'stock' => 40, 'sku' => 'VL-WT-004',
                'image' => 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],

            // OUTERWEAR (6)
            [
                'category_id' => $c['outerwear'], 'name' => 'Cashmere Overcoat', 'slug' => 'cashmere-overcoat',
                'description' => 'Pure Mongolian cashmere overcoat. Double-breasted with peak lapel. Unparalleled warmth.',
                'short_description' => 'Pure cashmere overcoat', 'price' => 1895.00, 'discount_price' => 1495.00, 'stock' => 15, 'sku' => 'VL-OW-001',
                'image' => 'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=600', 'is_featured' => true, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['outerwear'], 'name' => 'Slim Fit Wool Blazer', 'slug' => 'slim-fit-wool-blazer',
                'description' => 'Premium Italian wool blazer with notch lapels. Two-button closure and interior pockets.',
                'short_description' => 'Italian wool blazer', 'price' => 895.00, 'discount_price' => 695.00, 'stock' => 45, 'sku' => 'VL-OW-002',
                'image' => 'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['outerwear'], 'name' => 'Leather Biker Jacket', 'slug' => 'leather-biker-jacket',
                'description' => 'Lambskin leather biker jacket with asymmetric zip. A rebellious classic.',
                'short_description' => 'Lambskin leather biker jacket', 'price' => 1250.00, 'discount_price' => null, 'stock' => 25, 'sku' => 'VL-OW-003',
                'image' => 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600', 'is_featured' => true, 'is_trending' => true, 'is_active' => true,
            ],
            [
                'category_id' => $c['outerwear'], 'name' => 'Lightweight Bomber Jacket', 'slug' => 'lightweight-bomber-jacket',
                'description' => 'Satin-finish bomber jacket with ribbed cuffs. Perfect transitional piece.',
                'short_description' => 'Satin-finish bomber jacket', 'price' => 345.00, 'discount_price' => null, 'stock' => 60, 'sku' => 'VL-OW-004',
                'image' => 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['outerwear'], 'name' => 'Double Breasted Waistcoat', 'slug' => 'double-breasted-waistcoat',
                'description' => 'Premium wool-mohair blend waistcoat. Double-breasted with six buttons.',
                'short_description' => 'Wool-mohair waistcoat', 'price' => 445.00, 'discount_price' => 345.00, 'stock' => 30, 'sku' => 'VL-OW-005',
                'image' => 'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['outerwear'], 'name' => 'Trench Coat', 'slug' => 'trench-coat',
                'description' => 'Water-resistant cotton gabardine trench coat. Belted waist with storm flap.',
                'short_description' => 'Water-resistant gabardine trench', 'price' => 795.00, 'discount_price' => null, 'stock' => 35, 'sku' => 'VL-OW-006',
                'image' => 'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=600', 'is_featured' => false, 'is_trending' => true, 'is_active' => true,
            ],

            // EXTRA (3)
            [
                'category_id' => $c['t-shirts'], 'name' => 'Ribbed Tank Top', 'slug' => 'ribbed-tank-top',
                'description' => 'Heavyweight ribbed cotton tank top. Perfect for layering or wearing solo.',
                'short_description' => 'Heavyweight ribbed cotton tank', 'price' => 55.00, 'discount_price' => null, 'stock' => 140, 'sku' => 'VL-TS-007',
                'image' => 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600', 'is_featured' => false, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['accessories'], 'name' => 'Leather Weekend Bag', 'slug' => 'leather-weekend-bag',
                'description' => 'Full-grain leather weekend duffel with brass hardware. 40L capacity.',
                'short_description' => 'Full-grain leather weekend duffel', 'price' => 895.00, 'discount_price' => null, 'stock' => 18, 'sku' => 'VL-AC-008',
                'image' => 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
            [
                'category_id' => $c['shoes'], 'name' => 'Monk Strap Shoes', 'slug' => 'monk-strap-shoes',
                'description' => 'Double monk strap shoes in burnished Italian leather. A power move for the boardroom.',
                'short_description' => 'Burnished Italian monk straps', 'price' => 545.00, 'discount_price' => null, 'stock' => 25, 'sku' => 'VL-SHO-007',
                'image' => 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=600', 'is_featured' => true, 'is_trending' => false, 'is_active' => true,
            ],
        ];
    }
}
