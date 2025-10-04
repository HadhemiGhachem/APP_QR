<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Déchiffrer un QR Code</title>
</head>
<body>
    <h2>Coller la chaîne obtenue en scannant un QR chiffré :</h2>

    @if ($errors->any())
        <div style="color: red;">{{ $errors->first('code') }}</div>
    @endif

    <form method="POST" action="/dechiffrer">
        @csrf
        <textarea name="code" rows="4" cols="70" placeholder="Colle ici le contenu du QR chiffré..."></textarea><br><br>
        <button type="submit">Déchiffrer</button>
    </form>
</body>
</html>
