<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Follow;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SocialController extends Controller
{
    public function follow(Request $request, User $user): JsonResponse
    {
        if ($request->user()->id === $user->id) {
            return response()->json(['success' => false, 'message' => 'Cannot follow yourself.'], 422);
        }

        $exists = Follow::where('follower_id', $request->user()->id)
            ->where('following_id', $user->id)
            ->exists();

        if ($exists) {
            Follow::where('follower_id', $request->user()->id)
                ->where('following_id', $user->id)
                ->delete();

            return response()->json(['success' => true, 'message' => 'Unfollowed.', 'is_following' => false]);
        }

        Follow::create([
            'follower_id' => $request->user()->id,
            'following_id' => $user->id,
        ]);

        return response()->json(['success' => true, 'message' => 'Following.', 'is_following' => true], 201);
    }

    public function followers(Request $request, User $user): JsonResponse
    {
        $followers = User::whereIn('id', Follow::where('following_id', $user->id)->pluck('follower_id'))
            ->get(['id', 'name', 'avatar']);

        return response()->json(['success' => true, 'data' => $followers]);
    }

    public function following(Request $request, User $user): JsonResponse
    {
        $following = User::whereIn('id', Follow::where('follower_id', $user->id)->pluck('following_id'))
            ->get(['id', 'name', 'avatar']);

        return response()->json(['success' => true, 'data' => $following]);
    }

    public function feed(Request $request): JsonResponse
    {
        $followingIds = Follow::where('follower_id', $request->user()->id)->pluck('following_id');
        $followingIds->push($request->user()->id);

        $posts = Post::with('user:id,name,avatar')
            ->whereIn('user_id', $followingIds)
            ->withCount(['likes', 'comments'])
            ->with(['likes' => fn ($q) => $q->where('user_id', $request->user()->id)])
            ->latest()
            ->paginate(20);

        $posts->getCollection()->transform(function ($post) {
            $post->is_liked = $post->likes_count > 0 && $post->likes->isNotEmpty();
            unset($post->likes);
            return $post;
        });

        return response()->json([
            'success' => true,
            'data' => $posts,
        ]);
    }
}
