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

The cost funciton $c(a_i)$ which each agent wishes to minimize imposes costs $alpha_c$ on each connection sponsored, but encourages connectedness by punishing a distance measure of $i$ in the graph, $c^d_i (G)$.
When agent $i$ sponsors an edge to $j$, we set $a_(i j) = 1$, and $a_(i j) = 0$ otherwise, so that

$ c^"NFG"_i (a_i) = c^d_i (G) + alpha_a norm(a_i) $ <eq:c_i>

returns the cost an agent incurs, with $norm(dot)$ being the L1 norm.

The funciton $c^d_i (G)$ conventionally depend on the choice of laterality and directedness @parkes2020algorithmic.
Whereas (bi-/)unilaterality implies edge creation to need one (both) nodes' sponsorship, (un)directed networks let one (both) nodes use a single edge to traverse paths.
Commonly, $c^d_i (G)$ uses the shortest-path distances or the number of reachable nodes, but depends on network choices made later in this report.
Thus, the definition of the distance costs is provided when our model is introduced in section @sec:CFG.

Because agents are unaware of the other game participants' actions when deciding on an action --- knowledge  of $a$ and the resulting network $G(a)$ is only implicit in @eq:c_i --- there is no room for coordination.
Instead, step-wise adaptions of $a_i$ are taken to reduce costs, until there is no single sponsorship change left which improves costs.
These final states $a^star$ are so-called Nash equilibria (NEs).
They correspond to the concept of local stability, and a big portion NFG-related research devotes itself to analyzing the set of NEs and NE traits.

Since costs are minimised locally and step-wise, a configuration which minimizes the total cost

$ c(a) = sum_(i=1)^n c_i (a_i) = c_d (G) + alpha_c norm(a) $

may be unreachable:

$ a^"opt" = arg min_a c(a) <= arg min_(a^star) c(a^star) . $

This relates to the Price of Anarchy, which presents how costly selfish strategies end up being relative to game $Gamma$'s optimum costs profile,

$ "PoA"(Gamma) = max_(a^star) C(a^star) / C(a^"opt") . $

Overall, while there are many studies regarding optimality considerations for NFGs in terms of topolgoy @Bil2017OnTT @parkes2020algorithmic and some research weighing costs by categorical opinions @Bullinger2022NetworkCW, NFGs are yet to include explicit information propagation their dynamics.

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

= Co-Formation Games <sec:CFG>

This section summarizes the model choices we made for our Co-Formation Games (CFG) after reviewing both NFG and SIM literature.

== Mathematical Model

Firstly, edges are undirected, as communication commonly involves bidirectonal information flow @Flache2017ModelsOS.
Similarily, unilateral sponsorship suffices for edge creation in the model to account for the fact that communication can be initiated by one party in SIMs.
Obviously, there are scenarioes which are better covered by alternative choices.
Next to intuition, though, undirected and unilateral games are a simple choice, which seemed appropriate given the projects short time frame.

The distance cost function then, following the conventional choice for unilateral, undirected NFGs @parkes2020algorithmic, becomes the negated total distance,

$ c^d_i (G) = sum_(j eq.not i) d_(i j) , $ <eq:d_ij>

with $d_(i j)$ being the shortest pairwise distance.
Note that unconnected graphs will suffer infinite costs. 

Furthermore, it is worth mentioning that undirected, unilateral NFGs optimal configurations contain only the fully connected and star graphs for positve edge costs $alpha_c eq.not 2$.
One goal of our model, then, can be to find new optimal networks.

Let us now regard decisions on opinion dynamics, for which simplicity was an important factor, as choosing a well-understood SIM eases the attribution and understanding of results to stem from CFGs' co-evolution dynamic.
We define an opinion to be a real number which, when updated, gets averaged with the neighbours' opinions.
This follows the classical deGroot mechanism @Degroot1974ReachingAC.
While bound to converge, this guarantees stability of the opinion landscape, which is a necessary condition for overall stability in a CFG.

We denote agent $i$'s opinion as $x_i$, which then gives the deGroot opinion update as

$ x_i^"new" = (x_i + chevron.l x_j chevron.r_(K_i) ) / 2 . $ <eq:degroot>

where

$ K_i = {j}_(d_(i j) = 1) $

is the set of $i$'s neighbours.

Further, the opinion profile $x$ refers to the collection of all opinions ${x_i}_(i=1,...,n)$.

To incorporate SIM into the NFG, we introduce an opinion-based cost term 

$ c^x (x,G) = 1/norm(K_i) sum_(j in K_i) abs(x_i-x_j) . $ <eq:c_x>

and define the overall cost function to consist out of

