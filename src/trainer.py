import mlflow
import mlflow.sklearn
import optuna
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import RepeatedKFold, cross_val_score
import numpy as np

def objective(trial, X, y, preprocessor):
    n_estimators = trial.suggest_int('n_estimators', 50, 300)
    max_depth = trial.suggest_int('max_depth', 3, 15)
    min_samples_split = trial.suggest_int('min_samples_split', 2, 10)

    model = RandomForestRegressor(
        n_estimators=n_estimators,
        max_depth=max_depth,
        min_samples_split=min_samples_split,
        random_state=42
    )

    pipeline = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('model', model)
    ])

    cv = RepeatedKFold(n_splits=5, n_repeats=3, random_state=42)
    scores = cross_val_score(pipeline, X, y, scoring='neg_mean_absolute_error', cv=cv, n_jobs=-1)

    return scores.mean()

def train_model(X, y, preprocessor):
    mlflow.set_experiment("Previsao_Precos_Regressao")
    with mlflow.start_run():
        study = optuna.create_study(direction='maximize')
        study.optimize(lambda trial: objective(trial, X, y, preprocessor), n_trials=10)

        best_params = study.best_params
        mlflow.log_params(best_params)
        mlflow.log_metric("best_cv_neg_mae", study.best_value)

        best_model = RandomForestRegressor(**best_params, random_state=42)
        pipeline = Pipeline(steps=[
            ('preprocessor', preprocessor),
            ('model', best_model)
        ])

        pipeline.fit(X, y)
        mlflow.sklearn.log_model(pipeline, "model")

        return pipeline
