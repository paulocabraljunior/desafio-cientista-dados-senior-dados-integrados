{{ config(
    materialized='table',
    tags=['marts', 'educacao', 'absenteismo']
) }}

with aluno_frequencia as (
    select * from {{ ref('int_educacao__aluno_frequencia') }}
),

escola as (
    select * from {{ ref('stg_educacao__escola') }}
)

select
    e.regiao,
    e.id_escola,
    -- Contagem total de alunos na escola
    count(distinct af.id_aluno) as total_alunos,

    -- Contagem de alunos críticos (< 75% de presença)
    count(distinct case when af.taxa_frequencia < 0.75 then af.id_aluno end) as alunos_absenteismo_cronico,

    -- Cálculo da taxa com prevenção de divisão por zero via NULLIF e formatação para o BI
    round(
        count(distinct case when af.taxa_frequencia < 0.75 then af.id_aluno end) * 1.0
        / nullif(count(distinct af.id_aluno), 0),
        4
    ) as taxa_absenteismo_cronico

from escola e
left join aluno_frequencia af
    on e.id_escola = af.id_escola
group by 1, 2
