//#import "@preview/charged-ieee:0.1.4": ieee
#import "conf.typ": ieee
#import "@preview/dashy-todo:0.1.3": todo
#import "@preview/lovelace:0.3.1": pseudocode-list

#show: ieee.with(
  title: [ Co-Formation Games --- Unifying Network Formation and Opinion Dynamics ],
  abstract: [
This report proposes a novel model combining network creation studies and opinion dynamics.
After introducing each Network Formation Games (NFGs) and Social Influence Models (SIMs), we compose a model allowing for co-evolution of opinions and networks and containing both NFGs and SIMs as special cases.
Other sections consider basic dynamics, optimal states, and research directions of these Co-Formation Games (CFGs), as well as showcase an Julia module implementing CFGgames.
Overall, the model offers a promising basis for future research projects, while broadening the perspective of NFGs and SIMs.
  ],
  authors: (
    (
      name: "Jens Friedel",
      department: [School of Engineering Mathematics and Technology],
      organization: [University of Bristol],
      location: [Bristol, United Kingdom],
      email: "jens.friedel@bristol.ac.uk"
    ),
    (
      name: "Richard Pettigrew",
      department: [Department of Philosophy],
      organization: [University of Bristol],
      location: [Bristol, United Kingdom],
      email: "richard.pettigrew@bristol.ac.uk"
    ),
    (
      name: "Martin Bullinger",
      department: [School of Engineering Mathematics and Technology],
      organization: [University of Bristol],
      location: [Bristol, United Kingdom],
      email: "martin.bullinger@bristol.ac.uk"
    ),
  ),
  index-terms: ("Collective dynamics", "Game theory", "Network formation games", "Network theory (graphs)"),
  paper-size: "a4",
  bibliography: bibliography("refs.bib"),
  figure-supplement: [Fig.],
)

= Introduction

Network dynamics plays an ever-important role in describing the modern world, with connective plasticity and local optimizations enabling the emergence of global order.
Since this framework can describe a vast variety of phenomena, researchers employed numerous approaches --- often multidisciplinary ones --- to analyze these systems.
Specifically, networks of human-like agents have been subject of studies ranging from mostly theoretical analysis to phenomenological social science works @Sobkowicz2020WhitherNO @Flache2017ModelsOS.

Even as the sheer numerousness has inspired some authors to question each model's marginal benefit , considering strangs of research showcases a lack of holistic perspectives @Sobkowicz2020WhitherNO:
As a subfield of game theory, Network Formation Games (NFGs) study how self-interested agents create and drive the structure of networks @Fabrikant2003OnAN.
In constrast, Social Influence Models (SIMs) focus on inner states of nodes (opinions) diffusing through it @Flache2017ModelsOS.
In the case of social networks, this raises a tension: As opinion propagation and network formation can both be dynamic and influence each other, results from studies regarding only NFG or SIM do not necessarily generalize to the case of simultaneous dynamics.

This is an important caveat, as real social network behaviour rarely reduces to the semi-static treatment implied by NFGs and SIMs.
Yet, even though there are works trying to combine some aspects of the other's influence, they often do so as a small part of the original model's main mechanism (e.g., @Bullinger2022NetworkCW, @Baumann2019ModelingEC, @Nigam2018ONEMMT).
Moreover, there is still no work unifying both approaches in a way sheltering reults from both disciplines.

This report explores a model which allows topology and opinions to influence each other, while including NFGs and SIMs as special cases.
After presenting NFGs and SIMs, this work presents and justifies each building block of the model, before assessing some basic traits with regard to possible dynamics, optimality and a simulation module implemented in the Julia programming language.

= Background

== Network Formation Games

Introduced as a subfield of Game Theory, Network Formation Games (NFGs) consider agents acting strategically to maximize personal utilities / minimize costs @Fabrikant2003OnAN.
In NFGs, the action agents can decide on is whether or not to sponsor connections to an other agent.
An action profile $a$ --- storing every single agent $i$'s decisions $a_i$ --- consequently produces a graph $G(a)$ in which nodes represent agents and edges @parkes2020algorithmic.

(Since agents are always treated as part of a graph, the following text uses _agent_, _node_ and _vertex_ interchangibly, unless noted otherwise.) 

