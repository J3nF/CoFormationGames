module CoFormationGames

import Graphs
import Random

"""
    run_iteration!(G, x, r_c, r_g, t_max, ε)

Run update loop for co-formation games and costs over time.

Every r_c steps, a random node updates its opinion via get_opinion_update.
Every r_g steps, a random node updates its connections via get_action_update.

G: Graph
x: Vector, storing edge opinions
r_c: Communication rate
r_g: Float, Communication rate
t_max: Maximum runtime in steps
ε: Threshold to define convergence

"""
function run_game!(G, x, r_c, r_g, t_max, ε)
    t = 1
    c = zeros(t_max)
    c[t] = get_costs(G, x)
    while t < t_max || ε < Δc
        if floor(t / r_c) > floor((t - 1) / r_c)
            node = rand(1:n)
            x_new = get_opinion_update(node, G, x)
        end
        x[node] = x_new
        if floor(t / r_g) > floor((t - 1) / r_g)
            G = get_action_update(G, x)
        end
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

Subscripts '_a' signify variables assuming an action to take place.
"""
function get_action_update(G, x)
    nodes = 1:length(x)
    for _ in nodes
        i = randn!(nodes)
        G_a = check_actions(i, G, x)
        if act != 0
            return G_a
        end
    end
    return G
end

"""
    check_actions(node, G, x)

Iterate through node's sponsorship actions until finding a positive one.
If no helpful action is possible, return zero.

Subscripts '_a' signify variables assuming an action to take place.
"""
function check_actions(node, G, x)
    # Define an iterator over all but the current node
    nodes_without_i = cat(1:node-1, node+1:length(x), dims=1)

    for _ in nodes_without_i
        j = randn!(nodes)
        G_a = get_changed_edge(G, i, j)
        c_0 = get_costs(i, j, G, x)
        c_a = get_costs(i, j, G_tmp, x)
        if c_a < c_0
            return G_a
        end
    end
    return G
end

end # module CoFormationGames
