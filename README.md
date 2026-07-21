# colour-guesser

a little toy program that uses a [genetic algorithm](https://github.com/jali-clarke/genetic) to narrow down a colour space depending on the colours you choose.  uses threepenny-gui for the gui.  pass `--help` to the executable to see all runtime opts and tweakables

## how to run

### nix

run directly without cloning via

`nix run github:jali-clarke/colour-guesser [-- --help]`

or clone locally then:

`nix run . [-- --help]`

### haskell

clone locally then:

`hpack && cabal run colour-guesser [-- --help]`
