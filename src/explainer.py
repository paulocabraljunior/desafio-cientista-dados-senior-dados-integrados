import shap
import matplotlib.pyplot as plt
import numpy as np

class ModelExplainer:
    def __init__(self, model_pipeline, X_train):
        self.model = model_pipeline.named_steps['model']
        self.preprocessor = model_pipeline.named_steps['preprocessor']
        self.X_train_transformed = self.preprocessor.transform(X_train)
        self.explainer = shap.TreeExplainer(self.model)

    def generate_shap_summary(self):
        shap_values = self.explainer.shap_values(self.X_train_transformed)
        shap.summary_plot(shap_values, self.X_train_transformed, show=False)
        plt.savefig("shap_summary.png")
        plt.close()

    def generate_residuals_plot(self, y_true, y_pred):
        residuals = y_true - y_pred
        plt.scatter(y_pred, residuals, alpha=0.5)
        plt.axhline(y=0, color='r', linestyle='--')
        plt.xlabel("Predicted Values")
        plt.ylabel("Residuals")
        plt.title("Residual Analysis (Heteroscedasticity Check)")
        plt.savefig("residuals_plot.png")
        plt.close()
