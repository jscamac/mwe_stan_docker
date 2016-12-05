data{ # Declare what each data variable is
  int<lower=1> n_obs;
  int<lower=1> n_plots;
  int<lower=1> plot[n_obs];
  int<lower=0> y[n_obs]; 
  int<lower=0> otc[n_obs];
  int<lower=0> time[n_obs];
}
parameters{ # Declare parameters the models must estimate
  real alpha;
  real b_otc;
  real b_time;
  real raw_plot[n_plots];
  real<lower=0> plot_sigma;
  real<lower=0> phi;
}
transformed parameters { # Declare and define derived variables used in model
  real count[n_obs];
  real plot_ranef[n_plots];
  
  for (p in 1:n_plots) {
    plot_ranef[p] = raw_plot[p] * plot_sigma;
  }
  
  for (i in 1:n_obs) {
    count[i] = exp(alpha + b_time * time[i] + b_otc * otc[i] + plot_ranef[plot[i]]);
  }
}
model { # Define priors and likelihood
  
  # PRIORS
  alpha ~ normal(0, 2.5);
  plot_sigma ~ cauchy(0, 25);
  raw_plot ~ normal(0,1);
  b_otc ~ normal(0, 2.5);
  b_time ~ normal(0, 2.5);
  phi ~ cauchy(0, 25);
  
  
  # Likelihood
  y ~ neg_binomial_2(count, phi);
}

generated quantities {
  real pred_count_ctl_t1;
  real pred_count_ctl_t2;
  real pred_count_otc_t1;
  real pred_count_otc_t2;
  
  pred_count_ctl_t1 = exp(alpha);
  pred_count_ctl_t2 = exp(alpha + b_time);
  pred_count_otc_t1 = exp(alpha + b_otc);
  pred_count_otc_t2 = exp(alpha + b_time + b_otc);
}
