with source as (
    select * from {{ source('educacao', 'escola') }}
),
dominio as (
    select * from {{ ref('escola_dominio') }}
)

select
    s.id_escola,
    s.bairro as id_bairro,
    d.tipo,
    d.regiao
from source s
left join dominio d on cast(s.id_escola as varchar) = cast(d.id_escola as varchar)
