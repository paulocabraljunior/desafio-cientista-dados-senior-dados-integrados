import pandas as pd
from pydantic import BaseModel, ValidationError
from typing import List

class InputDataSchema(BaseModel):
    feature_1: float
    feature_2: int
    category_1: str
    target: float

def validate_data(df: pd.DataFrame) -> pd.DataFrame:
    records = df.to_dict(orient="records")
    validated = []
    for r in records:
        try:
            InputDataSchema(**r)
            validated.append(r)
        except ValidationError as e:
            print(f"Data validation error: {e}")
    return pd.DataFrame(validated)

def load_data(filepath: str) -> pd.DataFrame:
    # Simulação do carregamento de dados
    df = pd.read_csv(filepath)
    return validate_data(df)
