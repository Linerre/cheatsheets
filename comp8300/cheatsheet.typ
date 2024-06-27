#set page(
    paper: "a4",
    columns: 3,
    numbering: none,
    footer: none,
    header: none,
    margin: 4pt,
    flipped: true               // landscape
)

#set heading(
    numbering: none,
    bookmarked: true,
)

#set text(
    font: "Linux Libertine",
    size: 10pt,
)

#set list(
    spacing: 0.5em,
)

=== Reasons for parallelism [L11,10-12]
  - *speed* (high performance)
  - tackle/solve *larger*-scale problems
  - keep power consumption and heat dissipation under control
  - enable more accurate simulations (finer grids)
  - access huge aggregate memories
  - provide more/better input/output capacity
  - hide latency

=== Overheads in paralle programs [Grama,p196]
  - Idling (load imbalance, synchronization, serial components)
  - Interprocess interaction/communication (data sync)
  - extra computation (unable to reuse some computation results, splitting tasks)
=== Amdhal's law [L11,30]
  $ S(P) = frac(1, gamma + frac(1-gamma,P)) $
  - S(P) is _speedup_ of *P* processors; if $limits(P)_(->oo)$, then $S(P) = 1/gamma$
  - new speed = one-core speed $times$ S(P), i.e. S(P) times faster
  - $gamma = frac(T_"setup" + T_"finalization", T_"total(1)")$ where $gamma$ is _serial fraction_
  - $T_"setup" + T_"finalization" = T_"s"$, exec time of the serial part
  - it assumes no overhead in parallel part; parallel/serial parts perform same num. of steps
  - in real life, running time may be longer
  - problem *size* fixed at n, increase processors, efficiency drops/fixed (not growing)
  - processors fixed at p, increase problem size, efficiency grows (towards upper boundary)
  - increase both n and p, efficiency may be fixed (scalability of parallel systems)

=== Processes v.s. Processors
  #table(
      stroke: none,
      columns: 2,
      table.header([Processes], [Processors]),
      table.hline(),
      [logical computing agents that perform assigned tasks (like file descriptor on Linux)],
      [hardware units that physically perform assign computations (like hard disk)],
  )

=== Flynn's Taxonomy (L12,12-14)
  // #show table.cell.where(y: 3): {set text(gray)}
  #table(
      stroke: none,
      columns: 2,
      align: horizon,
      table.header([Type], [Note]),
      table.hline(),
      [SISD], [universial Turing machine + serial instructions],
      [SIMD], [parallelism w/t inter-process communication],
      [MISD], [No such machines],
      [MIMD], [more general-purpose, extra burden to programmers (2x24-core Xeon CPUs on each Gadi node)],
      table.hline(),
      table.cell(colspan: 2)[S: single, M: multiple, I: instructions, D: data],
      table.hline(),
  )

=== Embarrassingly Parallel problems (L0301, p2)
- "Ideal": problems can be easily divided into completely independent parts
- each part will be handled by a *separate* processor, simultaneously
- (ideally) no communications between those separate processors
- also known as _naturally_ parallel
- frequently use *master(manager)/slave(worker)* approach

=== Balance Load (static v.s. dynamic)
  Static:
  - predicable workloads that can be sorted into equal-cost tasks
  - assign tasks _prior to_ the Unit of Executions (UE)
  - each task is independent; often use single program multiple data (SPMD)
  Dynamic:
  - distribute tasks among processes during the execution of the algorithm
  - if tasks generated dynamically, then mapped dynamically
  - task sizes are often unknown in prior
  - if data associated with tasks is very large, moving data when assigning tasks may cause serious overheads
  - algorithms more complicated (particularly in MPI paradigm)
