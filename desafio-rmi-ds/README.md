# Desafio RMI - Analytics Engineering

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![DuckDB](https://img.shields.io/badge/DuckDB-FFF000?style=for-the-badge&logo=duckdb&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

## Visão Geral
Este projeto estrutura o pipeline analítico para dados educacionais do RMI, seguindo padrões de classe Enterprise. O projeto combina Analytics Engineering (via dbt) utilizando a arquitetura Medallion para transformar e testar dados antes que alcancem as camadas de consumo do BI.

## Arquitetura de Dados (dbt/Medallion) & Decisões de Modelagem
O projeto adota a arquitetura Medallion suportada pelas convenções oficiais do dbt Labs:

1. **Staging (`models/staging/stg_*`)**
   - **Lineage:** Consome diretamente os dados brutos (`sources`) do GCS via a extensão `httpfs` do DuckDB.
   - **Decisões:** Materializadas como `view`. Aqui fazemos o casting explícito de tipos, renomeamos colunas obscuras para o vernáculo de negócios (ex: `ano` para `ano_letivo`) e removemos/anulamos colunas inexistentes na fonte de dados provida.
   - **Testes:** Fortemente embasada em testes genéricos de não nulidade, chaves primárias e relacionamentos (`relationships` inter-tabelas).

2. **Intermediate (`models/intermediate/int_*`)**
   - **Lineage:** Cruza os modelos de staging, agindo como ponte lógica.
   - **Decisões:** Materializada como `view`. Foi criado o modelo `int_educacao__aluno_frequencia` para consolidar o grão `aluno + turma + escola`, unificando a leitura de frequência total e reduzindo joins repetitivos nos marts.
   - **Estratégia de Testes:** Focada em Surrogate Keys robustas (via `dbt_utils`) para garantir que os cruzamentos não criem duplicações espúrias.

3. **Marts (`models/marts/mart_*`)**
   - **Lineage:** Agrega as tabelas intermediárias no grão de análise final para o BI.
   - **Decisões:** Materializadas como `table` visando a performance de leitura. Desenvolvemos o `mart_educacao__absenteismo` que sumariza o absenteísmo crônico escolar por região e escola.
   - **Governança:** Protegido por um **Data Contract (`enforced: true`)**. Nenhuma alteração sobe para produção caso quebre a tipagem das colunas que alimentam os painéis finais.

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

## Trade-offs e Visão de Futuro
- **Ambiente de Data Warehouse:** Optei por rodar o desafio via DuckDB + Parquets online em vez de manter toda a infraestrutura sobre o BigQuery. Isso diminui fricção, não requer conta com billing ativo e demonstra proficiência no processamento descentralizado e in-memory. **Em um ambiente de produção real**, migraríamos a engine inteiramente para o dbt-bigquery, usufruindo da escalabilidade GCP.


## Ambiente de Desenvolvimento (Codespaces)
O projeto contém uma configuração do **Devcontainer** (`.devcontainer/devcontainer.json`).
Você pode abrir o projeto no GitHub Codespaces e ele instanciará um contêiner Linux pré-configurado com:
- Python 3.10
- dbt-duckdb, sqlfluff e dependências.
- Extensões recomendadas do VSCode instaladas (dbt Power User, Ruff, SQLFluff).

## Execução Rápida (Passo a Passo)

⚠️ **Importante:** O projeto está configurado para **ler os dados em tempo real** diretamente do bucket público no Google Cloud Storage durante o runtime (via extensão `httpfs` do DuckDB). Você não precisa baixar nada para a pasta `data/` manualmente.

Abaixo estão as instruções detalhadas para executar a pipeline em seu ambiente local:

1. **Pré-requisitos**
   Certifique-se de que você tem o Python 3.10+ instalado em sua máquina.

2. **Crie um ambiente virtual e o ative (opcional, mas recomendado)**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # No Windows use: venv\Scripts\activate
   ```

3. **Instale as bibliotecas necessárias**
   Na raiz do repositório `desafio-rmi-ds`, execute:
   ```bash
   pip install -r requirements.txt
   ```

4. **Baixe as dependências do dbt**
   Isso instalará os pacotes do dbt que usamos para validações e chaves primárias (`dbt_utils` e `dbt_expectations`).
   ```bash
   dbt deps
   ```

5. **Rode o Projeto (Extraia, Transforme e Teste)**
   O comando abaixo conectará ao GCS, processará os parquets via DuckDB, gerará os modelos (Staging, Intermediate e Marts) e rodará todos os testes de qualidade:
   ```bash
   dbt build
   ```
   > Se tudo ocorrer bem, você verá várias linhas em verde terminando em "Completed successfully".

## Evolução Arquitetural e Refinamentos (Orquestração Sênior)

Como parte das melhores práticas de Analytics Engineering e DevOps, o projeto evoluiu estruturalmente para garantir escalabilidade e precisão dos dados:

1. **Refatoração Wide-to-Long (Unpivot de Avaliações):**
   A tabela original de avaliações utilizava um modelo "wide" (`disciplina_1` a `disciplina_4`), o que prejudica sumarizações e análises granulares por disciplina. Implementamos a transformação via operação `unpivot` no `int_educacao__avaliacao_unpivot.sql`, padronizando o dataset para o formato colunar "long". Essa mudança facilita pipelines de Machine Learning futuros e a criação de novas features (ex: regressões por matéria).

2. **Estratégia de Testes Ampliada:**
   Além das validações genéricas, aplicamos **Testes Singulares** customizados em `tests/` para garantir regras de negócio essenciais:
   - *Limites de Frequência*: Bloqueia taxas de presença ilógicas (fora de 0-100%).
   - *Data de Matrícula*: Garante que a data de frequência não ocorra antes do ano letivo de fundação da turma.
   - *Data Leakage Check*: Inserimos um teste de detecção de anomalia configurado como alerta (`warn`) para flagrar se a quantidade de frequências exatas em `100.0` exceder o limiar orgânico, alertando os Cientistas de Dados sobre potencial ruído mecânico no preenchimento das escolas.

3. **Resolução de Débitos de Dados via Seeds:**
   As colunas essenciais `tipo` e `regiao` estavam documentadas mas ausentes na fonte. Introduzimos um domínio estático via **dbt seeds** (`seeds/escola_dominio.csv`), assegurando o enriquecimento da `stg_educacao__escola` de forma transparente e evitando a propagação de nulos para o DW.

4. **Automação CI/CD (GitHub Actions):**
   Estabelecemos o fluxo contínuo de build e testes. O workflow em `.github/workflows/dbt_build.yml` instala dependências (Python + dbt) e executa `dbt deps` e `dbt build` a cada `push` na branch `main`. Essa esteira atua como barreira de proteção de Qualidade (Quality Gate) antes de qualquer inserção produtiva.
