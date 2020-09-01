# Arctic Duck Storm

Arctic Duck Storm is a game where player controls a duck flying through an arctic storm. Goal of the game is to gain as many points as possible by avoiding falling snowballs.

![Teaser of the gameplay](gameplay.gif)

Game is written for Atari 2600 VCS in 6502 Assembly language.

## How to play

Online with [Javatari emulator](https://8bitworkshop.com/v3.6.0/embed.html?p=vcs&r=TFpHAAAQAAAAA7VJNHHTARYaIyepAoUAhQInIqkAhQBgJ8EChQGiISMFDYUOhQ%2BFG4UchQmFAsrQ7aAApYApfyBI8KABpYojgSMuKiDW8CMkASMxOOkPsPxJBwonAZkgAJkQAIUCIw4aCkGpHIUIIwgKppWkm7m%2B8inwhZ2kmSNBDwWdhZ2FAoUOpJwj0J6kmiPQnoWeIPbwIxEjF4QO5pvmnOaZ5pojC8qFDtC5GgdVGgO5JyhgogG1likPhZgKCmWYlZkjBPBKSoWYSkojBpvKEONgYIUCpaWFCKkBhQqlpoUJqfAaAkCpAIUPolaKOOWBxYKQAqkAGGWHqIUCsYOFG7GFhQYjEIvFjCPQkSNQjYUcsY%2FK0M%2BFAmCliCWJ8B0jOIilgmWCxYfQCSBb8WClgoWHYBgjSifh5ohgpZIlkyOekqWMZYzFkSMegSMejIWRIx4jCifh5pJgpZQKRSdDJ2ImlEpKhYqpFGWKJ6FUhYullCkHhQUnoQ%2BFDGClixjJADAOIOPxqQfFiRARxotM4vEgkfH4pZYYaQGFltjGiyciYKmAJAfQByAX8kz28WAgKfIgCfKFLKWhKSDwGiKGoSAg8mDmoWClpIWlhaYjCZYjO2ClooWmpaOFpWAjCRmFF4UVYKkDhRmpFIUXqQEjRRpCHR4aQg%2F7GiP2AAAYGH7bDzUfHgAAEBoHAgjbfhgjQjQ0NPDw8B7Q0NAaEgIAPvv9334cACcBI8JBFBoGAgBBVSMdJxl3VVVVdxEnAncRd0R3dxEzESMLIwojBRF3J4FVIwwjVlUjQiMRdyIjAlVmJyIzREREM2YjOWZ3RGYjNCeBRKkgLIAC0BHGgan1xYHwZyflX2CpQCNQFKkXxYDQAWDGgKkIhQsnYYkgRfGpgCNTE6WAyW8QDeaAqQAaCBIQI1ISpYHJRhAM5oHmgakBI5BgxoGpICPaGgJWARopc0yv82ClnyWg8BQjBp%2F4pZc46QGFl9ill8kA8ARg5p9geNiiAIqoyppI0PupPIWAqUaFgakKhYIn4YOp8oWEqWSFhSfhhiM2hxoCfoWIqWmFiiMWiyMejKmChY0jFo6poIWPqfKNofIjH5GFkiMhk6nUhZSpBYWVIwqW%2BKkAaVmFl9gjBJ%2BpQIWgJ%2BGhqYyFooWmIz2jhaWFB6lEhaQgAPAgD%2FAgXvAg9%2FAgNvIgDvMgu%2FEga%2FEgkvNMOfT%2FJx8nHycfJx8nHycfJx8nHycfJx8nHycfJx8nHycfJx8nHycfJx8nHycfJx8nHycc%2F6%2Fzr%2FM%3D) or locally using [dasm assembler](https://dasm-assembler.github.io/) and [Stella emulator](https://stella-emu.github.io/) (described below).

## Prerequisites

- [dasm](https://dasm-assembler.github.io/)
- [Stella](https://stella-emu.github.io/)
- `make` (platform specific)

## Compilation

```cmake
make
```

## Execution

```cmake
make run
```

## Controls

### Movement

Arrow keys.
