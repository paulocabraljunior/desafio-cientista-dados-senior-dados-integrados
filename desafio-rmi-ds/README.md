# Desafio RMI - Analytics Engineering e MLOps

[![dbt CI](https://github.com/seu-usuario/desafio-rmi-ds/actions/workflows/ci.yml/badge.svg)](https://github.com/seu-usuario/desafio-rmi-ds/actions/workflows/ci.yml)
[![dbt CD & Docs](https://github.com/seu-usuario/desafio-rmi-ds/actions/workflows/cd.yml/badge.svg)](https://github.com/seu-usuario/desafio-rmi-ds/actions/workflows/cd.yml)

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

## Governança e Qualidade (CI/CD)
O repositório está blindado por políticas de governança:
- **Pull Requests (PRs)**: Toda PR aciona o pipeline de **CI** que roda linters `sqlfluff` (para padronização de SQL) e `ruff` (para Python), além do `dbt test` para validar a regressão de qualidade. Um PR Template guia a descrição do impacto das métricas no BI.
- **Continuous Deployment (CD)**: Após o merge na branch `main`, o pipeline de **CD** aciona a geração automatizada da documentação (via `dbt docs generate`) e efetua o deploy no GitHub Pages.
- **Testes de Regras de Negócio**: Testes singulares estão embutidos (ex: impossibilidade de frequências anteriores ao início das aulas).
- Arquivos de dados brutos (`.parquet`, `.csv`) são rigorosamente bloqueados via `.gitignore`.

## Ambiente de Desenvolvimento (Codespaces)
O projeto contém uma configuração do **Devcontainer** (`.devcontainer/devcontainer.json`).
Você pode abrir o projeto no GitHub Codespaces e ele instanciará um contêiner Linux pré-configurado com:
- Python 3.10
- dbt-duckdb, sqlfluff e dependências.
- Extensões recomendadas do VSCode instaladas (dbt Power User, Ruff, SQLFluff).

### Execução Local (Alternativa)
```bash
pip install -r requirements.txt
dbt deps
dbt build
```
