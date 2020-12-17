# Gamma-hurdle-model-using-INLA
This repository 
## Gamma-hurdle model
There are many situations in which you may have a response variable that is positive and continuous but has zero inflation. For example, you are measuring the height of a tree species but there are not individuals at some sites. You may want to model the height using a gamma distribution, however, this distributions doesn’t allow for zero values. In such a case, you can model the zeros separately from the non-zeros using a binomial-gamma hurdle model.
## INLA
Integrated Nested Laplace Approximation (INLA) is a Bayesian modeling approach that easily accommodates complex data structures and it is very efficient in terms of computing time. See INLA website for more information. 
## Model
Let's *y* a continuous random variable that follows the pdf:

![Local functions](https://github.com/jmrmcode/Gamma-hurdle-model-using-INLA/blob/main/math-20201216.png?raw=true)

where &pi; and &gamma; are a binomial and gamma distribution, respectively, and **x** and **&theta;** are covariate and parameter vectors.

We want to fit a hurdle varying slopes mixed model to *y*<sup>B</sup> (*y* = 1 when *y* > 0 and 0 otherwise) and *y*<sup>G</sup> (*y* > 0) (*i* = 1, ..., n and *j* = 1, ..., J) that includes one continuous predictor whose effect on *y* varies across *J* levels.

![Local functions](https://github.com/jmrmcode/Gamma-hurdle-model-using-INLA/blob/main/modelEquations.png?raw=true)

where &beta;<sub>0</sub> is the intercept for the binomial (B) and gamma (G) components, respectively, &beta;<sub>1</sub> is the effect of *x* on *y*, *b*<sub>j</sub> is the deviation from &beta;<sub>j</sub> in level *j*, and *x* is the continuous predictor.

Let's put everything together in matrix notation to better understand how we have to provide the data to INLA:

![Local functions](https://github.com/jmrmcode/Gamma-hurdle-model-using-INLA/blob/main/matrixnotation.png?raw=true)

where *n*<sub>B</sub> is the # of observations = 0 and *n*<sub>G</sub> is the # of observations > 0. *Z* is a block matrix that contains matrices *Z*<sup>B</sup> and *Z*<sup>G</sup> filled with the *x* values in level *j* and 0 otherwise.

This repository includes the R code () to simulate the data and implement the hurdle model shown above. Also, it computes and plots the posterior distributions of (&beta;<sub>1</sub> + b<sub>j</sub>) by the function inla.make.lincombs() of INLA.
