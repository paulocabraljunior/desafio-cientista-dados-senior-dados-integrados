{{ config(severity = 'warn') }}

-- "Alerta de vazamento de dados: quantidade anormal de registros com frequência cravada em 100.0"
with frequencia as (
    select frequencia
    from {{ ref('stg_educacao__frequencia') }}
    where frequencia = 100.0
)

select count(*) as qtd_100
from frequencia
having count(*) > 1000000
