---
title: ~elis/cubing/
type: cubing
algorithms:
  - name: Sexy Move
    notation: R U R' U'
    description: |
      Very useful and recurring algorithm in cubing, is used as part of many
      other algorithms. It is often referred to as the "Sexy Move". If repeated
      six times, it results in a full rotation of the cube.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R U R' U'"

  - name: CFOP / OLL Cross / Line
    notation: F (sexy) F'
    description:
      The Line Algorithm in the OLL cross is used to orient all four edges of
      the last layer to form a cross on the top face.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=F R U R' U' F'"

  - name: CFOP / OLL Cross / Hook
    notation: f (sexy) f'
    description:
      The Hook Algorithm in the OLL cross is used to orient all four edges of
      the last layer to form a cross on the top face when two edges are already
      correctly oriented.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=f R U R' U' f'"

  - name: CFOP / OLL Cross / Dot
    notation: (line) (hook)
    description:
      The Dot Algorithm in the OLL cross is used to orient all four edges of
      the last layer to form a cross on the top face when no edges are
      correctly oriented.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=F R U R' U' F' f R U R' U' f'"

  - name: CFOP / OLL Corners / Sune
    notation: (R U R' U) (R U2 R')
    description:
      The Sune Algorithm in OLL corners is used to orient all four corners
      of the last layer when one corner is already correctly oriented.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R U R' U R U2 R'"

  - name: CFOP / OLL Corners / Anti-Sune
    notation: (R U2 R') (U' R U' R')
    description:
      The Anti-Sune Algorithm in OLL corners is used to orient all four
      corners of the last layer when one corner is already correctly oriented,
      but in the opposite direction compared to the Sune case.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R U2 R' U' R U' R'"

  - name: CFOP / OLL Corners / Headlights
    notation: (sune) U (anti-sune)
    description:
      My slow Headlights Algorithm in OLL corners is used to orient two
      corners facing the same direction (headlights).
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R U R' U R U2 R' U R U2 R' U' R U' R'"

  - name: CFOP / OLL Corners / Chameleon
    notation: (sune) U' (anti-sune)
    description:
      My slow Chameleon Algorithm in OLL corners is used to orient two
      corners facing out from each other (chamelion).
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R U R' U R U2 R' U' R U2 R' U' R U' R'"

  - name: CFOP / OLL Corners / Bowtie
    notation: (sune) U2 (anti-sune)
    description:
      My slow Bowtie Algorithm in OLL corners is used to orient two
      corners facing towards each other (bowtie).
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R U R' U R U2 R' U2 R U2 R' U' R U' R'"

  - name: CFOP / OLL Corners / Double Sune
    notation: (sune) (sune)
    description:
      My slow Double Sune Algorithm in OLL corners is used to orient all
      four corners of the last layer when no corners are correctly oriented.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R U R' U R U2 R' R U R' U R U2 R'"

  - name: CFOP / OLL Corners / Pi
    notation: (sune) U' (sune)
    description:
      My slow Pi Algorithm in OLL corners is used to orient all four corners
      of the last layer when no corners are correctly oriented.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R U R' U R U2 R' U' R U R' U R U2 R'"

  - name: CFOP / PLL Corners / T-Perm (Headlights)
    notation: (sexy) R' F R2 U' R' U' R U R' F'
    description:
      The T-Perm with Headlights Algorithm in PLL corners is used to swap
      two adjacent corners while keeping the other pieces in place, when
      two corners are facing the same direction (headlights).
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R U R' U' R' F R2 U' R' U' R U R' F'"

  - name: CFOP / PLL Corners / Y-Perm (No Headlights)
    notation: F R U' R' U' R U R' F' (sexy) R' F R F'
    description:
      The Y-Perm with No Headlights Algorithm in PLL corners is used to
      swap two adjacent corners while keeping the other pieces in place,
      when no corners are facing the same direction.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=F R U' R' U' R U R' F' R U R' U' R' F R F'"

  - name: CFOP / PLL Edges / Ua-perm (Counter clockwise)
    notation: (R2 U' R') U' R (U R) (U R) U' R
    description:
      The Ua-perm Algorithm in PLL edges is used to cycle three edge pieces
      in the last layer in a counter-clockwise direction while keeping the
      other pieces in place.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R2 U' R' U' R U R U R U' R"

  - name: CFOP / PLL Edges / Ub-perm (Clockwise)
    notation: R' U (R' U') (R' U') R' U (R U R2)
    description:
      The Ua-perm Algorithm in PLL edges is used to cycle three edge pieces
      in the last layer in a counter-clockwise direction while keeping the
      other pieces in place.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=R' U R' U' R' U' R' U R U R2"

  - name: CFOP / PLL Edges / H-perm
    notation: M2 U' (M2 U2 M2) U' M2
    description:
      The H-perm Algorithm in PLL edges is used to swap two pairs of edge
      pieces on opposite sides of the last layer while keeping the other
      pieces in place.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=M2 U' (M2 U2 M2) U' M2"

  - name: CFOP / PLL Edges / Z-perm
    notation: M' U' (M2 U') (M2 U') M' U2 M2 U
    description:
      The Z-perm Algorithm in PLL edges is used to swap two pairs of edge
      pieces on adjacent sides of the last layer while keeping the other
      pieces in place.
    params: "buttonheight=25&buttonbar=1&speed=10&initmove=x2&initrevmove=#&move=M' U' M2 U' M2 U' M' U2 M2 U"
---

This page is in no way a comprehensive guide to cubing but provides a
selection of useful algorithms mostly for my own reference of
algorithms that I use.

So for a more complete resource, check out [cube.academy/](https://www.cube.academy/).
