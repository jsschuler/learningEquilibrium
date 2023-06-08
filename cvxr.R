library(CVXR)

alpha <- c(0.18354042169899376, 0.23356912222655113, 0.49519335734490944, 0.08769709872954567)
endow <- c(3.8774899000796794, 5.194085257030688, 6.374932791377095, 7.066225385767078)

pVec <- c(3,2,50,1)

x <- Variable(4)

obj <- Maximize(sum(alpha * log(x)))
constr <- list(sum(pVec*x) <= sum(pVec*endow))
prob <- Problem(obj, constr)
result <- solve(prob)
result$value
result$getValue(x) -> eqEndow

sum(pVec * eqEndow)
