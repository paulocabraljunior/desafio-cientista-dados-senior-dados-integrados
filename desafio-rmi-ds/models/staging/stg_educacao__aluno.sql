select
    id_aluno,
    faixa_etaria,
    id_bairro
from {{ source('educacao', 'aluno') }}
