package HTML::FormFu::I18N::fr;
use strict;

use base qw( HTML::FormFu::I18N );

our %Lexicon = (
    form_error_message =>
        'Votre requête contient des erreurs. Consultez les détails ci-dessous.',
    form_constraint_allornone => 'Erreur',
    form_constraint_ascii    => 'Ce champs contient des caratères non valides',
    form_constraint_autoset  => 'Ce champs contient un choix non valide',
    form_constraint_bool     => 'Ce champs doit avoir une valeur booléenne',
    form_constraint_callback => 'Entrée non valide',
    form_constraint_datetime => 'Date non valide',
    form_constraint_dependon => 'Erreur',
    form_constraint_email    => 'Ce champs doit contenir une adresse email',
    form_constraint_equal    => 'Erreur',
    form_constraint_file     => "Il ne s'agit pas d'un fichier",
    form_constraint_file_mime => 'Type de fichier non valide',
    form_constraint_file_size => 'Taille de fichier non valide',
    form_constraint_integer   => 'Ce champs doit être un entier',
    form_constraint_length    => 'Entrée non valide',
    form_constraint_minlength =>
        'Ce champs doit contenir au moins [_1] caractères',
    form_constraint_minmaxfields => 'Entrée non valide',
    form_constraint_maxlength =>
        'Ce champs doit contenir au maximum [_1] caractères',
    form_constraint_number => 'Ce champs doit être un nombre',
    form_constraint_printable =>
        'Ce champs contient des caractères non valides',
    form_constraint_range       => 'Entrée non valide',
    form_constraint_regex       => 'Entrée non valide',
    form_constraint_required    => 'Ce champs est obligatoire',
    form_constraint_set         => 'Ce champs contient un choix non valide',
    form_constraint_singlevalue => 'Ce champs accepte une seule valeur',
    form_constraint_word => 'Ce champs contient des caractères non valides',
    form_inflator_compounddatetime => 'Date non valide',
    form_inflator_datetime         => 'Date non valide',
    form_validator_callback        => 'Erreur lors de la validation',
    form_transformer_callback      => 'Erreur lors de la transformation',

    form_inflator_imager       => "Erreur lors de l'ouverture du fichier image",
    form_validator_imager_size => "Image à charger trop grosse",
    form_transformer_imager    => "Erreur lors du traitement de l'image",
);

1;
