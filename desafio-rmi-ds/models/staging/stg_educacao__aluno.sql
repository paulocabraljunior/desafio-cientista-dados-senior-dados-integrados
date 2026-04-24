select
    id_aluno,
    id_turma,
    faixa_etaria,
    bairro as id_bairro
from {{ source('educacao', 'aluno') }}
