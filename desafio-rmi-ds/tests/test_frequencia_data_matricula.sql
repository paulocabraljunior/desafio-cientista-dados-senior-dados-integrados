-- "Nenhum registro de frequência deve ter data anterior à data de matrícula do aluno naquela turma"
-- Dado que não temos a data exata da matrícula, e sim frequências, essa regra pode não ser estritamente
-- aplicável aos dados disponibilizados de forma determinística, então usamos a data mínima de aula
-- da turma como um proxy (início das aulas da turma), mas em uma base real, cruzaríamos com a tabela `matricula`.

with frequencia as (
    select * from {{ ref('stg_educacao__frequencia') }}
),
-- Inferindo o "início do ano letivo da turma" como a data mais antiga registrada para a turma:
inicio_aulas_turma as (
    select id_turma, min(data_frequencia) as data_inicio_turma
    from frequencia
    group by 1
)

select
    f.id_aluno,
    f.id_turma,
    f.data_frequencia,
    i.data_inicio_turma
from frequencia f
join inicio_aulas_turma i
    on f.id_turma = i.id_turma
where f.data_frequencia < i.data_inicio_turma
