<?php

namespace App\Http\Controllers;

use SimpleSoftwareIO\QrCode\Facades\QrCode;

class QrCodeController extends Controller
{
    public function show()
    {
        $qr = QrCode::size(300)->generate('Bonjour Laravel QR Code !');
        return view('qr', ['qrCode' => $qr]);
    }



    
}
