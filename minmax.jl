

mutable struct MiniMaxPlayer{G <: AbstractGame, P, A} <: AbstractPlayer
    valuefn::Dict{G, NTuple{P, Float64}}
    policy::Dict{G, Union{A, Nothing}}
    function MiniMaxPlayer{G}() where {G <: AbstractGame}
        P = playercount(G)
        A = actiontype(G)
        new{G, P, A}(Dict{Tuple{G}, NTuple{P, Float64}}(), Dict{G, Union{A, Nothing}}())
    end
end

function minimax_update!(mmp::MiniMaxPlayer{G, P}, state) where {G<:AbstractGame, P}
    if haskey(mmp.valuefn, state)
        return nothing
    end
    if isgameover(state)
        mmp.valuefn[state] = utilities(state)
        mmp.policy[state] = nothing
        return nothing
    end
    player = whoseturn(state)
    vs = -Inf64
    valuefn = nothing
    policy = nothing
    for m in legalmoves(state, player)
        s′ = play!(deepcopy(state), player, m)
        minimax_update!(mmp, s′)
        vs′ = mmp.valuefn[s′][player]
        if vs′ > vs
            vs = vs′
            valuefn = mmp.valuefn[s′]
            policy = m
        end
        if vs′ == 1
            break
        end
    end
    mmp.valuefn[state] = valuefn
    mmp.policy[state] = policy
    return nothing
end

function (mmp::MiniMaxPlayer)(state)
    println("values", mmp.valuefn[state])
    mmp.policy[state]
end
