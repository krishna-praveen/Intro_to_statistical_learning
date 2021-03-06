# In this problem we will generate simulated data and use that to perform the best susbset selection.

## a)
# Use the rnorm() to generate predictor X of length n=100 and also noise of e of length 100
x = rnorm(n = 100)
eps = rnorm(n = 100)
length(x)
length(eps)

## b)
# Generate response vector Y of length n = 100 with the model below
y = 1 + 2*x + 3*x^2 + 4*x^3 + eps
plot(x,y)

## c)
# Use the regsubsets to perform the ebst subset selection with predictors from x^1 to x^10
# What is best model obtained according to Cp, BIC and adjsuted R^2

# Adding regsubsets library to this, which is inside the library called leaps
library(leaps)

# We have to create a dataframe from x^1 to x^10
xfull = poly(x = x,degree = 10,raw = T)

# making a dataframe of y and x
datahere = data.frame(y,xfull)

# Fitting the regsubsets model
reg_model = regsubsets(y~.,data = datahere,nvmax = 10)
reg_model
plot(reg_model)
?regsubsets

reg_summary = summary(reg_model)
reg_summary
reg_summary$rsq

# Creating a grid of 2x2
par(mfrow = c(2,2))

# Plotting for each of the type of indicators we consider to select model
plot(reg_summary$rsq)
plot(reg_summary$bic)
plot(reg_summary$cp)
plot(reg_summary$adjr2)

maxpointnumber_adjrsq = which.max(reg_summary$adjr2)
maxpointnumber_adjrsq
minpointnumber_cp = which.min(reg_summary$cp)
minpointnumber_cp
minpointnumber_bic = which.min(reg_summary$bic)
minpointnumber_bic
points(maxpointnumber_adjrsq, reg_summary$adjr2[maxpointnumber_adjrsq], col="red", cex=2, pch=20)

# According to bic and cp indexes we have these at the lowest for index equal to 3
# So lets get the coefficients of the model where we have 3 predictors,which is meant by 3 above.
coef(reg_model,3)
coef(reg_model,minpointnumber_cp)
coef(reg_model,maxpointnumber_adjrsq)

## d)
# Now using the backward and forward selection for selecting the model predictors
# For specifying the backward and forward selection we just hve to add another argument in regsubsets
?regsubsets

reg_model_forward = regsubsets(y~.,data = datahere,nvmax = 10,method = "forward")
reg_sumamry_forward = summary(reg_model_forward)

maxpointnumber_adjrsq = which.max(reg_sumamry_forward$adjr2)
maxpointnumber_adjrsq

minpointnumber_bic = which.min(reg_sumamry_forward$bic)
minpointnumber_bic

minpointnumber_cp = which.min(reg_sumamry_forward$cp)
minpointnumber_cp

coef(reg_model_forward,maxpointnumber_adjrsq)
coef(reg_model_forward,minpointnumber_bic)
coef(reg_model_forward,minpointnumber_cp)

# Now using the backward selection method to fit the model and doing the same process again.
reg_model_backward = regsubsets(y~.,data = datahere,nvmax = 10,method = "backward")
reg_summary_backward = summary(reg_model_backward)

maxpointnumber_adjrsq = which.max(reg_summary_backward$adjr2)
maxpointnumber_adjrsq

minpointnumber_bic = which.min(reg_summary_backward$bic)
minpointnumber_bic

minpointnumber_cp = which.min(reg_summary_backward$cp)
minpointnumber_cp

coef(reg_model_backward,maxpointnumber_adjrsq)
coef(reg_model_backward,minpointnumber_bic)
coef(reg_model_backward,minpointnumber_cp)

## As we can observe all the three method resulted in the same value and number of coefficietns that
##  we can select. So the way of seleciton of predictors have no infleunce in the selection of
##  predcitors and the numbe r of predictors

## e)
# Fitting the lasso model to the simualated model. using the same data.
# Using the cross validation now , not the validation model.
# Also select the best lambda based on the best value from the cross validation
library(glmnet)
typeof(xfull)
?model.matrix

lambda_seq = 10^seq(10,-2,length.out = 100)

## Using cv.glmnet to fit a 10 fold CV with this sequence of lambda values
#   We can either use the lambda sequence or it will be generated by default
lasso_model = cv.glmnet(x = xfull,y = y,alpha = 1)
lasso_model$lambda

lasso_model
plot(lasso_model)

best_lambda = lasso_model$lambda.min
best_lambda

# The predictions value of responses for this beest value of lambda is :
#   If we want to get predicitons of coefficients rather than the response, we have to include another
#     argument inside the predict model which is type = "coefficients" which will be an extra
#     argument passed on to the lasso_model.
lasso_pred = predict(object = lasso_model,newx = xfull,s = best_lambda)
lasso_pred

mean((y - lasso_pred)^2)

# Coefficients of the lasso model we have developed and these coefficients are  for the best model.
lasso_coeff = predict(object = lasso_model,newx = xfull,s = best_lambda,type = "coefficients")
lasso_coeff[,1]

# The coefficients obtained are very close to the actual values which are 1, 2,3 ,4
# Here we have obtained : .98,1.88,3.01,4.01 which are really close to the actual values


## f)
# Generating another response vector y2 which will be like this
y2 = 1+2*x^7

plot(x,y2)

# Creating a full vector of x upto having 10 polynomials
xfull = poly(x = x,degree = 10,raw = T)

# Creating dataframe with response and the data
datahere = data.frame(y2,xfull)

###
# Fitting by subset selection
reg_model = regsubsets(y2~.,data = datahere)

summary(reg_model)
plot(reg_model)

reg_summary = summary(reg_model)

plot(reg_summary$rsq)

plot(reg_summary$bic)

plot(reg_summary$cp)

minpointnumber_bic = which.min(reg_summary$bic)
minpointnumber_bic

minpointnumber_cp = which.min(reg_summary$cp)
minpointnumber_cp

maxpointnumber_adjrsq = which.max(reg_summary$rsq)
maxpointnumber_adjrsq

coef(reg_model,minpointnumber_bic)
coef(reg_model,minpointnumber_cp)
coef(reg_model,maxpointnumber_adjrsq)

# All the coefficients predicted here are very close to the actual model
#   Particularicly fo rthis adjrsq, we have best coefficients which are actually exact.
#   Rest of BIC and CP gave good results too




##
# Predicting by using lasso method with 10 fold cross validation
lasso_model = cv.glmnet(x = xfull,y = y2,alpha = 1)
lasso_model

summary(lasso_model)
plot(lasso_model)

# lasso model by default gives us the best lambda where we get the lowest MSEP
#   We can use this by calling it using $ and then calling lambda.min
best_lambda = lasso_model$lambda.min
best_lambda

# As in lasso we have to predict coefficients by taking the best lambda value and then
#   asking it to predic the coefficients by giving argument "type = "coefficients""
# We can also ask it to predict just the responses if we dont give that argument and give the
#   x data.
lasso_coeff = predict(lasso_model,s = best_lambda,type = "coefficients")
lasso_coeff[,1]

# lasso coefficients has predicted an extra for 5th power of x which is not present in our actual
#   function.
# However the predictions of the coefficients are very close.