$
c^"CFG"_i (a,x) 
  &= c^d_i (G) + c^a_i (a_i) + c^x_i (x,G) \
  &= sum_(j eq.not i) d_(i j) + alpha_a norm(a_i) + 1/norm(K_i) sum_(j in K_i) abs(x_i-x_j)
$ <eq:c_cfg>

for a single agent, and system-wide costs

$ c^"CFG" (a,x) = sum_(i=1)^n c^"CFG"_i (a,x) . $

It follows that nodes have to balance their original NFG goal with the minimisation of neighborhood polarisation.

Note how, whereas distance costs foster sponsorship and edge costs imply sparsity, the opinion term's effect can be ambiguous and context-sensitive.
Sometimes dropping a connection to a disagreeing agent may minimise costs, while denser neighborhoods (when dropping a single edge makes little difference) can lead to sponsorships to other agreeing nodes.
Also, the probability of a node extending or reducing their sponsorships depends on the network-wide opinion profile $x$ for agents happy to choose any cost-reducing step:
If the majority of other agents disagree, there are few worthwile edges whose creation reduced $c_i$, and vice versa.

With regard to long-term dynamics, consider how @eq:c_x vanishes in the case of total opinion convergence $abs(x_i-x_j)=0 forall i,j $, reducing  @eq:c_cfg to the original NFG cost <eq:cost_i>.
Given deGroot's opinion averaging and distance costs enforcing connected networks, CFGs have the same set of theoretical long-term Nash equilibria as NFGs.
That being said, it may be that CFGs can reach NEs inaccessible to classical NFGs.

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
    [Network graph], [$G$], [${0,1}^(n crossmark n)$],
    [Opinion], [$x_i$], [$RR$],
    [Opinion profile], [$x$], [$RR^n$],
    [Action], [$a_i$], [${0,1}^n$],
    [Action profile], [$a$], [${0,1}^(n times n)$],
    [Distance costs], [$c^d$], [ $ZZ^-$ ],
    [Pairwise distance], [$d_(i j)$], [$NN$],
    [Sponsorship costs], [$c^a$],  [ $]-infinity,0[$ ],
    [Costs per edge], [$alpha_c$], [ $]0,infinity[$ ],
    [Opinion costs], [$c^x$], [ $]-infinity,0[$ ],
    [Opinion range], [$alpha_x$], [$RR^+$],
    [Set of $i$'s neighbours], [$K_i$], [$NN$],
    [Communication rate], [$r_c$], [ $[0, infinity[$ ],
    [Action rate], [$r_a$], [${0,1}$],
    [Convergence threshold], [$epsilon$], [ $]0,alpha_c]$ ],
  ),
  caption: [List of variables used in Co-Formation Games],
  placement: auto,
) <tab:variables>

== Co-evolution Algorithm

Lastly, this section presents the explicit game dynamics.
After providing initial action and opinion profiles $a, x$, a game starts and proceeds in discrete time steps $t$.

Rate parameters $r_x$ and $r_a$ determine the frequency of opinion and action updates.
When an update is due, a random node $i$ gets to either update their opinion, or find an action update improving $c^"CFG"_i$.
If there is no such action step, the game probes other nodes until it finds one or probed all agents, in which case no action update takes place.

While, theoretically, the game runs indefinitely, we can expect costs to converge after some time.
In pracice, simulations end after surpassing the allocated runtime or total costs $c^"CFG"$ changing less than a threshold $epsilon$.

This way, CFGs include both NFGs and SIMs as the special cases of $r_x=0$ and $r_a=0$, respectively, while allowing for a co-evolution of opinions and networks in the general case.

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Schematic CFG algorithm pseudocode. Note this algorithm expects node $i$ to have a cost-reducing action step available, whereas the actual implementation looks through nodes until it found one such step or probed all agents.],

  pseudocode-list[
    + Initialise $a, x$
    + $Delta c = 2 epsilon$
    + *while* $(t<t_max and epsilon < Delta c)$ 
      + *if* $mod(t,r_x) = 0 $ *then*
        + select random node $i$
        + $x_i arrow.l$ get opinion update $x_i^u$
      + *end if*
      + *if* $mod(t,r_f) = 0$ *then*
        + select random node $i$
          + $a_i arrow.l$ get action update $a_i^u$
      + *end if*
      + t += 1
      + $c(t) arrow.l$ get new costs $c_t$
      + $Delta c = c_(t-1) - c(t)$
    + *end while*
  ],
  placement: auto,
) <alg:dynamics>

= 

== Cost function behaviour

- Copy some of your paper drawings

== New optimal costs

- Examples of chains vs star

== Some simulations
