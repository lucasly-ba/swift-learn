# swiftlings-linux

Small exercises to learn Swift on Linux, in the style of
[Rustlings](https://github.com/rust-lang/rustlings). You fix one broken file at a
time; the runner recompiles it on save and moves you forward when it passes. Each
exercise links to the matching chapter of
[The Swift Programming Language](https://docs.swift.org/swift-book/).

This is a fork of [Swiftlings](https://github.com/tornikegomareli/swiftlings) by
Tornike Gomareli, which is a macOS-focused project. The exercises and the runner
come from there. What this fork adds is making the whole thing build and run on
Linux: it targets a Swift 6.x toolchain from swift.org, fixes the toolchain
issues that showed up along the way (see [Notes on the Linux port](#notes-on-the-linux-port)),
adds a `doc` link to the relevant Swift book chapter in every hint, ships a
Makefile and Linux CI, and rewrites the runner's watch loop to compile cleanly
under the Swift 6 language mode.

## Prerequisites

- Swift 6.x, installed from [swift.org](https://www.swift.org/install/linux/)
- git

Check your toolchain:

```sh
swift --version
```

## Quick start

```sh
git clone https://github.com/lucasly-ba/swiftlings-linux.git
cd swiftlings-linux
make install        # builds a release binary into ~/.local/bin
swiftlings          # start
```

`make install` puts `swiftlings` in `~/.local/bin`, so make sure that is on your
`PATH`. If you would rather not install anything, run it straight from the repo
with `swift run swiftlings`.

## How it works

Open the first unsolved exercise. It has a `// TODO` and a compiler or logic
error. Fix it and save. In watch mode the runner recompiles and reruns the file
automatically. An exercise is solved once it compiles and all of its checks pass,
and you move on to the next one.

While watching, these keys work: `h` for a hint, `l` to list everything, `n` to
move on once the current exercise passes, `r` to rerun, and `q` to quit.

## Commands

| Command             | What it does                                          |
| ------------------- | ----------------------------------------------------- |
| `swiftlings`        | Watch mode: fix, save, repeat                         |
| `swiftlings run`    | Run the current exercise once, or `run NAME`          |
| `swiftlings list`   | Every exercise and your progress                      |
| `swiftlings hint`   | A hint, plus a link to the relevant Swift book page   |
| `swiftlings reset`  | Put an exercise back to its starting state            |

## Topics

The exercises go from the basics to the deeper parts of the language:

1. `00_basics`
2. `01_control_flow`
3. `02_functions`
4. `03_collections`
5. `04_optionals`
6. `05_structs`
7. `06_classes`
8. `07_enums`
9. `08_protocols`
10. `09_extensions`
11. `10_generics`
12. `11_error_handling`
13. `12_closures`
14. `13_memory_management`
15. `14_property_wrappers`
16. `15_concurrency`
17. `16_result_builders`
18. `17_advanced_types`
19. `18_codable`

There is also a small data-structures track that builds a queue from scratch.
Each topic folder has a `README.md` with a short explanation and links to the
official docs.

## Notes on the Linux port

The runner began as a macOS project, and a few things needed fixing to make it
behave on Linux. These are worth writing down:

- **Date encoding.** Older Linux Foundation builds crash when `JSONEncoder` uses
  the `.iso8601` date strategy. It works on Swift 6, so the progress file uses
  `.iso8601` again, but it is the kind of thing that silently takes down a Linux
  build that works fine on macOS.
- **`swift test` and `libIndexStore`.** SwiftPM loads `libIndexStore.so` to
  assemble the test bundle. Some Linux Swift toolchains do not ship that library,
  and then `swift test` fails before it runs a single test even though
  `swift build` is fine. The official swift.org toolchains include it, which is
  why the prerequisites point there.
- **Swift 6 strict concurrency.** Moving to the Swift 6 language mode flagged the
  watch loop, which used a background input thread and a `Timer`. It is now one
  synchronous loop that polls the keyboard with a short timeout and compares file
  modification times, so there is no shared mutable state to make safe.

## Credits

- [Swiftlings](https://github.com/tornikegomareli/swiftlings) by Tornike
  Gomareli: the original Swift runner and exercises this is built on (MIT).
- [Rustlings](https://github.com/rust-lang/rustlings): the Rust project that
  started the idea (MIT).

## License

MIT. See [LICENSE](LICENSE).
