-- "A soma de presença + ausência por aluno/dia não deve ultrapassar a carga horária da turma"
-- Dado que não temos carga horária, podemos adaptar para: "Um aluno não deve ter mais de um registro de frequência na mesma turma no mesmo dia"
with frequencia as (
    select * from {{ ref('stg_educacao__frequencia') }}
)

select
    id_aluno,
    id_turma,
    data_frequencia,
    count(*) as qtd_registros
from frequencia
group by 1, 2, 3
having count(*) > 1