The cost funciton $c(a_i)$ which each agent wishes to minimize imposes costs $alpha_c$ on each connection sponsored, but encourages connectedness by punishing a distance measure of $i$ in the graph, $d_i (G)$.
When agent $i$ sponsors an edge to $j$, we set $a_(i j) = 1$, and $a_(i j) = 0$ otherwise, so that

$ c_i(a_i) = d_i (G) + alpha_c norm(a_i) $ <eq:cost_i>

returns the cost an agent incurs, with $norm(dot)$ being the L1 norm.

The funciton $d_i$ conventionally depend on the choice of laterality and directedness @parkes2020algorithmic.
Whereas (bi-/)unilaterality implies edge creation to need one (both) nodes' sponsorship, (un)directed networks let one (both) nodes use a single edge to traverse paths.
Commonly, $d_i$ uses the shortest-path distances or the number of reachable nodes, depending.
The definition of our model's $d_i$ is provided when our model is introduced

Because agents are unaware of the other game participants' actions while deciding on an action --- knowledge  of $a$ and the resulting network $G(a)$ is only implicit in @eq:cost_i --- no explicit coordination is possible.
Instead, step-wise adaptions of $a_i$ are taken to reduce costs, until there is no single sponsorship change left which improves costs.
These final states $a^star$ are so-called Nash equilibria (NEs).
They correspond to the concept of local stability, and a big portion NFG-related research devotes itself to analyzing the set of NEs and NE traits.

Since costs are minimised locally and step-wise, a configuration which minimizes the total cost

$ c(a) = sum_(i=1)^n c_i (a_i) = d(G) + alpha_c norm(a) $

may be unreachable:

$ a^"opt" = arg min_a c(a) <= arg min_(a^star) c(a^star) . $

This relates to the Price of Anarchy, which presents how costly selfish strategies end up being relative to game $Gamma$'s optimum costs profile,

$ "PoA"(Gamma) = max_(a^star) C(a^star) / C(a^"opt") . $

Overall, while there are many studies regarding optimality considerations for NFGs in terms of topolgoy @Bil2017OnTT @parkes2020algorithmic and some research weighing costs by categorical opinions @Bullinger2022NetworkCW, NFGs are yet to include explicit information propagation their dynamics.

- Varieties:
-- Laterality
-- Directedness

== Social Influence Models

Social Influence Models (SIMs) investigate how agents interacting with each other may adapt their behaviour due to those interaction, given some theoretical simplifications.
While rooted in social sciences @Degroot1974ReachingAC, the field captured some interest from the hard science theorists, who borrowed models and tools for the interdisciplinary field they call _sociophysics_ or opinion modelling @Sobkowicz2020WhitherNO.

After exhausting hopes of physic's "hard-science" reductionist models inspiring correct descriptions of human interactions, the field underwent a shift towards Agent-based models (ABMs) @Sobkowicz2020WhitherNO, which identify humans as agents following an algorithm to exchange and update information.

Next to defining the domain opinions are drawn from (numerical/categorical, dimsensionality), an update rule describing how to adapt held opinions given an interaciton is at the core of ABMs.
The deGroot model is an established choice, boiling down to interactions leading to averaging of continuous numerical opinions @Degroot1974ReachingAC.
As perfect averaging eventually makes opinions converge and disregards human biases, other approaches let updates depend on proximity of opinions, which enables polarized stable states (e.g., @Friedkin2011SocialIN, @Baumann2019ModelingEC).
While richer dynamics and patterns ensue, it is not trivial how much, if any, practical utility such models offer.
Hence, multiple reviews stress the necessity of exercising caution to properly justify the introduction of novel update mechanisms.

Regarding the network structure, most ABMs assume either communication to take place by random chance or place agents in a fixed topology @Sobkowicz2020WhitherNO.
As a middle-ground, some incorporate homophily (the preference to contact similar agents) by biasing communication rates towards others with similar opinions @Baumann2019ModelingEC.
Overall, though, contact structures are either seen as fixed or only change as the consequence of social influences.
Therefore, models are incapable of deducing social topologies from first principles per se (i.e., in scenarioes without explicit communication).

#todo
- Rather, see "opinion" as label for local information connected to edge; "social" as nodes influence each other due to "personal" information.

= The model --- Co-Formation Games <sec:CFG>

This section summarizes the model choices we made after 
After reviewing both NFG and SIM literature

