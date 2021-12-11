struct WeightedCell{RT}
    occupied::Bool
    doubled::Bool
    connected::Bool
    weight::RT
end

abstract type WeightedCrossPattern end
abstract type WeightedSimplifyPattern end
const WeightedPattern = Union{WeightedCrossPattern, WeightedSimplifyPattern}