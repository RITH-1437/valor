<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Soft deletes for products
        if (!Schema::hasColumn('products', 'deleted_at')) {
            Schema::table('products', function (Blueprint $table) {
                $table->softDeletes();
            });
        }

        // Soft deletes for orders
        if (!Schema::hasColumn('orders', 'deleted_at')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->softDeletes();
            });
        }

        // Soft deletes for users
        if (!Schema::hasColumn('users', 'deleted_at')) {
            Schema::table('users', function (Blueprint $table) {
                $table->softDeletes();
            });
        }

        // Missing indexes for performance (check each before adding)
        $this->addIndexIfMissing('orders', ['user_id']);
        $this->addIndexIfMissing('orders', ['status']);
        $this->addIndexIfMissing('reviews', ['product_id']);
        $this->addIndexIfMissing('reviews', ['user_id']);
        $this->addIndexIfMissing('cart_items', ['user_id']);
        $this->addIndexIfMissing('wishlists', ['user_id']);
        $this->addIndexIfMissing('order_items', ['order_id']);
        $this->addIndexIfMissing('order_items', ['product_id']);
        $this->addIndexIfMissing('payment_transactions', ['user_id']);
        $this->addIndexIfMissing('payment_transactions', ['order_id']);
        $this->addIndexIfMissing('payment_transactions', ['status']);
        $this->addIndexIfMissing('addresses', ['user_id']);
        $this->addIndexIfMissing('notifications', ['user_id']);
        $this->addIndexIfMissing('notifications', ['is_read']);
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
        Schema::table('orders', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
        Schema::table('users', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
    }

    private function addIndexIfMissing(string $table, array $columns): void
    {
        $indexName = $table . '_' . implode('_', $columns) . '_index';
        if (!Schema::hasIndex($table, $columns)) {
            Schema::table($table, function (Blueprint $table) use ($columns) {
                $table->index($columns);
            });
        }
    }
};
