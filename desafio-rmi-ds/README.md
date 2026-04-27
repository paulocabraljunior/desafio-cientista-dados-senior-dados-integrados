# Desafio Técnico - Cientista de Dados Sênior (Registro Municipal Integrado)

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![DuckDB](https://img.shields.io/badge/DuckDB-FFF000?style=for-the-badge&logo=duckdb&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Scikit-Learn](https://img.shields.io/badge/Scikit--Learn-F7931E?style=for-the-badge&logo=scikit-learn&logoColor=white)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

## Sumário
- [1. Visão Geral e Arquitetura](#1-visão-geral-e-arquitetura)
- [2. Guia de Execução (Como Rodar)](#2-guia-de-execução-como-rodar)
- [3. Decisões Arquiteturais e Engenharia de Analytics (O Core do Desafio)](#3-decisões-arquiteturais-e-engenharia-de-analytics-o-core-do-desafio)
- [4. Governança e Qualidade de Dados](#4-governança-e-qualidade-de-dados)
- [5. Modelagem Preditiva e Diagnóstico de Dados Sintéticos (O Diferencial Sênior)](#5-modelagem-preditiva-e-diagnóstico-de-dados-sintéticos-o-diferencial-sênior)

---

## 1. Visão Geral e Arquitetura

Este projeto materializa a resolução do desafio para Cientista de Dados Sênior focado nos dados educacionais do RMI. A arquitetura proposta consolida um pipeline analítico de ponta a ponta, projetado para operar com alta eficiência, pragmatismo e rigor técnico. 

O processamento de dados é orquestrado através do **dbt (Data Build Tool)** em conjunto com o **DuckDB**. A escolha do DuckDB permite um processamento analítico local, *in-memory* e extremamente veloz diretamente sobre arquivos `.parquet`, minimizando a fricção de infraestrutura enquanto simula o comportamento de um *Data Warehouse* em nuvem.

Estruturamos a transformação de dados sob o paradigma da **Arquitetura Medallion**:
- **Staging (Bronze/Silver):** Limpeza primária, tipagem rigorosa e adequação dos dados crus.
- **Intermediate (Silver):** Cruzamentos cruciais e modelagem de negócios complexa.
- **Marts (Gold):** Tabelas finais e consolidadas, modeladas e otimizadas para consumo de BI e de modelos de *Machine Learning*.

---

## 2. Guia de Execução (Como Rodar)

O repositório foi construído visando reprodutibilidade imediata. Siga os passos abaixo para executar a extração, transformação e a modelagem preditiva em seu ambiente local.

**Passo a passo:**

1. **Ativação do ambiente virtual:**
   ```bash
   source .venv/bin/activate
   ```
   *(No Windows, utilize `.venv\Scripts\activate`)*

2. **Instalação das dependências:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Execução do pipeline de dados (dbt):**
   Baixe os pacotes necessários do dbt e execute o processo de *build* (que engloba a criação das tabelas e a execução dos testes). 
   *Nota: O parâmetro `--profiles-dir .` garante que o dbt utilize o arquivo `profiles.yml` local do repositório, dispensando configurações prévias no seu ambiente.*
   ```bash
   dbt deps --profiles-dir .
   dbt build --profiles-dir .
   ```

4. **Execução do modelo preditivo:**
   Com os dados da camada *marts* gerados, execute o script do modelo preditivo:
   ```bash
   python src/models/predict_dropout.py
   ```

---

## 3. Decisões Arquiteturais e Engenharia de Analytics (O Core do Desafio)

Para entregar um pipeline resiliente que reflita cenários do mundo real, abordamos ativamente desafios e inconsistências na fonte de dados:

* **Resolução de Débitos Técnicos via Seeds:**
  Os arquivos `.parquet` originais apresentavam um débito técnico severo: a ausência completa das colunas descritivas `tipo` e `regiao` na entidade de escolas. Para contornar essa falha de integridade na origem, sem poluir a lógica de transformação, injetamos um arquivo de domínio estático (`escola_dominio.csv`) utilizando **dbt seeds**. A união desse domínio garante o enriquecimento correto durante a camada de *staging*.

* **Modelagem Long-Format via UNPIVOT:**
  As tabelas de avaliação foram entregues em formato *wide* (ex: `disciplina_1` até `disciplina_4` como colunas). Essa estrutura antipadrão impossibilita agregações analíticas granulares. Aplicamos uma operação robusta de `UNPIVOT` na camada *intermediate* para converter as avaliações em um formato *long* colunar. Essa decisão arquitetural viabilizou o correto cruzamento dimensional e facilitou o consumo ágil pela camada de *features* de Machine Learning.

---

## 4. Governança e Qualidade de Dados

A confiabilidade dos dados é assegurada através de mecanismos estritos de testes e integração contínua:

* **Estratégia de Testes Abrangente:**
  Aplicamos *testes genéricos* em toda a camada de *staging* para garantir a unicidade (`unique`) e não nulidade (`not_null`) das chaves primárias. Fomos além aplicando **Singular Tests** (testes de regras de negócio customizados). Um destaque é a validação cronológica lógica: construímos um teste para assegurar que não haja registros de frequência anteriores à data de fundação da turma ou matrícula do aluno, bloqueando anomalias lógicas na raiz.

* **Integração e Entrega Contínuas (CI/CD):**
  A base de código está submetida a esteiras de integração contínua via **GitHub Actions**. O workflow configurado em `.github/workflows/dbt_build.yml` valida os *commits*, garantindo que toda modificação estrutural passe pelo linter de SQL, compilação do projeto e sucesso nos testes de dados (`dbt build`), protegendo a branch `main` contra regressões.

---

## 5. Modelagem Preditiva e Diagnóstico de Dados Sintéticos (O Diferencial Sênior)

O *pipeline* de Machine Learning foi construído com **Scikit-Learn** no script `predict_dropout.py`, englobando processamento estruturado de *features*, categorização e treinamento.

**⚠️ DOCUMENTAÇÃO CRÍTICA (Diagnóstico do Dataset)**

Durante a fase de validação, o modelo de predição de evasão atingiu uma métrica perfeita de **AUC-ROC 1.0**. Em um contexto prático, isso sinaliza uma anomalia severa.

Nossa auditoria profunda diagnosticou os seguintes fatores inerentes a este conjunto de dados sintéticos:
1. **Data Leakage (Vazamento de Alvo):** A variável que indica a condição de evasão é um derivado direto da própria regra de negócio calculada para a variável de absenteísmo (frequência). Fornecer as variáveis causadoras diretamente ao algoritmo configurou um forte vazamento de informação do futuro, tornando a tarefa trivial.
2. **Severo Desbalanceamento de Classes:** O conjunto de treinamento reduziu-se a 200 amostras efetivas, com uma distribuição de **183 instâncias da classe negativa contra apenas 17 da classe positiva** (Evasão). As propriedades puramente aleatórias (randômicas) injetadas no *dataset* durante a sua geração mascaram padrões do mundo real.

**Conclusão e Próximos Passos:** 
A arquitetura de engenharia de *features* e treinamento já está perfeitamente assentada. Em um ambiente produtivo real — e com *datasets* autênticos não sintéticos —, este pipeline encontra-se preparado para:
- Remover estrategicamente as *features* que causam o vazamento (*leakage*).
- Aplicar técnicas robustas de balanceamento de classes como o **SMOTE** (Synthetic Minority Over-sampling Technique) para permitir que o modelo capture generalizações úteis do negócio.
