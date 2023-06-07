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

using Distributions

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