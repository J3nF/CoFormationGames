module CoFormationGames

import Graphs
import Printf
import Random

"""
    run_game(G, a, x, r_c, r_g, t_max, ε, α_c)

Run update loop for co-formation games and costs over time.

Every r_c steps, a random node updates its opinion via get_opinion_update.
Every r_g steps, a random node updates its connections via get_action_update.

G: Graph
a: Action profile matrix, storing edge sponsorships
x: Vector, storing edge opinions
r_c: Communication rate
r_g: Float, Communication rate
t_max: Maximum runtime in steps
ε: Threshold to define convergence
α_c: Costs per edge
"""
function run_game(G, a, x, r_c, r_g, t_max, ε, α_c)
    t = 1
    c = zeros(t_max)
    c[t] = get_total_costs(G, a, x, α_c)
    Δc = 2 * ε
    while t < t_max && ε < Δc
        if floor(20 * t / t_max) > floor(20 * (t - 1) / t_max)
            print(get_game_progress(t, t_max, c[1], c[t]))
        end
        if r_c > 0 && floor(t / r_c) > floor((t - 1) / r_c)
            x = get_opinion_update(G, x, ε)
        end
        if r_g > 0 && floor(t / r_g) > floor((t - 1) / r_g)
            G, a = get_action_update(G, a, x, α_c, ε)
        end
        t += 1
        c[t] = get_total_costs(G, a, x, α_c)
        Δc = c[t-1] - c[t]
    end
    print(get_game_progress(t, t_max, c[1], c[t]))
    println("\nGame finished after $t steps.")
    return G, a, x, c
end


"""
    get_opinion_update(G, x, ε)

Update a node's opinion by diffusing in neighbouring opinions.
"""
function get_opinion_update(G, x, ε)
    shuffled_nodes = Random.shuffle(1:length(x))
    for i in shuffled_nodes
        x_tmp = check_opinion_update(i, G, x, ε)
        if x_tmp != x[i]
            x_out = copy(x)
            x_out[i] = x_tmp
            return x_out
        end
    end
    return x
end

"""
    check_opinion_update(node, G, x, ε)

TBW

Note the threshold check prevents premature convergence of 'run_game!'.
"""
function check_opinion_update(node, G, x, ε)
    c0 = get_opinion_costs(node, G, x)
    x_tmp = copy(x)
    k = Graphs.neighbors(G, node)
    if length(k) == 0
        return x[node]
    end
    x_tmp[node] = (mean(x[k]) + x[node]) / 2
    c_tmp = get_opinion_costs(node, G, x_tmp)
    # Use update only if cost improvement is above threshold ε
    if c_tmp < c0 - ε
        return x_tmp[node]
    end
    return x[node]
end


"""
    get_action_update(G, a, x, α_c, ε)

Check whether a new action (establishing or cancelling the sponsorship of an
edge) could improve the node's costs.

Subscripts '_tmp' signify variables assuming an action to take place.
"""
function get_action_update(G, a, x, α_c, ε)
    shuffled_nodes = Random.shuffle(1:length(x))
    for i in shuffled_nodes
        G_tmp, a_tmp = check_actions(i, G, a, x, α_c, ε)
        if (G_tmp, a_tmp) != (G, a)
            return G_tmp, a_tmp
        end
    end
    return G, a
end

"""
    check_actions(node, G, a, x, α_c, ε)

Iterate through node's sponsorship actions until finding a positive one.
If no helpful action is possible, return zero.

Subscripts '_tmp' signify variables assuming an action to take place.
"""
function check_actions(node, G, a, x, α_c, ε)
    # Define an iterator over all but the current node
    nodes_without_i = cat(1:node-1, node+1:length(x), dims=1)
    Random.shuffle!(nodes_without_i)
    c_0 = get_costs(node, G, a, x, α_c)

    for j in nodes_without_i
        G_tmp = get_changed_edge(G, node, j)
        a_tmp = copy(a)
        a_tmp[node, j] = 1 - a_tmp[node, j]
        c_tmp = get_costs(node, G_tmp, a_tmp, x, α_c)
        if c_tmp < c_0 - ε
            return G_tmp, a_tmp
        end
    end
    return G, a
end


"""
    get_changed_edge(G, i, j)

TBW
"""
function get_changed_edge(G, i, j)
    G_tmp = copy(G)
    if Graphs.has_edge(G_tmp, i, j)
        Graphs.rem_edge!(G_tmp, i, j)
    else
        Graphs.add_edge!(G_tmp, i, j)
    end
    return G_tmp
end

"""
    get_costs(node, G, a, x, α_c)

TBW
"""
function get_costs(node, G, a, x, α_c) # I could make this and the total cost function one thing by using a vector for "node"...
    c_distances = sum(Graphs.desopo_pape_shortest_paths(G, node))
    c_edges = α_c * sum(a[node, :])
    c_opinion = get_opinion_costs(node, G, x)
    return c_distances + c_edges + c_opinion
end

"""
    get_total_costs(G, a, x, α_c)

TBW
"""
function get_total_costs(G, a, x, α_c)
    Σ_distances = sum(Graphs.floyd_warshall_shortest_paths(G).dists)
    Σ_edges = α_c * sum(a)
    Σ_opinion = sum(get_opinion_costs(i, G, x) for i in 1:length(x))
    return Σ_distances + Σ_edges + Σ_opinion
end

function get_opinion_costs(node, G, x)
    k = Graphs.neighbors(G, node)
    if length(k) == 0
        c_out = 0
    else
        c_out = mean(abs.(x[k].-x[node]))
    end
    return c_out
end

function get_game_progress(t, t_max, c_start, c_t)
    out_string = Printf.@sprintf("t/t_max = %.2f, \t c(t)/c(1) = %.1e", t / t_max, c_t / c_start)
    return out_string
end


end # module CoFormationGames
