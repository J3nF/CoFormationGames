module CoFormationGames

import Graphs
import Random

"""
    run_iteration!(G, x, r_c, r_g, t_max, ε)

Run update iteration for co-formation games.

Every r_c steps, a random node updates its opinion via get_opinion_update.
Every r_g steps, a random node updates its connections via get_action_update.

G: Graph
x: Vector, storing edge opinions
r_c: Communication rate
r_g: Float, Communication rate
t_max: Maximum runtime in steps
ε: Threshold to define convergence

"""
function run_iteration!(G, x, r_c, r_g, t_max, ε)
    t = 0
    c = zeros(t_max)
    c[t] = get_costs(G, x)

    while t < t_max || ε < Δc
        if floor(t / r_c) > floor((t - 1) / r_c)
            node = rand(1:n)
            x_new = get_opinion_update(node, G, x)
        end
        x[node] = x_new
        if floor(t / r_g) > floor((t - 1) / r_g)
            node = rand(1:n)
            get_action_update!(G, x)
        end
        c[t] = get_cost_change()
        t += 1
    end
    return c
end


"""
    get_opinion_update(node, G, x)

Update a node's opinion by diffusing in neighbouring opinions.
"""
function get_opinion_update(node, G, x)
    k = Graphs.neighbors(G, node)
    return (mean(x[k]) + x[node]) / 2
end

"""
    get_action_update(G, x)

Check whether a new action (establishing or cancelling the sponsorship of an
edge) could improve the node's costs.
"""
function get_action_update(G, x)
    nodes = 1:length(x)
    for _ in nodes
        i = randn!(nodes)
        act = check_actions(i, G, x)
        if act != 0
            update_action!(i, G, act)
            return 1
        end
    end
    return 0
end

"""
    check_actions(node, G, x)

Iterate through node's sponsorship actions until finding a positive one.
If no helpful action is possible, return zero.
"""
function check_actions(node, G, x)
    nodes = 1:nodes
end




end # module CoFormationGames
