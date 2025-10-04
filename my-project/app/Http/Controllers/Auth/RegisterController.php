<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;


/**
 * @OA\Post(
 *     path="/api/register",
 *     summary="Enregistrer un nouvel utilisateur",
 *     tags={"Authentification"},
 *     @OA\RequestBody(
 *         required=true,
 *         @OA\JsonContent(
 *             required={"name", "email", "password"},
 *             @OA\Property(property="name", type="string", example="Jean Dupont"),
 *             @OA\Property(property="email", type="string", format="email", example="jean@example.com"),
 *             @OA\Property(property="password", type="string", format="password", example="secret123")
 *         )
 *     ),
 *     @OA\Response(
 *         response=200,
 *         description="Utilisateur enregistré avec succès",
 *         @OA\JsonContent(
 *             @OA\Property(property="user", type="object", description="Détails de l'utilisateur"),
 *             @OA\Property(property="token", type="string", example="1|XyzTokenString")
 *         )
 *     ),
 *     @OA\Response(
 *         response=422,
 *         description="Erreur de validation",
 *         @OA\JsonContent(
 *             @OA\Property(property="message", type="string", example="The email has already been taken.")
 *         )
 *     )
 * )
 */
 

class RegisterController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:6',
        ]);

        $user = \App\Models\User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('flutter-token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token
        ]);
    }
}
