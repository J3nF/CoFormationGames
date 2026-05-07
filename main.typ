//#import "@preview/charged-ieee:0.1.4": ieee
#import "conf.typ": ieee
#import "@preview/dashy-todo:0.1.3": todo

#show: ieee.with(
  title: [ #todo Co-Formation Games],
  abstract: [
    #todo
  ],
  authors: ( // todo
    (
      name: "Martin Haug",
      department: [Co-Founder],
      organization: [Typst GmbH],
      location: [Berlin, Germany],
      email: "haug@typst.app"
    ),
    (
      name: "Laurenz Mädje",
      department: [Co-Founder],
      organization: [Typst GmbH],
      location: [Berlin, Germany],
      email: "maedje@typst.app"
    ),
  ),
  index-terms: ("Scientific writing", "Typesetting", "Document creation", "Syntax"),
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

#table(
  columns: 3,
  align: (left, center + horizon, center + horizon),
  stroke: .25pt,
  
  table.header[*Variable*][*Symbol*][*Domain*],
  [#todo[$c$ is already taken] Cost/Utility function], [$c \/ u$], [ $]-infinity,0[$ ],
  [Costs per edge], [$c$], [$[0,infinity[$],
  [Pairwise distance], [$d_(i j)$], [$bb(N)$],
  
  
  
)

$ a + b = gamma $ <eq:gamma>

#lorem(80)

#figure(
  placement: none,
  circle(radius: 15pt),
  caption: [A circle representing the Sun.]
) <fig:sun>

In @fig:sun you can see a common representation of the Sun, which is a star that is located at the center of the solar system.

#lorem(120)

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
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

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
The distances were calculated with @eq:gamma that we presented in @sec:methods.

#lorem(240)

#lorem(240)
