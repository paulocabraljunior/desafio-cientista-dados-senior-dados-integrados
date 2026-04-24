-- "Nenhum registro de frequência deve ter data anterior ao ano letivo da turma"
-- Valida que a data de frequência não antecede o ano de fundação/letivo da turma em que o aluno foi matriculado.
with frequencia as (
    select id_turma, data_frequencia
    from {{ ref('stg_educacao__frequencia') }}
),
turma as (
    select id_turma, ano_letivo
    from {{ ref('stg_educacao__turma') }}
)

select
    f.id_turma,
    f.data_frequencia,
    t.ano_letivo
from frequencia f
join turma t on f.id_turma = t.id_turma
where extract('year' from f.data_frequencia) < t.ano_letivo
