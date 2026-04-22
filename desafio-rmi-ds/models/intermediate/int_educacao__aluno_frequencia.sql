with frequencia as (
    select * from {{ ref('stg_educacao__frequencia') }}
),
turma as (
    select * from {{ ref('stg_educacao__turma') }}
)

select
    f.id_aluno,
    f.id_turma,
    t.id_escola,
    count(f.data_frequencia) as total_aulas,
    sum(case when f.status = 'Presente' then 1 else 0 end) as total_presencas,
    sum(case when f.status = 'Ausente' then 1 else 0 end) as total_ausencias,
    case
        when count(f.data_frequencia) > 0
        then cast(sum(case when f.status = 'Presente' then 1 else 0 end) as float) / count(f.data_frequencia)
        else null
    end as taxa_frequencia
from frequencia f
left join turma t on f.id_turma = t.id_turma
group by 1, 2, 3
