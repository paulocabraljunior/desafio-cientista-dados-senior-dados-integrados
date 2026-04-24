select
    id_aluno,
    id_turma,
    id_escola,
    cast(data_inicio as date) as data_frequencia,
    frequencia,
    disciplina,
    cast(null as varchar) as status
from {{ source('educacao', 'frequencia') }}
