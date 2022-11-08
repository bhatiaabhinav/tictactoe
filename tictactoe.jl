
using StaticArrays

@enum TicTacToeCell blank=0 cross=1 knot=2
Base.zero(::Type{TicTacToeCell}) = blank

mutable struct TicTacToeBoard{N} <: AbstractGame
    const board::MMatrix{N, N, TicTacToeCell}
    const eachrowcounts::MVector{N, MVector{2, Int}}
    const eachcolcounts::MVector{N, MVector{2, Int}}
    const eachdiagcounts::MVector{2, MVector{2, Int}}
    const won::MVector{2, Bool}
    count::Int
end

function TicTacToeBoard{N}() where N
    TicTacToeBoard{N}(
          @MMatrix zeros(TicTacToeCell, N, N)
        , @MVector zeros(MVector{2, Int}, N)
        , @MVector zeros(MVector{2, Int}, N)
        , @MVector zeros(MVector{2, Int}, 2)
        , @MVector [false, false]
        , 0
        )
end

Base.hash(b::TicTacToeBoard) = hash(b.board)
Base.isequal(b1::TicTacToeBoard, b2::TicTacToeBoard) = b1.board == b2.board

function play!(b::TicTacToeBoard{N}, player::Int, position::Tuple{Int, Int})::TicTacToeBoard{N} where N
    r, c = position
    @assert 1 <= r <= N && 1 <= c <= N
    @assert b.board[r, c] == blank
    @assert player == 1 || player == 2

    b.board[r, c] = TicTacToeCell(player)
    b.count += 1
    b.eachrowcounts[r][player] += 1
    b.eachcolcounts[c][player] += 1
    if r == c
        b.eachdiagcounts[1][player] += 1
    end
    if r + c == N + 1
        b.eachdiagcounts[2][player] += 1
    end
    b.won[player] = b.eachrowcounts[r][player] == N || b.eachcolcounts[c][player] == N || b.eachdiagcounts[1][player] == N || b.eachdiagcounts[2][player] == N
    return b
end

playercount(::Type{TicTacToeBoard{N}}) where N = 2
actiontype(::Type{TicTacToeBoard{N}}) where N = Tuple{Int, Int}

whoseturn(b::TicTacToeBoard)::Int = b.count % 2 == 0 ? Int(cross) : Int(knot)
function isgameover(b::TicTacToeBoard{N})::Bool where N
    sum(b.won) > 0 || b.count >= N^2
end
function utilities(b::TicTacToeBoard)::Tuple{Float64, Float64}
    if (b.won[1] == b.won[2])
        return (0,0)
    else 
        return b.won[1] ? (1, -1) : (-1, 1)
    end
end
struct TicTacToeLegalMoves{N}
    b::TicTacToeBoard{N}
end
Base.eltype(::Type{TicTacToeLegalMoves}) = Tuple{Int, Int}
Base.length(b::TicTacToeLegalMoves{N}) where N = N^2 - b.b.count
function Base.iterate(b::TicTacToeLegalMoves{N}, state=1) where N
    while state <= N^2
        # println("checking state ", state)
        if b.b.board[state] == blank
            r, c = (state - 1) % N + 1, ((state - 1) ÷ N) + 1
            # println("that's ", r, c)
            return (r, c), state + 1
        end
        # println("illegal")
        state += 1
    end
    return nothing
end

function legalmoves(b::TicTacToeBoard, player::Int)
    return TicTacToeLegalMoves(b)
end



function Base.show(io::IO, tttb::TicTacToeBoard{N}) where N
    if sum(tttb.won) > 0
        winner = argmax(tttb.won)
        println("Game over. Player $(winner) won!")
    elseif tttb.count == N^2
        println("Game over. It's a tie!")
    end
    for r in 1:N
        for c in 1:N
            s = tttb.board[r, c]
            if s == blank
                print(io, '☐')
            elseif s == knot
                print(io, 'O')
            else
                print(io, 'X')
            end
            c < N && print(io, " ")
        end
        r < N && println(io)
    end
    # println(tttb.eachdiagcounts)
end


function randomgameplay()
    b = TicTacToeBoard{3}()
    p = 1
    while !isgameover(b)
        m = rand(collect(legalmoves(b, p)))
        play!(b, p, m)
        # show(b)
        # sleep(1)
        p = 3 - p
    end
    b
end