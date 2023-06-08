
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
    portions=rand(Beta(2,5),2)
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

# now we need to get the gradient of the utility functions

function gradient(agt::agent)
    gradient=Float64[]
    for i in 1:length(agt.currEndow)
        push!(gradient,agt.preferenceVec[i]/agt.currEndow[i])
    end
    gradient=gradient./gradient[length(gradient)]
    return gradient
end

function subsidy(agt::agent)
    grad=gradient(agt)
    subsidy=dot(grad,agt.currEndow)-dot(grad,agt.initEndow)
    return subsidy
end

function tradePrice(agt::agent)
    priceVec=Float64[]
    for i in 1:length(agt.initEndow)
        push!(priceVec,abs(agt.currEndow[i]-agt.initEndow[i]))
    end
    finPrice=priceVec./priceVec[length(priceVec)]
    return finPrice
end

# now, we need a function to actually compute equilibrium 

function equilibrium()
    global agtList
    global commodCnt
    #First, build want matrix w 
    # m goods, n traders, m by n matrix
    wList=[]
    # the endowment matrix is also m by n
    eList=[]
    for agt in agtList
        push!(wList,agt.preferenceVec)
        push!(eList,agt.initEndow)
    end
    wMat=hcat(wList...)
    #println("Wants")
    #println(wMat)
    #println(size(wMat))
    #println(eList)
    eMat=hcat(eList...)
    #println(eMat)
    #println("Endowments")
    #println(size(eMat))

    # now sum up all endowments 
    totEndow=sum(eMat,dims=2)
    #println(totEndow)
    normEndow=eMat./totEndow
    tstNorm=sum(normEndow,dims=2)
    #println(tstNorm)
    # now, transpose 

    #eMat=transpose(normEndow)
    edgeworth=normEndow*transpose(wMat)
    #println(size(edgeworth))
    #println(edgeworth)
    eigenvals= eigvals(edgeworth)
    eigenvecs = eigvecs(edgeworth)
    # now find the non-negative 
    soln=eigenvecs[all.(>(0.0), eachrow(eigenvecs)),:]
    soln=soln./soln[commodCnt]
    # now get agent demands 
    demandOvr=[]
    for agt in agtList
        # calculate agent income
        income=dot(soln,agt.initEndow ./ tstNorm)
        # now get percentage
        portion=income.*agt.preferenceVec
        # now, how much can the agent get? 
        demandVec=[]
        for t in 1:length(portion)
            push!(demandVec,portion[t]/soln[t])
        end
        push!(demandOvr,demandVec)
    end

    demandMatrix=hcat(demandOvr...)

    return [tstNorm,soln,demandMatrix]      
end

# get total resources
function totalRes()
    global agtList
    global commodCnt
    #First, build want matrix w 
    # m goods, n traders, m by n matrix
    # the endowment matrix is also m by n
    eList=[]
    for agt in agtList
        push!(eList,agt.initEndow)
    end
    eMat=hcat(eList...)
    return sum(eMat,dims=2)
end

function perturb(agt::agent)
    global sigma 
    agt.initEndow=agt.initEndow .+ rand(Normal(0,sigma),4)
end

# we need an alternative way to calculate equilibrium 

function demand(agt,pVec)
    # using convex
    x=Variable(length(pVec))

    alpha=agt.preferenceVec
    income=dot(pVec,agt.initEndow)
    println(agt.preferenceVec)
    println(income)

    prob=minimize(-sum(alpha.*log(x)))
    prob.constraints += transpose(x)*pVec <= income 
    solve!(prob,COSMO.Optimizer)

    return evaluate(x)
end
