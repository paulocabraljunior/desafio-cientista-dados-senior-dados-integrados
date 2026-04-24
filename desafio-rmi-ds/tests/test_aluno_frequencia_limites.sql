-- "A taxa média de frequência de um aluno consolidada não pode ser negativa ou maior que 100%"
-- Valida que a lógica do intermediate manteve a integridade matemática da presença.
with aluno_frequencia as (
    select sk_aluno_turma, id_aluno, taxa_frequencia
    from {{ ref('int_educacao__aluno_frequencia') }}
)

select
    sk_aluno_turma,
    id_aluno,
    taxa_frequencia
from aluno_frequencia
where taxa_frequencia < 0.0 or taxa_frequencia > 100.0
