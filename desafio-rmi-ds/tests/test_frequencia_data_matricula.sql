-- "Nenhum registro de frequência deve ter data anterior à data de matrícula do aluno naquela turma"
-- Como não temos a data exata da matrícula ou a tabela matricula, validamos se
-- o ano da frequência corresponde ao ano letivo da turma como um proxy lógico para essa regra de negócio.

with frequencia as (
    select * from {{ ref('stg_educacao__frequencia') }}
),
turma as (
    select * from {{ ref('stg_educacao__turma') }}
)

select
    f.id_aluno,
    f.id_turma,
    f.data_frequencia,
    t.ano_letivo
from frequencia f
join turma t on f.id_turma = t.id_turma
where extract(year from f.data_frequencia) < t.ano_letivo
