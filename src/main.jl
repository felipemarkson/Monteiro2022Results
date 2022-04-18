using Monteiro2022Results

function run()
    modes = [
        Dict(
            "name" => "both",
            "hc" => [-1.0, 0.0, 1.0],
        ),
        Dict(
            "name" => "dg",
            "hc" => [0.0, 1.0],
        ),
        Dict(
            "name" => "ev",
            "hc" => [-1.0, 0.0],
        )
    ]
    for mode in modes
        julia_main(mode)
    end

end

run()