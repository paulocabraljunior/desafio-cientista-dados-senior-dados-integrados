select
    id_aluno,
    id_turma,
    cast(bimestre as integer) as bimestre,
    frequencia,
    cast(disciplina_1 as numeric(10,2)) as disciplina_1,
    cast(disciplina_2 as numeric(10,2)) as disciplina_2,
    cast(disciplina_3 as numeric(10,2)) as disciplina_3,
    cast(disciplina_4 as numeric(10,2)) as disciplina_4
from {{ source('educacao', 'avaliacao') }}
