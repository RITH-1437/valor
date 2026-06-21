<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Post;
use App\Models\PostComment;
use App\Models\PostLike;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $posts = Post::with('user:id,name,avatar')
            ->withCount(['likes', 'comments'])
            ->with(['likes' => fn ($q) => $q->where('user_id', $request->user()->id)])
            ->latest()
            ->paginate(20);

        $posts->getCollection()->transform(function ($post) {
            $post->is_liked = $post->likes_count > 0 && $post->likes->isNotEmpty();
            unset($post->likes);
            return $post;
        });

        return response()->json(['success' => true, 'data' => $posts]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'content' => 'nullable|string|max:1000',
            'image' => 'nullable|file|image|mimes:jpg,jpeg,png,webp|max:5120',
            'style_tags' => 'nullable|string|max:255',
        ]);

        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('posts', 'public');
        }

        $validated['user_id'] = $request->user()->id;

        $post = Post::create($validated);
        $post->load('user:id,name,avatar');
        $post->likes_count = 0;
        $post->comments_count = 0;
        $post->is_liked = false;

        return response()->json(['success' => true, 'data' => $post], 201);
    }

    public function show(Post $post): JsonResponse
    {
        $post->load('user:id,name,avatar');
        $post->loadCount(['likes', 'comments']);
        $post->load('comments.user:id,name,avatar');

        return response()->json(['success' => true, 'data' => $post]);
    }

    public function destroy(Request $request, Post $post): JsonResponse
    {
        if ($post->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        if ($post->image && Storage::disk('public')->exists($post->image)) {
            Storage::disk('public')->delete($post->image);
        }

        $post->delete();

        return response()->json(['success' => true, 'message' => 'Post deleted.']);
    }

    public function like(Request $request, Post $post): JsonResponse
    {
        $exists = PostLike::where('user_id', $request->user()->id)->where('post_id', $post->id)->exists();

        if ($exists) {
            PostLike::where('user_id', $request->user()->id)->where('post_id', $post->id)->delete();
            $post->decrement('likes_count');
            return response()->json(['success' => true, 'is_liked' => false, 'likes_count' => $post->likes_count]);
        }

        PostLike::create(['user_id' => $request->user()->id, 'post_id' => $post->id]);
        $post->increment('likes_count');

        return response()->json(['success' => true, 'is_liked' => true, 'likes_count' => $post->likes_count], 201);
    }

    public function comment(Request $request, Post $post): JsonResponse
    {
        $validated = $request->validate(['comment' => 'required|string|max:500']);

        $comment = PostComment::create([
            'user_id' => $request->user()->id,
            'post_id' => $post->id,
            'comment' => $validated['comment'],
        ]);

        $post->increment('comments_count');
        $comment->load('user:id,name,avatar');

        return response()->json(['success' => true, 'data' => $comment], 201);
    }
}
