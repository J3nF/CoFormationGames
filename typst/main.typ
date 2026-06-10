//#import "@preview/charged-ieee:0.1.4": ieee
#import "conf.typ": ieee
#import "@preview/dashy-todo:0.1.3": todo
#import "@preview/lovelace:0.3.1": pseudocode-list

#show: ieee.with(
  title: [ #todo Co-Formation Games],
  abstract: [
    #todo
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

#todo

== Paper overview

#todo

= Methods <sec:methods>

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
    [Action profile], [$a_i$], [${0,1}^n$],
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
    + *while* $(t<t_max and epsilon < Delta c)$ 
      + *if* $mod(t,r_c) = 0 $ *then*
        + select random node $i$
        + $x_i$ arrow.l get opinion update $x_i^u$
      + *end if*
      + *if* $r_f = 1$ *then*
        + select random node $i$
        + $a_i$ arrow.l get action update $a_i^u$
      + *end if*
      + get new costs $c_(t+1)$
      + $Delta c = abs(c_(t+1) - c_t)$
      + $c_t arrow.l c_(t+1)$
      + $t arrow.l t+1$
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
The distances were calculated with @eq:costs that we presented in @sec:methods.

