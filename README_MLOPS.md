# Sistema de Previsão de Preços (MLOps & XAI)

## Justificativa Arquitetural
Este projeto implementa uma estrutura modular Python (nível enterprise) com o objetivo de facilitar a produtização de modelos de Machine Learning (Regressão).

1. **Engenharia de Software & Schemas**: Utilização do `pydantic` para garantir o contrato de dados logo na entrada (`data_loader.py`), falhando rápido em caso de anomalias (Data Quality).
2. **Pipelines do Scikit-Learn**: Todo o pré-processamento (imputação, one-hot encoding, scaling e tratamento de outliers) foi envelopado via `Pipeline` e `ColumnTransformer`. Isso evita *data leakage* durante o Cross Validation e em ambiente de produção.
3. **MLOps**: Integração com `mlflow` e `optuna`. O `optuna` garante buscas no espaço de hiperparâmetros mais eficientes (Otimização Bayesiana), enquanto o MLFlow rastreia métricas e versiona o modelo treinado.
4. **Explicabilidade (XAI)**: Integração com SHAP Values para transparência do modelo, e análise de resíduos para diagnosticar quebras de premissas (ex: heterocedasticidade).

## Como Escalar via FastAPI
Para escalar essa solução como um serviço, a API pode ser implementada carregando o modelo (`mlflow.sklearn.load_model()`) em tempo de inicialização (startup event).
Um endpoint `/predict` receberia o payload (validado diretamente pelo Pydantic Schema `InputDataSchema`) e faria a inferência via `pipeline.predict()`.
A arquitetura em pacotes permite que a API simplesmente importe o schema e invoque a previsão.

## Executando Localmente (Docker)
```bash
docker build -t ml_price_predictor .
docker run ml_price_predictor
```
Isso rodará a suite de testes unitários garantindo a integridade dos transformers customizados.
