<?php
namespace App\Http\Controllers;
namespace App\Http\Controllers\Auth;


use Illuminate\Support\Facades\Route;
use App\Http\Controllers\QrCodeController;
use App\Http\Controllers\QrExcelController;
use App\Http\Controllers\Auth\RegisterController;



Route::get('/', function () {
    return view('welcome');
});
