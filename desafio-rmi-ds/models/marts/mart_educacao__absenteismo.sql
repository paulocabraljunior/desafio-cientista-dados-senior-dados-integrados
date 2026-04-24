with aluno_frequencia as (
    select * from {{ ref('int_educacao__aluno_frequencia') }}
),
escola as (
    select * from {{ ref('stg_educacao__escola') }}
)

select
    e.regiao,
    cast(e.id_escola as varchar) as id_escola,
    count(distinct af.id_aluno) as total_alunos,
    count(distinct case when af.taxa_frequencia < 0.75 then af.id_aluno else null end) as alunos_absenteismo_cronico,
    case
        when count(distinct af.id_aluno) > 0
        then cast(count(distinct case when af.taxa_frequencia < 0.75 then af.id_aluno else null end) as double) / count(distinct af.id_aluno)
        else null
    end as taxa_absenteismo_cronico
from aluno_frequencia af
left join escola e on af.id_escola = e.id_escola
group by 1, 2
