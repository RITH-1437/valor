<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('size_recommendations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->integer('height_cm');
            $table->integer('weight_kg');
            $table->string('body_type')->nullable();
            $table->string('recommended_size');
            $table->timestamps();

            $table->index('user_id');
        });

        Schema::create('stylist_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->string('occasion');
            $table->json('recommendations');
            $table->timestamps();

            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stylist_sessions');
        Schema::dropIfExists('size_recommendations');
    }
};
