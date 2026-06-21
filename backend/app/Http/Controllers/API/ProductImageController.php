<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductImage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Jobs\PerformImageOperations;

class ProductImageController extends Controller
{
    public function index(Product $product): JsonResponse
    {
        $images = $product->images()->orderBy('sort_order')->get();

        return response()->json([
            'success' => true,
            'data' => $images->map(fn ($img) => [
                'id' => $img->id,
                'image' => $img->image,
                'thumbnail' => $img->thumbnail,
                'sort_order' => $img->sort_order,
                'url' => Storage::url($img->image),
                'thumbnail_url' => $img->thumbnail ? Storage::url($img->thumbnail) : null,
            ]),
        ]);
    }

    public function store(Request $request, Product $product): JsonResponse
    {
        $request->validate([
            'images' => 'required|array|max:10',
            'images.*' => 'required|file|image|mimes:jpg,jpeg,png,webp|max:5120',
        ]);

        $uploaded = [];
        foreach ($request->file('images') as $file) {
            $path = $file->store('products', 'public');
            $thumbnail = $this->createThumbnail($file);

            $image = ProductImage::create([
                'product_id' => $product->id,
                'image' => $path,
                'thumbnail' => $thumbnail,
                'sort_order' => $product->images()->count(),
            ]);

            $uploaded[] = $image;
        }

        return response()->json([
            'success' => true,
            'message' => count($uploaded) . ' image(s) uploaded.',
            'data' => $uploaded,
        ], 201);
    }

    public function update(Request $request, ProductImage $image): JsonResponse
    {
        $validated = $request->validate([
            'sort_order' => 'required|integer|min:0',
        ]);

        $image->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Image updated.',
            'data' => $image,
        ]);
    }

    public function destroy(ProductImage $image): JsonResponse
    {
        if ($image->image && Storage::disk('public')->exists($image->image)) {
            Storage::disk('public')->delete($image->image);
        }
        if ($image->thumbnail && Storage::disk('public')->exists($image->thumbnail)) {
            Storage::disk('public')->delete($image->thumbnail);
        }

        $image->delete();

        return response()->json([
            'success' => true,
            'message' => 'Image deleted.',
        ]);
    }

    public function reorder(Request $request, Product $product): JsonResponse
    {
        $validated = $request->validate([
            'order' => 'required|array',
            'order.*' => 'required|integer|exists:product_images,id',
        ]);

        foreach ($validated['order'] as $index => $imageId) {
            ProductImage::where('id', $imageId)->where('product_id', $product->id)->update(['sort_order' => $index]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Images reordered.',
        ]);
    }

    private function createThumbnail($file): string
    {
        $path = $file->store('products/thumbnails', 'public');
        $fullPath = Storage::disk('public')->path($path);

        try {
            $img = \Intervention\Image\Facades\Image::make($fullPath);
            $img->fit(300, 300);
            $img->save($fullPath, 80);
        } catch (\Exception $e) {
            // Thumbnail creation failed, use original
        }

        return $path;
    }
}
