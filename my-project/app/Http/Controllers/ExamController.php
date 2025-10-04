<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Student;
use PhpOffice\PhpSpreadsheet\IOFactory;

/**
 * @OA\Post(
 *     path="/api/import-notes",
 *     summary="Importer les notes depuis un fichier Excel",
 *     description="Charge un fichier Excel de correction, extrait numero_inscri + note, met à jour la base de données et retourne la liste finale des étudiants.",
 *     tags={"Examens"},
 *     @OA\RequestBody(
 *         required=true,
 *         @OA\MediaType(
 *             mediaType="multipart/form-data",
 *             @OA\Schema(
 *                 required={"file"},
 *                 @OA\Property(
 *                     property="file",
 *                     type="string",
 *                     format="binary",
 *                     description="Fichier Excel (.xlsx ou .xls) contenant les numéros d’inscription et les notes"
 *                 )
 *             )
 *         )
 *     ),
 *     @OA\Response(
 *         response=200,
 *         description="Liste des étudiants avec leurs notes",
 *         @OA\JsonContent(
 *             type="array",
 *             @OA\Items(
 *                 @OA\Property(property="id", type="integer", example=1),
 *                 @OA\Property(property="cin", type="string", example="12345678"),
 *                 @OA\Property(property="numero_inscri", type="string", example="20231234"),
 *                 @OA\Property(property="first_name", type="string", example="Ali"),
 *                 @OA\Property(property="last_name", type="string", example="Ben Salah"),
 *                 @OA\Property(property="exam", type="string", example="Maths"),
 *                 @OA\Property(property="exam_date", type="string", format="date", example="2025-06-01"),
 *                 @OA\Property(property="qr_hash", type="string", example="a1b2c3d4e5"),
 *                 @OA\Property(property="qr_path", type="string", example="storage/qrcodes/1234.png"),
 *                 @OA\Property(property="note", type="number", format="float", example=14.75),
 *                 @OA\Property(property="created_at", type="string", format="date-time"),
 *                 @OA\Property(property="updated_at", type="string", format="date-time")
 *             )
 *         )
 *     ),
 *     @OA\Response(
 *         response=400,
 *         description="Requête invalide (fichier manquant ou mauvais format)"
 *     )
 * )
 */


class ExamController extends Controller
{
    public function importNotes(Request $request)
    {
        // 1. Vérifier si le fichier est uploadé
        $request->validate([
            'file' => 'required|mimes:xlsx,xls',
        ]);

        $file = $request->file('file');
        $spreadsheet = IOFactory::load($file->getPathName());
        $worksheet = $spreadsheet->getActiveSheet();

        // 2. Parcourir les lignes Excel
        foreach ($worksheet->getRowIterator(2) as $row) { // commence à la 2ème ligne (en-têtes ignorés)
            $cellIterator = $row->getCellIterator();
            $cellIterator->setIterateOnlyExistingCells(false);

            $cells = [];
            foreach ($cellIterator as $cell) {
                $cells[] = $cell->getValue();
            }

            // Exemple : supposons colonne A = numInscri, colonne B = note
            $numInscriExcel = $cells[0];
            $note = $cells[1];

            // On prend les 4 derniers chiffres
            $lastFour = substr($numInscriExcel, -4);

            // 3. Chercher l'étudiant
            $student = Student::where('numero_inscri', 'LIKE', "%{$lastFour}")->first();

            if ($student) {
                // 4. Mettre à jour la note
                $student->note = $note;
                $student->save();
            }
        }

        // 5. Retourner la liste finale des étudiants avec leurs notes
        return response()->json(Student::all());
    }
}


?>