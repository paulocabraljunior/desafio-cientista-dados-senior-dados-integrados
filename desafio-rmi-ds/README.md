# Desafio RMI - Analytics Engineering

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![DuckDB](https://img.shields.io/badge/DuckDB-FFF000?style=for-the-badge&logo=duckdb&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

## Visão Geral
Este projeto estrutura o pipeline analítico para dados educacionais do RMI, seguindo padrões de classe Enterprise. O projeto combina Analytics Engineering (via dbt) utilizando a arquitetura Medallion para transformar e testar dados antes que alcancem as camadas de consumo do BI.

## Arquitetura de Dados (dbt/Medallion)
1. **Staging (`models/staging/`)**
   - Importa os dados parquet originais provindos de um data lake (GCS).
   - Tipagem rigorosa, padronização e testes genéricos primários (garantia da unicidade e não nulidade de chaves).
2. **Intermediate (`models/intermediate/`)**
   - Cruza fontes isoladas (frequência, turma, aluno) criando tabelas consolidadas preparatórias.
3. **Marts (`models/marts/`)**
   - Agregações de negócio que respondem diretamente a perguntas estratégicas, como as taxas de absenteísmo crônico escolar.

## Diferenciais Implementados (Going Beyond)
Para garantir o mais alto nível de governança, este projeto implementa funcionalidades avançadas do dbt:
- **Data Contracts:** Aplicados na camada de Marts (`contract: {enforced: true}`) para garantir que nenhuma alteração quebre os tipos de dados consumidos pelos painéis de BI.
- **dbt Packages:** Utilização do `dbt_utils` para geração segura de chaves (surrogate keys) e `dbt_expectations` para testes de distribuição, ranges numéricos e expressões regulares, elevando o rigor além dos testes genéricos padrão.
- **CI/CD Automatizado:** Pipeline configurada via GitHub Actions para rodar linters (SQLFluff, Ruff) e `dbt build` a cada Pull Request garantindo automação de testes e checagem de qualidade antes do merge.

## Governança e Qualidade
O repositório está blindado por políticas de governança:
- **Pull Requests (PRs)**: Toda PR aciona o pipeline de **CI** que roda linters `sqlfluff` (para padronização de SQL) e `ruff` (para Python), além do `dbt test` para validar a regressão de qualidade. Um PR Template guia a descrição do impacto das métricas no BI.
- **Continuous Deployment (CD)**: Após o merge na branch `main`, o pipeline de **CD** aciona a geração automatizada da documentação (via `dbt docs generate`) e efetua o deploy no GitHub Pages.
- **Testes de Regras de Negócio**: Testes singulares estão embutidos (ex: proxy de impossibilidade de frequências em turmas antes do início do ano letivo).
- Arquivos de dados brutos (`.parquet`, `.csv`) são rigorosamente bloqueados via `.gitignore`.

## Trade-offs
- **Ambiente de Data Warehouse:** Optei por rodar o desafio via DuckDB em vez do BigQuery para isolar a infraestrutura local, removendo o ônus de requerer conta GCP ativa do avaliador para execução. Em produção, migraria para o adapter do BigQuery (`dbt-bigquery`).

## Ambiente de Desenvolvimento (Codespaces)
O projeto contém uma configuração do **Devcontainer** (`.devcontainer/devcontainer.json`).
Você pode abrir o projeto no GitHub Codespaces e ele instanciará um contêiner Linux pré-configurado com:
- Python 3.10
- dbt-duckdb, sqlfluff e dependências.
- Extensões recomendadas do VSCode instaladas (dbt Power User, Ruff, SQLFluff).

## Execução Local (Alternativa)

⚠️ **Importante:** Antes de executar, certifique-se de que os arquivos brutos (`aluno.parquet`, `escola.parquet`, etc.) baixados do GCP foram colocados dentro da pasta `data/` na raiz do projeto.

```bash
pip install -r requirements.txt
dbt deps
dbt build
