select
    id_turma,
    id_escola,
    cast(serie as integer) as serie,
    turno,
    cast(ano_letivo as integer) as ano_letivo
from {{ source('educacao', 'turma') }}
