select
    id_escola,
    tipo,
    regiao
from {{ source('educacao', 'escola') }}
