select
    id_escola,
    bairro as id_bairro,
    cast(null as varchar) as tipo,
    cast(null as varchar) as regiao
from {{ source('educacao', 'escola') }}
