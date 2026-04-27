with stg_avaliacao as (
    select * from {{ ref('stg_educacao__avaliacao') }}
)

select
    id_aluno,
    id_turma,
    bimestre,
    frequencia,
    disciplina,
    nota
from stg_avaliacao
unpivot (
    nota for disciplina in (disciplina_1, disciplina_2, disciplina_3, disciplina_4)
)
