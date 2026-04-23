select
    id_aluno,
    id_turma,
    cast(data as date) as data_frequencia,
    status
from {{ source('educacao', 'frequencia') }}
