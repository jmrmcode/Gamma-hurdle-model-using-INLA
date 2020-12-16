# Gamma-hurdle-model-using-INLA
## Why
There are many situations in which you may have a response variable that is positive and continuous but has zero inflation. For example, you are measuring the height of a tree species but there are not individuals at some sites. You may want to model the height using a gamma distribution, however, this distributions doesn’t allow for zero values. In such a case, you can model the zeros separately from the non-zeros using a binomial-gamma hurdle model.
## INLA
Integrated Nested Laplace Approximation (INLA) is a Bayesian modeling approach that easily acomadate complex model structures. 
