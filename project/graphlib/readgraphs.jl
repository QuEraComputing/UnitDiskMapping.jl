############################ G6 graphs ###########################
# NOTE: this script is copied from GraphIO.jl
function _g6StringToGraph(s::AbstractString)
    V = Vector{UInt8}(s)
    (nv, rest) = _g6_Np(V)
    bitvec = _g6_Rp(rest)

    ixs = Vector{Int}[]
    n = 0
    for i in 2:nv, j in 1:(i - 1)
        n += 1
        if bitvec[n]
            push!(ixs, [j, i])
        end
    end
    return nv, ixs
end

function _g6_Rp(bytevec::Vector{UInt8})
    x = BitVector()
    for byte in bytevec
        bits = _int2bv(byte - 63, 6)
        x = vcat(x, bits)
    end
    return x
end
function _int2bv(n::Int, k::Int)
  bitstr = lstrip(bitstring(n), '0')
  l = length(bitstr)
  padding = k - l
  bv = falses(k)
  for i = 1:l
    bv[padding + i] = (bitstr[i] == '1')
  end
  return bv
end

function _g6_Np(N::Vector{UInt8})
    if N[1] < 0x7e return (Int(N[1] - 63), N[2:end])
    elseif N[2] < 0x7e return (_bv2int(_g6_Rp(N[2:4])), N[5:end])
    else return(_bv2int(_g6_Rp(N[3:8])), N[9:end])
    end
end

function load_g6(filename)
    res = SimpleGraph{Int}[]
    open(filename) do f
        while !eof(f)
            line = readline(f)
            nv, ixs0 = _g6StringToGraph(line)
            push!(res, ixs2graph(nv, ixs0))
        end
    end
    return res
end

function ixs2graph(n::Int, ixs)
    g = SimpleGraph(n)
    for (i, j) in ixs
        add_edge!(g, i, j)
    end
    return g
end