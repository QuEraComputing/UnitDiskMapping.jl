function Base.match(::Cross{false}, matrix, i, j)  # needs additional check to detect environment
    matrix[i, j] == 2 || return false
    if j<3 || j>size(matrix, 2)-2 || i<2 || i > size(matrix, 1)-2
        return false
    end
    @inbounds for j_=j-2:j+2
        for i_=i-1:i+2
            if i_ == i
                if j_ != j
                    abs(matrix[i_, j_]) == 1 || return false
                end
            elseif j==j_
                abs(matrix[i_, j_]) == 1 || return false
            else
                matrix[i_, j_] == 0 || return false
            end
        end
    end
    return true
end

function Base.match(::Cross{true}, matrix, i, j)  # needs additional check to detect environment
    matrix[i, j] == -2 || return false
    if j<4 || j>size(matrix, 2)-1 || i<4 || i > size(matrix, 1)-2
        return false
    end
    for j_=j-3:j+1
        for i_=i-3:i+2
            if i_ == i
                if j_ != j
                    abs(matrix[i_, j_]) == 1 || return false
                end
            elseif j==j_
                abs(matrix[i_, j_]) == 1 || return false
            else
                matrix[i_, j_] == 0 || return false
            end
        end
    end
    return true
end

function Base.match(s::TShape{:H}, matrix, i, j)
    matrix[i, j] == (iscon(s) ? -2 : 2) || return false
    i==1 && j!=1 && j!=size(matrix, 2) || return false
    return abs(matrix[1,j-1]) == abs(matrix[1,j+1]) == abs(matrix[2,j]) == 1 && matrix[2,j+1] == matrix[2,j-1] == 0
end

function Base.match(s::TShape{:V}, matrix, i, j)
    matrix[i, j] == (iscon(s) ? -2 : 2) || return false
    j==size(matrix, 2) && i!=1 && i!=size(matrix, 1) || return false
    return abs(matrix[i-1,end]) == abs(matrix[i+1,end]) == abs(matrix[i,end-1]) == 1 && matrix[i+1,end-1] == matrix[i-1,end-1] == 0
end

function Base.match(::Turn, matrix, i, j)
    i >= 3 && j<=size(matrix, 2)-2 || return false
    for i_=i-2:i
        for j_=j:j+2
            if i_ == i || j_ == j
                abs(matrix[i_,j_]) == 1 || return false
            else
                matrix[i_,j_] == 0 || return false
            end
        end
    end
    return true
end

function Base.match(s::Corner, matrix, i, j)
    j == size(matrix, 2) && i==1 || return false
    for j_=j-2:j
        for i_=i:i+2
            if i_ == i && j_ == j
                matrix[i_, j_] == (iscon(s) ? -2 : 2) || return false
            elseif i_ == i || j_ == j
                abs(matrix[i_,j_]) == 1 || return false
            else
                matrix[i_,j_] == 0 || return false
            end
        end
    end
    return true
end

#   1
# 2-o-2
#   2
function apply_gadget!(::Cross{false}, matrix, i, j)
    matrix[i, j] = 1
    matrix[i-1, j] = 1
    matrix[i+1, j-1] = 1
    matrix[i+1, j+1] = 1
    return matrix
end

#   3
# 3-o-1
#   2
function apply_gadget!(::Cross{true}, matrix, i, j)
    matrix[i, j-2] = 0
    matrix[i, j] = 0
    matrix[i-2, j] = 0
    matrix[i+1, j] = 0
    matrix[i-1,j-2] = 1
    matrix[i-2,j-1] = 1
    matrix[i-1,j-1] = 1
    matrix[i+1,j-1] = 1
    return matrix
end

# 1-o-1
#   1
function apply_gadget!(::TShape{:H, false}, matrix, i, j)
    matrix[i, j] = 1
    matrix[i+1, j] = 0
    return matrix
end
function apply_gadget!(::TShape{:H, true}, matrix, i, j)
    matrix[i, j] = 0
    return matrix
end

#   1
# 1-o
#   1
function apply_gadget!(::TShape{:V, false}, matrix, i, j)
    matrix[i, j] = 1
    matrix[i, j-1] = 0
    return matrix
end
function apply_gadget!(::TShape{:V, true}, matrix, i, j)
    matrix[i, j] = 0
    return matrix
end

#  2
#  o2
function apply_gadget!(::Turn, matrix, i, j)
    matrix[i, j] = 0
    matrix[i-1, j] = 0
    matrix[i, j+1] = 0
    matrix[i-1, j+1] = 1
    return matrix
end

#  2
#  o2
function apply_gadget!(::Corner{false}, matrix, i, j)
    matrix[i, j] = 0
    matrix[i+1, j] = 0
    matrix[i, j-1] = 0
    return matrix
end

function apply_gadget!(::Corner{true}, matrix, i, j)
    matrix[i, j] = 0
    return matrix
end

