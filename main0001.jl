######################################################################################################################
#                       Learning to GE Code                                                                          #
#                       June 2023                                                                                    #
#                       John S. Schuler                                                                              #
#                                                                                                                    #
#                                                                                                                    #
######################################################################################################################

# The general idea is that agents initially trade to the contract curve with no thought of finding equilibrium 

# once agents have a lot of data, they take calculate two price vectors. 
# one is the implicit price vector at the contract curve 
# the second is the implicit price vector from the endowment to the final allocation 
using LinearAlgebra
using Distributions
using Random
using Convex 
using SCS
using COSMO
Random.seed!(6893)
agtCnt=30 
commodCnt=4

endowGenerator=Gamma(7.5,1)

include("structs.jl")

agtList::Array{agent}=agent[]

include("functions.jl")

# now generate agents 
for i in 1:agtCnt
    agtGen()
end

# now as a very crude first step, we run the simulation until no agent has traded for 1000 rounds 
function naiveProc()
    noTradeCnt=0
    while true 
        # select two agents at random 
        agtPair=sample(agtList,2,replace=false)

        trade=tradeGuess(agtPair[1],agtPair[2])
        if !trade
            global noTradeCnt
            noTradeCnt=noTradeCnt+1
        else
            global noTradeCnt
            noTradeCnt=0
            println("Trade")
        end
        println(noTradeCnt)
        if noTradeCnt==1000000
            break
        end
    end
end
#for agt in agtList
#    println("Endowments")
#    println(agt.initEndow)
#    println(agt.currEndow)
#    println("Utilities")
#    println(utility(agt,agt.initEndow))
#    println(utility(agt,agt.currEndow))
#    println(gradient(agt))
#    println("Subsidy")
#    println(subsidy(agt))
#    println("Trade Price")
#    println(tradePrice(agt))
#end

# first solve for the equilibrium
#sigma=1
#eq1=equilibrium()[3]
#println(sum(eq1,dims=2))
#println(totalRes())
#println(agtList[1].initEndow)
# now, perturb the agt endowments 
#for agt in agtList
#    perturb(agt)
#end
#eq2=equilibrium()[1]
#println(eq2)
##println(agtList[1].initEndow)
#for agt in agtList
#    perturb(agt)
#end
#eq3=equilibrium()[1]
#println(eq3)
#println(agtList[1].initEndow)

agt1=agtList[1]
println(agt1.initEndow)
qD=demand(agt1,[3,2,50,1])
println(qD)
#println(dot([3,2,50,1],agt1.initEndow))
#println(dot([3,2,50,1],qD))




