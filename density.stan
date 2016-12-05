data{ # Declare what each data variable is
  int<lower=1> n_obs;
  int<lower=1> n_sites;
  int<lower=1> n_transects;
  int<lower=1> site[n_obs];
  int<lower=1> transect[n_obs];
  int<lower=0> burnt[n_sites];
  real cs_severity[n_sites];
  real cs_altitude[n_sites];
  real cs_twi[n_sites];
  real cs_adult_den[n_transects];
  int<lower=0> y[n_obs]; 
  int<lower=0> n_sims;
  real cs_sim_severity[n_sims];
  real cs_sim_altitude[n_sims];
  real cs_sim_twi[n_sims];
  real cs_sim_adult_den[n_sims];
}
parameters{ # Declare parameters the models must estimate
  
  real alpha_mu;
  real<lower=0> alpha_sigma;
  real raw_alpha[n_sites];
  real b_unburnt;
  real b_severity;
  real b_altitude;
  real b_twi;
  real b_transect_mu;
  real<lower=0> b_transect_sigma;
  real b_raw_transect[n_transects];
  real b_adult_density;
}
transformed parameters { # Declare and define derived variables used in model
  real count[n_obs];
  real alpha[n_sites];
  real a_transect[n_transects];
  real b_transect[n_transects];
  
  
  for (t in 1:n_transects) {
    b_transect[t] = b_raw_transect[t] * b_transect_sigma;
  }
  
  for (s in 1:n_sites) {
    alpha[s] = raw_alpha[s] * alpha_sigma + alpha_mu;
  }
  
  for (i in 1:n_obs) {
    count[i] = exp(alpha[site[i]] + 
                     b_unburnt * (1-burnt[site[i]]) + 
                     b_severity * (cs_severity[site[i]] * burnt[site[i]]) +
                     b_altitude * cs_altitude[site[i]] + 
                     b_twi * cs_twi[site[i]] + 
                     b_adult_density * cs_adult_den[transect[i]] +
                     b_transect[transect[i]]);
  }
}
model { # Define priors and likelihood
  
  # PRIORS
  raw_alpha ~ normal(0,1);
  alpha_mu ~ normal(0, 2.5);
  alpha_sigma ~ cauchy(0, 25);
  b_unburnt ~ normal(0,2.5);
  b_severity ~ normal(0,2.5);
  b_altitude ~ normal(0,2.5);
  b_twi ~ normal(0,2.5);
  b_raw_transect ~ normal(0,1);
  b_transect_sigma ~ cauchy(0,25);
  b_adult_density ~ normal(0, 2.5);
  
  
  # Likelihood
  y ~ poisson(count);
}
generated quantities { # Calculate log likelihood, residuals or make predictions
  
  # Parameters to calculate log likelihood
  
  # Predictions
  real pred_count_unburnt;
  real pred_count_burnt;
  real pred_count_severity[n_sims];
  real pred_count_altitude[n_sims];
  real pred_count_twi[n_sims];
  real pred_count_adult_density[n_sims];
  
  # Partial dependencies
  
  pred_count_unburnt = exp(alpha_mu + b_unburnt);
  pred_count_burnt = exp(alpha_mu);
  
  for(i in 1:n_sims) {
    pred_count_severity[i] = exp(alpha_mu + b_severity * cs_sim_severity[i]);
    pred_count_altitude[i] = exp(alpha_mu + b_altitude * cs_sim_altitude[i]);
    pred_count_twi[i] = exp(alpha_mu + b_twi * cs_sim_twi[i]);
    pred_count_adult_density[i] = exp(alpha_mu + b_adult_density * cs_sim_adult_den[i]);
  }
}
