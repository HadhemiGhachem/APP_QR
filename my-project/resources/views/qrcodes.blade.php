<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>QR Codes</title>
    <style>
        body { font-family: sans-serif; }
        .student { margin-bottom: 20px; text-align: center; }
        .qrcode { margin-top: 8px; }
        h2 { margin-bottom: 0; }
        h4 { margin: 0; font-weight: normal; }
    </style>
</head>
<body>
    @if(!empty($qrcodes))
        <h1 style="text-align:center;">{{ $qrcodes[0]['exam'] }} - {{ $qrcodes[0]['exam_date'] }}</h1>

        @foreach($qrcodes as $student)
            <div class="student">
                <h2>{{ $student['nom'] }} {{ $student['prenom'] }}</h2>
                <h4>ID: {{ $student['student_id'] }} | CIN: {{ $student['cin'] }}</h4>
                <div class="qrcode">
                    <img src="data:image/png;base64,{{ $student['qrcode'] }}" alt="QR Code" width="150" height="150">
                </div>
            </div>
        @endforeach
    @else
        <p>Aucun QR code disponible.</p>
    @endif
</body>
</html>