- This section shows the choices. Considered alternatives are in the appendix.

- Unilateral, Undirected
-- TBW

-  ....... (basically write down notebook page)

== Definitions & Equations

#figure(
  table(
    columns: (12em, 6em, 6em),
    align: (left, center + horizon, left + horizon),
    inset: (x: 8pt, y: 4pt),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    //fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },
    fill: (x, y) => if y > 0 and calc.rem(y, 4) in (1,2)  { rgb("#efefef") },
    
    table.header[*Variable*][*Symbol*][*Domain*],
    [Number of nodes], [$n$], [$NN$],
    [Node of concern], [$i$], [${1, dots, n}$],
    [Set of $i$'s neighbours], [$K_i$], [$NN^norm(k_i)$],
    [Network graph #footnote[The graph is represented as an adjacency matrix.]], [$G$], [${0,1}^(n crossmark n)$],
    [Opinion], [$x_i$], [$RR$],
    [Opinion profile], [$x$], [$RR^(n times n)$],
    [Action], [$a_i$], [${0,1}^n$],
    [Action profile], [$a$], [${0,1}^(n times n)$],
    [Costs per edge], [$alpha_c$], [$[0,infinity[$],
    [Pairwise distance], [$d_(i j)$], [$NN$],
    [Network valuation], [$v$], [ $]-infinity,0]$ ],
    [Network expenses], [$f^c$],  [ $]-infinity,0[$ ],
    [Cost function], [$c$], [ $]-infinity,0[$ ],      // Usually called utility u, but negative domain, so swap symbols
    [Communication rate], [$r_c$], [$[0, infinity[$],
    [Formation rate], [$r_f$], [${0,1}$],
    [Convergence threshold], [$epsilon$], [#todo[Up for discussion]$[0,alpha_c]$],
  ),
  caption: [List of variables used in this document],
) <tab:variables>

where a norm $norm( dot )$ is the L0 norm, returning the count of non-zero elements.

=== Equations

- Cost function
$ c_i = v_i (a) + f^c (a) $ <eq:costs>

- Valuation function
$ v_i (a) = - sum_(j = 1,dots,n) d_(i j) $ <eq:valuation>

- Network expenses:
$ f^c_i (a) = - alpha_c norm(a_i) - 1/norm(k) sum_(j in K_i) abs(x_i-x_j) $ <eq:network-costs>

=== Algorithm

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Dynamics of our synchronous move game],

  pseudocode-list[
    + Initialise $t=1, c($
    + *while* $(t<t_max and epsilon < Delta c)$ 
      + *if* $mod(t,r_c) = 0 $ *then*
        + select random node $i$
        + $x_i$ arrow.l get opinion update $x_i^u$
      + *end if*
      + *if* $r_f = 1$ *then*
        + select random node $i$
        + $a_i$ arrow.l get action update $a_i^u$
      + *end if*
      + t += 1
      + c(t) arrow.l get new costs $c_t$
      + $Delta c = c_(t-1) - c(t)$
    + *end while*
  ]
) <alg:dynamics>

= Introductory examples

== Cost function behaviour

- Copy some of your paper drawings

== New optimal costs

- Examples of chains vs star

== Some simulations




= Old stuff from the template
#figure(
  placement: none,
  circle(radius: 15pt),
  caption: [A circle representing the Sun.]
) <fig:sun>

In @fig:sun you can see a common representation of the Sun, which is a star that is located at the center of the solar system.


#figure(
  caption: [The Planets of the Solar System and Their Average Distance from the Sun],
  placement: top,
  table(
    // Table styling is not mandated by the IEEE. Feel free to adjust these
    // settings and potentially move them into a set rule.
    columns: (6em, auto),
    align: (left, right),
    inset: (x: 8pt, y: 4pt),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 4) in (1,2)  { rgb("#efefef") },

    table.header[Planet][Distance (million km)],
    [Mercury], [57.9],
    [Venus], [108.2],
    [Earth], [149.6],
    [Mars], [227.9],
    [Jupiter], [778.6],
    [Saturn], [1,433.5],
    [Uranus], [2,872.5],
    [Neptune], [4,495.1],
  )
) <tab:planets>

In @tab:planets, you see the planets of the solar system and their average distance from the Sun.
The distances were calculated with @eq:costs that we presented in //@sec:methods.

