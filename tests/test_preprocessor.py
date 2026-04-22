import pandas as pd
import numpy as np
from src.preprocessor import OutlierHandler, get_preprocessor

def test_outlier_handler():
    df = pd.DataFrame({
        'feature_1': [1, 2, 3, 4, 100]
    })
    handler = OutlierHandler(factor=1.5)
    handler.fit(df)
    transformed = handler.transform(df)

    assert transformed['feature_1'].max() < 100
    assert transformed.shape == df.shape

def test_pipeline_integrity():
    df = pd.DataFrame({
        'num_1': [1.0, 2.0, np.nan, 4.0],
        'cat_1': ['A', 'B', 'A', np.nan]
    })
    y = np.array([10, 20, 15, 30])

    preprocessor = get_preprocessor(['num_1'], ['cat_1'])
    # fit_transform handles the selection part which needs y
    X_trans = preprocessor.fit_transform(df, y)

    assert X_trans is not None
    assert X_trans.shape[0] == 4
