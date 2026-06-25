<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ForceJsonRequest
{
    public function handle(Request $request, Closure $next): Response
    {
        $request->headers->set('Accept', 'application/json');

        if ($request->isJson()) {
            $request->headers->set('Content-Type', 'application/json');
        }

        return $next($request);
    }
}
