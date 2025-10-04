<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>QR Codes Étudiants</title>
</head>
<body>
    <h2>QR Codes générés :</h2>
    @foreach ($qrs as $qr)
        <div style="margin-bottom: 20px;">
            {!! $qr !!}
        </div>
    @endforeach
</body>
</html>
