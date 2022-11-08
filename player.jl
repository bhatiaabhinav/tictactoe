abstract type AbstractPlayer end

(::AbstractPlayer)(state) = error("not implemented")


function playgame(G, players)
    s = G()
    while !isgameover(s)
        show(s)
        p = whoseturn(s)
        a = players[p](s)
        println("playing move ", a)
        play!(s, p, a)
    end
    show(s)
    println("\nFinal outcomes: ", utilities(s))
    return s
end
