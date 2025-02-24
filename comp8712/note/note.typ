#import "@preview/cetz:0.3.2"
#import "@preview/finite:0.4.1"

#set page(
    paper: "a4",
    margin: (
        top: 0.5cm,
        bottom: 1cm,
        x: 0.5cm,
    ),
    columns: 3,
    flipped: true,
)
#set columns(gutter: 6pt)

= NFA to DFA (subset construction)
#finite.automaton(
    (
        // states
        q0: (q0: "0,1", q1: 0),
        q1: (q2: 1),
        q2: none
    ),
    initial: "q0",
    final: ("q2"),
    style: (
        state: (radius: .3),
        transition: (curve: 0, stroke: 1pt + black),
        label:(angle: 90)
    ),
    layout: finite.layout.linear.with(spacing: 1.2),
)
