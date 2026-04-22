select
    id_aluno,
    disciplina,
    cast(bimestre as integer) as bimestre,
    cast(nota as numeric(10,2)) as nota
from {{ source('educacao', 'avaliacao') }}
