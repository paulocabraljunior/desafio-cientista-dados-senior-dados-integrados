select
    id_turma,
    id_aluno,
    cast(null as int) as id_escola,
    cast(null as integer) as serie,
    cast(null as varchar) as turno,
    cast(ano as integer) as ano_letivo
from {{ source('educacao', 'turma') }}
