<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Soft deletes for products
        Schema::table('products', function (Blueprint $table) {
            $table->softDeletes();
        });

        // Soft deletes for orders
        Schema::table('orders', function (Blueprint $table) {
            $table->softDeletes();
        });

        // Soft deletes for users
        Schema::table('users', function (Blueprint $table) {
            $table->softDeletes();
        });

        // Missing indexes for performance
        Schema::table('orders', function (Blueprint $table) {
            $table->index('user_id');
            $table->index('status');
        });

        Schema::table('reviews', function (Blueprint $table) {
            $table->index('product_id');
            $table->index('user_id');
        });

        Schema::table('cart_items', function (Blueprint $table) {
            $table->index('user_id');
        });

        Schema::table('wishlists', function (Blueprint $table) {
            $table->index('user_id');
        });

        Schema::table('order_items', function (Blueprint $table) {
            $table->index('order_id');
            $table->index('product_id');
        });

        Schema::table('payment_transactions', function (Blueprint $table) {
            $table->index('user_id');
            $table->index('order_id');
            $table->index('status');
        });

        Schema::table('addresses', function (Blueprint $table) {
            $table->index('user_id');
        });

        Schema::table('notifications', function (Blueprint $table) {
            $table->index('user_id');
            $table->index('read_at');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->dropSoftDeletes();
            $table->dropIndex(['user_id', 'status']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->dropIndex(['user_id', 'status']);
        });

        Schema::table('reviews', function (Blueprint $table) {
            $table->dropIndex(['product_id', 'user_id']);
        });

        Schema::table('cart_items', function (Blueprint $table) {
            $table->dropIndex(['user_id']);
        });

        Schema::table('wishlists', function (Blueprint $table) {
            $table->dropIndex(['user_id']);
        });

        Schema::table('order_items', function (Blueprint $table) {
            $table->dropIndex(['order_id', 'product_id']);
        });

        Schema::table('payment_transactions', function (Blueprint $table) {
            $table->dropIndex(['user_id', 'order_id', 'status']);
        });

        Schema::table('addresses', function (Blueprint $table) {
            $table->dropIndex(['user_id']);
        });

        Schema::table('notifications', function (Blueprint $table) {
            $table->dropIndex(['user_id', 'read_at']);
        });
    }
};
