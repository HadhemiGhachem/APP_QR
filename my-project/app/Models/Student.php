<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    use HasFactory;

    protected $fillable = [
    'cin',
    'numero_inscri',
    'first_name',
    'last_name',
    'exam',
    'exam_date',
    'qr_hash',
    'qr_path',
    'grade',
    'note',
];


 // ⭐️ AJOUT CRUCIAL : Ces champs virtuels seront inclus dans la réponse JSON
    protected $appends = ['nom', 'prenom'];

    /**
     * Accessor pour retourner le champ last_name sous la clé 'nom' (pour le JSON).
     */
    public function getNomAttribute()
    {
        return $this->attributes['last_name'] ?? '';
    }

    /**
     * Accessor pour retourner le champ first_name sous la clé 'prenom' (pour le JSON).
     */
    public function getPrenomAttribute()
    {
        return $this->attributes['first_name'] ?? '';
    }

}

