
function endowmentGen()
    global commodCnt
    return rand(endowGenerator,commodCnt)
end

function preferenceGen()
    global commodCnt
    fVec=sort!(rand(Uniform(),commodCnt-1))
    fVec=vcat([0.0],fVec,1.0)
    alphaVec=[]
    for i in 2:length(fVec)
        push!(alphaVec,fVec[i]-fVec[i-1])
    end
    return alphaVec
end

function agtGen()
    global agtList
    endow=endowmentGen()
    push!(agtList,agent(endow,endow,preferenceGen()))
end

function utility(agt::agent,x::Array{Float64})
    global commodCnt
    retVal=1.0
    for i in 1:commodCnt
        retVal=retVal*x[i]^agt.preferenceVec[i]
    end
    return retVal
end

function utility(agt::agent)
    global commodCnt
    retVal=1.0
    for i in 1:commodCnt
        retVal=retVal*agt.currEndow[i]^agt.preferenceVec[i]
    end
    return retVal
end


# now we need some trade functions 
function tradeGuess(agt1,agt2)
    # select two goods 
    goods=sample(1:commodCnt,2,replace=false)
    # now select a certain portion of each to trade 
    portions=rand(Uniform(),2)
    global commodCnt
    deltaVec=zeros(commodCnt)
    deltaVec[goods[1]]=portions[1]*agt1.currEndow[goods[1]]
    deltaVec[goods[2]]=-portions[2]*agt2.currEndow[goods[2]]
    # now check if agents prefer this
    better1=utility(agt1,agt1.currEndow-deltaVec) > utility(agt1)
    better2=utility(agt2,agt2.currEndow+deltaVec) > utility(agt2)

    # now, if both are better off, make the trade 
    if better1 & better2
        agt1.currEndow=agt1.currEndow-deltaVec
        agt2.currEndow=agt2.currEndow+deltaVec
    end
    return better1 & better2
end

