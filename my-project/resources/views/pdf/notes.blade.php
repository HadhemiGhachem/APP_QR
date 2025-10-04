<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Relevé de Notes</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        h1 {
            text-align: center;
            color: #1a73e8;
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            font-size: 12px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Relevé de Notes</h1>
        <p>Examen: {{ $exam }}</p>
        <p>Date: {{ $exam_date }}</p>
    </div>

    <table>
        <thead>
            <tr>
                <th>Num. Inscription</th>
                <th>Nom</th>
                <th>Prénom</th>
                <th>CIN</th>
                <th>Note</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($notes as $note)
                <tr>
                    <td>{{ $note['numero_inscri'] }}</td>
                    <td>{{ $note['nom'] }}</td>
                    <td>{{ $note['prenom'] }}</td>
                    <td>{{ $note['cin'] }}</td>
                    <td>{{ number_format($note['note'], 2) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    <div class="footer">
        <p>Généré le {{ now()->format('d/m/Y') }}</p>
    </div>
</body>
</html>