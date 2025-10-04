<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\LogoutController;
use App\Http\Controllers\QrCodeController;
use App\Http\Controllers\QrExcelController;
use App\Http\Controllers\ExcelController;

Route::post('/register', [RegisterController::class, 'register']);
Route::post('/login', [LoginController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [LogoutController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});

Route::get('/qr-code', [QrCodeController::class, 'show']);




Route::post('/upload-excel', [ExcelController::class, 'uploadAndParse']);
Route::post('/generate-qrcodes', [ExcelController::class, 'generateQRCodes']);

Route::post('/generate-pdf', [ExcelController::class, 'generatePDF']);


// routes/api.php
Route::post('/upload-notes', [ExcelController::class, 'uploadNotes']);
// Pour afficher les QR codes générés à partir du contenu Excel

Route::post('/generate-notes-pdf', [ExcelController::class, 'generateNotesPdf']);
