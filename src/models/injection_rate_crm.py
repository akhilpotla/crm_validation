import matplotlib.pyplot as plt
import numpy as np

from scipy.optimize import fmin_slsqp
from sklearn.utils.validation import check_is_fitted

from src.models.crm import CRM


class InjectionRateCRM(CRM):


    def predict(self, X):
        # TODO: This is not done, this needs to optimize the injection rate
        check_is_fitted(self)
        X = X.T
        self.X_predict_ = X
        params = self._fit_injection_rate(X)
        return (self.q2(X, self.tau_, *self.gains_), params)


    def _objective_function(self, params):
        injection_rates = params
        n_gains = len(self.X_predict_) - 1
        params = np.reshape(params, (n_gains, -1)).tolist()
        X = params
        X.insert(0, self.X_predict_[0].tolist())
        X = np.array(X)
        return -sum(self.q2(X, self.tau_, *self.gains_))


    def _fit_injection_rate(self, X):
        # The CRM function is part of the _sum_residuals function
        n_gains = len(X) - 1
        time_steps = len(X[0])
        lower_bounds = np.ones(n_gains * time_steps) * np.min(X[1:]) * 0.8
        upper_bounds = np.ones(n_gains * time_steps) * np.max(X[1:]) * 1.2
        bounds = np.array([lower_bounds, upper_bounds]).T.tolist()
        p0 = np.ones(n_gains * time_steps) * np.average(X[1:])
        params = fmin_slsqp(
            self._objective_function, p0, f_eqcons=self._constraints,
            bounds=bounds, iter=1000, iprint=0
        )
        return params
