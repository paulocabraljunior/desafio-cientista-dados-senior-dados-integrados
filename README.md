# Desafio RMI - Cientista de Dados Sênior (Engenharia de Analytics)

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![DuckDB](https://img.shields.io/badge/DuckDB-FFF000?style=for-the-badge&logo=duckdb&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

## Visão Geral
Este projeto foi desenvolvido como resposta ao desafio de **Cientista de Dados Sênior** do **Registro Municipal Integrado (RMI)** da Prefeitura do Rio de Janeiro.

O objetivo do projeto é demonstrar proficiência em engenharia de analytics através da modelagem de dados educacionais, implementação de testes para garantir a confiabilidade da informação e documentação acessível da arquitetura e das decisões do negócio.

## Arquitetura e Modelagem
Foi utilizado o **dbt-core** com o adaptador **DuckDB** (`dbt-duckdb`). Esta escolha permite rodar localmente de maneira robusta, simulando o comportamento de um banco de dados analítico.

O projeto segue a estrutura tradicional de camadas do dbt:

1. **Staging (`models/staging/`)**
   - Importa os dados originais (em formato parquet) através das definições no `sources.yml`.
   - Limpa, padroniza nomenclaturas (case, convenção de nomes) e atribui tipagens explícitas.
   - Aplica testes genéricos robustos (unicidade, not_null, accepted_values, relationships) visando a identificação imediata de dados que não aderem à especificação mínima.

2. **Intermediate (`models/intermediate/`)**
   - O modelo `int_educacao__aluno_frequencia.sql` consolida os alunos, turmas e frequências em uma única fonte de verdade por aluno, calculando agregações como "total_aulas", "total_presencas", "total_ausencias" e "taxa_frequencia".
   - Serve como principal fonte de preparação para os marts, garantindo a redução de redundância em lógicas de agregação.

3. **Marts (`models/marts/`)**
   - O modelo `mart_educacao__absenteismo.sql` é a camada de consumo, materializado como `table`.
   - Responde diretamente a uma pergunta de negócio estratégica: *Quais escolas/regiões têm maior taxa de alunos com frequência abaixo de 75%?*

## Estratégia de Testes
A confiabilidade dos dados do RMI é crítica, logo a estratégia de testes engloba:

- **Testes Genéricos (Schema Tests)**: Garantem chaves primárias (`unique`, `not_null`), relações referenciais (`relationships`) e limites de domínio numérico ou categórico (`accepted_values`).
- **Testes de Regra de Negócio (Singular Tests)**:
  - `test_frequencia_data_matricula`: Assegura que nenhum aluno possui registro de frequência anterior à data de matrícula.
  - `test_frequencia_carga_horaria_diaria`: Assegura a integridade transacional de registros ao validar que um aluno não possui mais de um registro de frequência em uma mesma turma no mesmo dia.

## Integração Contínua (CI/CD)

Para garantir a qualidade e a governança do código, este repositório utiliza **GitHub Actions**:
- **Continuous Integration (CI):** A cada Pull Request, um pipeline é acionado para validar a formatação do SQL, compilar os modelos dbt e executar a malha de testes (`dbt build`) em um ambiente isolado. Isso garante que nenhuma alteração que quebre regras de negócio ou granularidade chegue à branch principal.

# Diferenciais Implementados (Going Beyond)
Para garantir o mais alto nível de governança, este projeto implementa funcionalidades avançadas do dbt:
- **Data Contracts:** Aplicados na camada de Marts (`contract: {enforced: true}`) para garantir que nenhuma alteração quebre os tipos de dados consumidos pelos painéis de BI.
- **dbt Packages:** Utilização do `dbt_utils` para geração segura de chaves (surrogate keys) e `dbt_expectations` para testes de distribuição e expressões regulares, elevando o rigor além dos testes genéricos padrão.
- **CI/CD Automatizado:** Pipeline configurada via GitHub Actions para rodar linters e `dbt build` a cada Pull Request.

## Trade-offs
- **Ambiente de Data Warehouse:** Optei por rodar o desafio via DuckDB em vez do BigQuery para isolar a infraestrutura local, removendo o ônus de requerer conta GCP ativa do avaliador para execução. Em um ambiente produtivo real, este projeto é perfeitamente portável para o adapter do BigQuery (`dbt-bigquery`).

## Setup e Execução

### Pré-requisitos
- Python 3.10+
- Instalar as dependências via pip:
```bash
pip install dbt-core dbt-duckdb duckdb
```

### Executando o Projeto

1. Clone o repositório e navegue até a pasta do projeto:
```bash
cd desafio-rmi-ds
```

2. Verifique se o dbt consegue se conectar corretamente (e resolve as dependências corretamente):
```bash
dbt debug
```

3. Execute todas as camadas da pipeline:
```bash
dbt build
```
O comando `dbt build` é preferível pois executa e roda os testes em cascata, bloqueando materializações dependentes caso um teste falhe na origem.


### Configuração do profiles.yml

Crie um arquivo chamado `profiles.yml` na raiz da pasta `~/.dbt/` contendo a configuração abaixo para uso com o DuckDB:

```yaml
desafio_rmi_ds:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'rmi.duckdb'
      extensions:
        - httpfs
        - parquet
```
