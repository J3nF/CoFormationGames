//#import "@preview/charged-ieee:0.1.4": ieee
#import "conf.typ": ieee
#import "@preview/dashy-todo:0.1.3": todo
#import "@preview/lovelace:0.3.1": pseudocode-list

#show: ieee.with(
  title: [ Co-Formation Games --- Unifying Network Formation and Opinion Dynamics ],
  abstract: [
This report proposes a novel model combining network creation studies and opinion dynamics.
After introducing each Network Formation Games (NFGs) and Social Influence Models (SIMs), I compose a model allowing for co-evolution of opinions and networks and containing both NFGs and SIMs as special cases.
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
In constrast, Social Influence Models (SIMs) focus on inner states of nodes (opinions) diffusing through it.
In the case of social networks, this raises a tension: As opinion propagation and network formation can both be dynamic and influence each other, results from studies regarding only NFG or SIM do not necessarily generalize to the case of simultaneous dynamics.

This is an important caveat, as real social network behaviour rarely reduces to the semi-static treatment implied by NFGs and SIMs.
Yet, even though there are works trying to combine some aspects of the other's influence, they often do so as a small part of the original model's main mechanism (e.g., @Bullinger2022NetworkCW, @Baumann2019ModelingEC, @Nigam2018ONEMMT).
Moreover, there is still no work unifying both approaches in a way sheltering reults from both disciplines.

This report explores a model which allows topology and opinions to influence each other, while including NFGs and SIMs as special cases.
After presenting NFGs and SIMs, this work presents and justifies each building block of the model, before assessing some basic traits with regard to possible dynamics, optimality and a simulation module implemented in the Julia programming language.

= Background

== Network Formation Games

- Consider personal utility-maximising agents

- Action: Establish or cut edge sponsorship

- All actions (action profile) lead to Graph G(a), hooray.

- Costs: Generally speaking, agents incur costs when sponsoring, and profit from closeness.
-- Overall cost function design like this...
- Stability concepts:
-- Nash equilibrium: No agent can increase utility via a single step. Think local equilibrium.
-- Optimal system: Graphs which minimise global costs.
-- PoA...

- Varieties:
-- Laterality
-- Directedness

- In terms of overlapping research:
-- Martin went for shapes ~ opinions or sth. That's it.

== Social Influence Models

(- Sidenote: Often used interchangibly with opinion dynamics, sorry Michael)

- Basic idea: Agents have opinions. Interaction = opinion exchange => Consequence

- Historically, most models are random interactions, i.e., have no topology.

- Some simple models
-- deGroot: Averaging real numbers
-- Ising model: we are all discrete spins
-- Modern stuff: Homophily, Similarity.
--- Structure implied, but not specific.
-- Bounded confidence et al. Because convergence was boring.
 
- Criticisms: No model captures true human behaviour so far. Duh.

- For our purpose: Edging closer to holistic model. No wish to capture human spirit or anything.
- Rather, see "opinion" as label for local information connected to edge; "social" as nodes influence each other due to "personal" information.

= The model --- Co-Formation Games <sec:CFG>

- This section shows the choices. Considered alternatives are in the appendix.

- Unilateral, Undirected
-- TBW

- 

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

