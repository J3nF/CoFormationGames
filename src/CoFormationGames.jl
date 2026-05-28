module CoFormationGames

import Graphs

"""
Run update iteration for co-formation games.

Every r_c steps, a random node updates its opinion via get_opinion_update.
Every r_g steps, a random node updates its connections via get_action_update.
"""
function run_iteration!(G, x, r_c, r_g, t_max, ε)
    t = 0
    Δc = 2 * ε
    while t < t_max || ε < Δc
        if floor(t / r_c) > floor((t - 1) / r_c)
            node = rand(1:n)
            x_new = get_opinion_update(node)
        end
        x[node] = x_new
        if floor(t / r_g) > floor((t - 1) / r_g)
            node = rand(1:n)
            get_action_update(node)
        end
        Δc = get_cost_change()
        t += 1
    end
end


"""Update a node's opinion by diffusing in neighbouring opinions."""
function get_opinion_update(node, G, x)
    k = Graphs.neighbors(G, node)
    neighbours_avg = mean(x[k])
end




end # module CoFormationGames
