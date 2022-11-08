

struct HumanPlayer{G} <: AbstractPlayer end

function (p::HumanPlayer{G})(state) where G<:AbstractGame
    A = actiontype(G)
    print("\nType your move: ", )
    m = readline()
    try
        m = A(eval(Meta.parse(m)))
    catch
        println("Parsing error. Try again.")
        m = p(state)
    end
    return m
end