---
title: ~elis/cubing/3x3-cfop/
type: cubing
cubeSize: 3
algorithms:
  # - name: Template algorithm
  #   notation:
  #     full: R U R' U'
  #     short: R U R' U'     # Optional: to show easier to remember version like "sexy" instead of full notation
  #   description: |
  #     This is a template algorithm entry. Replace with actual algorithm data.
  #   animCube:
  #     initMove: ""         # Recommended: Set to x2 to get yellow side on top
  #     buttonBar: 1         # Default: show button bar (1) or not (0)
  #     buttonHeight: 25     # Default: height of buttons in px
  #     speed: 10            # Default: animation speed
  #     initRevMove: '#'     # Default: '#' means no reverse initial move and is default

  - name: Sexy Move
    notation:
      full: R U R' U'
    description: |
      Very useful and recurring algorithm in cubing, is used as part of many
      other algorithms. It is often referred to as the "Sexy Move". If repeated
      six times, it results in a full rotation of the cube.
    animCube:
      initMove: x2

  - name: CFOP / OLL Cross / Line
    notation:
      full:  F (R U R' U') F'
      short: F (sexy)      F'
    description: |
      The Line Algorithm in the OLL cross is used to orient all four edges of
      the last layer to form a cross on the top face.
    animCube:
      initMove: x2

  - name: CFOP / OLL Cross / Hook
    notation:
      full:  f (R U R' U') f'
      short: f (sexy)      f'
    description: |
      The Hook Algorithm in the OLL cross is used to orient all four edges of
      the last layer to form a cross on the top face when two edges are already
      correctly oriented.
    animCube:
      initMove: x2

  - name: CFOP / OLL Cross / Dot
    notation:
      full:  F (R U R' U') F' f (R U R' U') f'
      short: (line)           (hook)
    description: |
      The Dot Algorithm in the OLL cross is used to orient all four edges of
      the last layer to form a cross on the top face when no edges are
      correctly oriented.
    animCube:
      initMove: x2

  - name: CFOP / OLL Corners / Sune
    notation:
      full: (R U R' U) (R U2 R')
    description: |
      The Sune Algorithm in OLL corners is used to orient all four corners
      of the last layer when one corner is already correctly oriented.
    animCube:
      initMove: x2

  - name: CFOP / OLL Corners / Anti-Sune
    notation:
      full: (R U2 R') (U' R U' R')
    description: |
      The Anti-Sune Algorithm in OLL corners is used to orient all four
      corners of the last layer when one corner is already correctly oriented,
      but in the opposite direction compared to the Sune case.
    animCube:
      initMove: x2

  - name: CFOP / OLL Corners / Headlights
    notation:
      full:  (R U R' U R U2 R') U (R U2 R' U' R U' R')
      short: (sune)             U (anti-sune)
    description: |
      My slow Headlights Algorithm in OLL corners is used to orient two
      corners facing the same direction (headlights).
    animCube:
      initMove: x2

  - name: CFOP / OLL Corners / Chameleon
    notation:
      full:  (R U R' U R U2 R') U' (R U2 R' U' R U' R')
      short: (sune)             U' (anti-sune)
    description: |
      My slow Chameleon Algorithm in OLL corners is used to orient two
      corners facing out from each other (chamelion).
    animCube:
      initMove: x2

  - name: CFOP / OLL Corners / Bowtie
    notation:
      full:  (R U R' U R U2 R') U2 (R U2 R' U' R U' R')
      short: (sune)             U2 (anti-sune)
    description: |
      My slow Bowtie Algorithm in OLL corners is used to orient two
      corners facing towards each other (bowtie).
    animCube:
      initMove: x2

  - name: CFOP / OLL Corners / Double Sune
    notation:
      full:  (R U R' U R U2 R') (R U R' U R U2 R')
      short: (sune)             (sune)
    description: |
      My slow Double Sune Algorithm in OLL corners is used to orient all
      four corners of the last layer when no corners are correctly oriented.
    animCube:
      initMove: x2

  - name: CFOP / OLL Corners / Pi
    notation:
      full:  (R U R' U R U2 R') U' (R U R' U R U2 R')
      short: (sune)             U' (sune)
    description: |
      My slow Pi Algorithm in OLL corners is used to orient all four corners
      of the last layer when no corners are correctly oriented.
    animCube:
      initMove: x2

  - name: CFOP / PLL Corners / T-Perm (Headlights)
    notation:
      full:  (R U R' U') R' F R2 U' R' U' R U R' F'
      short: (sexy)      R' F R2 U' R' U' R U R' F'
    description: |
      The T-Perm with Headlights Algorithm in PLL corners is used to swap
      two adjacent corners while keeping the other pieces in place, when
      two corners are facing the same direction (headlights).
    animCube:
      initMove: x2

  - name: CFOP / PLL Corners / Y-Perm (No Headlights)
    notation:
      full:  F R U' R' U' R U R' F' (R U R' U') R' F R F'
      short: F R U' R' U' R U R' F' (sexy)      R' F R F'
    description: |
      The Y-Perm with No Headlights Algorithm in PLL corners is used to
      swap two adjacent corners while keeping the other pieces in place,
      when no corners are facing the same direction.
    animCube:
      initMove: x2

  - name: CFOP / PLL Edges / Ua-perm (Counter clockwise)
    notation:
      full: (R2 U' R') U' R (U R) (U R) U' R
    description: |
      The Ua-perm Algorithm in PLL edges is used to cycle three edge pieces
      in the last layer in a counter-clockwise direction while keeping the
      other pieces in place.
    animCube:
      initMove: x2

  - name: CFOP / PLL Edges / Ub-perm (Clockwise)
    notation:
      full: R' U (R' U') (R' U') R' U (R U R2)
    description: |
      The Ua-perm Algorithm in PLL edges is used to cycle three edge pieces
      in the last layer in a counter-clockwise direction while keeping the
      other pieces in place.
    animCube:
      initMove: x2

  - name: CFOP / PLL Edges / H-perm
    notation:
      full: M2' U' (M2' U2' M2') U' M2'
    description: |
      The H-perm Algorithm in PLL edges is used to swap two pairs of edge
      pieces on opposite sides of the last layer while keeping the other
      pieces in place.
    animCube:
      initMove: x2

  - name: CFOP / PLL Edges / Z-perm
    notation:
      full: M' U' (M2' U') (M2' U') M' U2' M2' U
    description: |
      The Z-perm Algorithm in PLL edges is used to swap two pairs of edge
      pieces on adjacent sides of the last layer while keeping the other
      pieces in place.
    animCube:
      initMove: x2
---

This page is in no way a comprehensive guide to cubing but provides a
selection of useful algorithms mostly for my own reference of
algorithms that I use.

So for a more complete resource, check out [cube.academy/](https://www.cube.academy/).
