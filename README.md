This repository is an attempt at diagnosing what is causing stan to run slower on a docker container.
Here I have set up four example models.

###Example 1: 8schools
8schools is a simple example taken directly from the stan repository. In total the model estimates 10 parameters.

###Example 2: recruits 
recruits is a simple count model that also extracts for categorical generated quantity parameters. In total the model estimates 5 parameters + 32 plot random effects.

###Example 3: shrub density
shrub density is another count model but with many more parameters & random effects. In total this model has 209 parameters (200 of which are random effect parameters). This model also contains range of generated quantities

###Example 4: shrub density minus generated quantities.
is the same as example 3 except with no generated quantities.

##Running Models in Docker
First, if you haven't already done so, install [docker](https://www.docker.com).

Next open a terminal and run the following:

`sudo docker pull jscamac/mwe_stan_docker`
The above will download the prebuild image of a virtual machine that contains linux, R and `rstan`.

Next run the docker image by running:
`docker run -it jscamac/mwe_stan_docker`
This should run a docker container using th image jscamac/mwe_stan_docker`. It should automatically open an `R` session:

From here the models can be run sequentially by running:

# Example 1 8schools
```
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

load('schools_dat.rda')
system.time(fit <-stan(file = '8schools.stan', data = schools_dat, 
                       iter = 2000, pars = c("mu","tau","eta"), chains = 4, seed=12345))

```

# Example 2
```
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

load('recruit_data.rda')
system.time(fit <-stan(file = 'recruit.stan', data = recruit_data, 
                       iter = 2000, pars =c('alpha','plot_sigma',
                                            'b_otc','b_time','phi',
                                            'pred_count_ctl_t1','pred_count_ctl_t2',
                                            'pred_count_otc_t1', 'pred_count_otc_t2'), chains = 4, seed=12345))
```

# Example 3
```
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

load('density_data.rda')
system.time(fit <-stan(file = 'density.stan', data = density_data, 
                       iter = 2000, pars =c("alpha_mu", "alpha_sigma","b_transect_sigma",
                                            "b_unburnt","b_severity","b_altitude","b_twi", "b_adult_density",
                                            "pred_count_unburnt","pred_count_burnt","pred_count_severity","pred_count_altitude",
                                            "pred_count_twi","pred_count_adult_density"), chains = 4, seed=12345))
```

# Example 4

```
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

load('density_data.rda')
system.time(fit <-stan(file = 'density_no_genquants.stan', data = density_data, 
                       iter = 2000, pars =c("alpha_mu", "alpha_sigma","b_transect_sigma",
                                            "b_unburnt","b_severity","b_altitude","b_twi", "b_adult_density"), chains = 4, seed=12345))
```

These models can also be run locally on your machine by doing the following:

1) Open a terminal and move to a directory you want the repository to be stored then run:
`git clone git@github.com:jscamac/mwe_stan_docker.git`

2) Open an R session within that repository and run the above code (assuming 'rstan is installed').
