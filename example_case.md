# Example Beam Analysis

This example demonstrates the calculator using point, uniform distributed,
and linearly varying loads.

## Beam

- Length: 10 m
- Force units: kN
- Length units: m

## Supports

- Support 1: x = 0 m
- Support 2: x = 10 m

## Applied Loads

### Point Load

- Magnitude: -5 kN
- Location: x = 3 m

### Uniform Distributed Load

- Magnitude: -2 kN/m
- Start: x = 5 m
- End: x = 8 m

### Linearly Varying Load

- Start: x = 8 m
- End: x = 10 m
- Starting magnitude: 0 kN/m
- Ending magnitude: -3 kN/m

## Calculated Support Reactions

- R1 = 5.8 kN
- R2 = 8.2 kN

## Output

![Example shear force and bending moment diagrams](example_output.png)
