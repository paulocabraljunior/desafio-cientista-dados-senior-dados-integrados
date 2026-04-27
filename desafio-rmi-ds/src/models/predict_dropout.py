import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, roc_auc_score
from typing import Tuple

def load_and_prepare_data() -> pd.DataFrame:
    """
    Carrega os dados consolidados do mart e prepara features.
    Na vida real, esta função faria query no DuckDB/BigQuery.
    """
    # Dados mockados simulando o que viria dos marts para fins do desafio
    np.random.seed(42)
    n_samples = 1000
    
    data = {
        'id_aluno': range(n_samples),
        'taxa_frequencia': np.random.uniform(40, 100, n_samples),
        'qtd_avaliacoes_bim_1': np.random.randint(0, 5, n_samples),
        'qtd_avaliacoes_bim_4': np.random.randint(0, 5, n_samples),
    }
    df = pd.DataFrame(data)
    
    # Feature Engineering: Queda de avaliações entre bimestres
    df['queda_avaliacoes'] = df['qtd_avaliacoes_bim_1'] - df['qtd_avaliacoes_bim_4']
    
    # Target: Evasão escolar (dropout). 
    # Assumimos que o aluno evadiu se a taxa de frequência < 75% e a queda de avaliações > 2
    df['target_evasao'] = np.where((df['taxa_frequencia'] < 75) & (df['queda_avaliacoes'] > 2), 1, 0)
    
    # Injetando nulos para simular vida real
    df.loc[df.sample(frac=0.1).index, 'taxa_frequencia'] = np.nan
    
    return df

def train_dropout_model(df: pd.DataFrame) -> Tuple[Pipeline, dict]:
    """
    Treina um modelo para predizer o risco de evasão escolar.
    """
    features = ['taxa_frequencia', 'queda_avaliacoes', 'qtd_avaliacoes_bim_1']
    X = df[features]
    y = df['target_evasao']
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
    
    pipeline = Pipeline([
        ('imputer', SimpleImputer(strategy='median')), # Tratamento de nulos
        ('scaler', StandardScaler()),
        ('classifier', RandomForestClassifier(n_estimators=100, random_state=42, class_weight='balanced'))
    ])
    
    pipeline.fit(X_train, y_train)
    y_pred = pipeline.predict(X_test)
    y_prob = pipeline.predict_proba(X_test)[:, 1]
    
    metrics = {
        'classification_report': classification_report(y_test, y_pred),
        'roc_auc': roc_auc_score(y_test, y_prob)
    }
    
    return pipeline, metrics

if __name__ == "__main__":
    print("Iniciando pipeline de predição de evasão escolar (Dropout)...")
    df_dataset = load_and_prepare_data()
    print(f"Dataset carregado com {len(df_dataset)} registros.")
    
    model, evaluation_metrics = train_dropout_model(df_dataset)
    
    print("\nResultados da Validação do Modelo:")
    print("-" * 40)
    print("AUC-ROC:", round(evaluation_metrics['roc_auc'], 4))
    print("\nClassification Report:")
    print(evaluation_metrics['classification_report'])
