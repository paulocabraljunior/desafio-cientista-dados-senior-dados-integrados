with frequencia as (
    select * from {{ ref('stg_educacao__frequencia') }}
),
turma as (
    select * from {{ ref('stg_educacao__turma') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['f.id_aluno', 'f.id_turma']) }} as sk_aluno_turma,
    f.id_aluno,
    f.id_turma,
    f.id_escola,
    count(f.data_frequencia) as total_aulas,
    sum(case when f.status = 'Presente' then 1 else 0 end) as total_presencas,
    sum(case when f.status = 'Ausente' then 1 else 0 end) as total_ausencias,
    avg(f.frequencia) as taxa_frequencia
from frequencia f
group by 1, 2, 3, 4
