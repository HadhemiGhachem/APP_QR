<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Données déchiffrées</title>
</head>
<body>
    <h2>Résultat du QR Code :</h2>
    <ul>
        <li><strong>ID :</strong> {{ $data->id }}</li>
        <li><strong>Nom :</strong> {{ $data->nom }}</li>
        <li><strong>Prénom :</strong> {{ $data->prenom }}</li>
        <li><strong>Examen :</strong> {{ $data->examen }}</li>
    </ul>
</body>
</html>
