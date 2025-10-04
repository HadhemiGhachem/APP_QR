<?php
use App\Models\Student;
use Illuminate\Database\Seeder;

class StudentSeeder extends Seeder
{
    public function run(): void
    {
        Student::create([
            'cin' => 'AB12345',
            'numero_inscri' => '20250001',
            'first_name' => 'Jean',
            'last_name' => 'Dupont',
            'exam' => 'Informatique',
            'exam_date' => '2025-06-15',
            'qr_hash' => null,
            'qr_path' => null,
            'grade' => 'Excellent',
            'note' => 18.50,
        ]);
        // Ajoutez d'autres enregistrements ici
    }
}