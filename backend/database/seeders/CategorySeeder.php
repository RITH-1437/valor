<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'T-Shirts', 'slug' => 't-shirts', 'description' => 'Premium cotton and linen t-shirts for the modern gentleman.'],
            ['name' => 'Shirts', 'slug' => 'shirts', 'description' => 'Dress shirts, casual shirts, and polo shirts crafted from finest fabrics.'],
            ['name' => 'Pants', 'slug' => 'pants', 'description' => 'Tailored trousers, chinos, and dress pants for every occasion.'],
            ['name' => 'Jeans', 'slug' => 'jeans', 'description' => 'Premium denim jeans in slim, straight, and relaxed fits.'],
            ['name' => 'Shoes', 'slug' => 'shoes', 'description' => 'Italian leather shoes, sneakers, and formal footwear.'],
            ['name' => 'Accessories', 'slug' => 'accessories', 'description' => 'Belts, wallets, sunglasses, and finishing touches.'],
            ['name' => 'Watches', 'slug' => 'watches', 'description' => 'Luxury timepieces and everyday watches.'],
            ['name' => 'Outerwear', 'slug' => 'outerwear', 'description' => 'Jackets, coats, and layering pieces for all seasons.'],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
