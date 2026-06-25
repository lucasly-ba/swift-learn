{
  description = "Swift learning environment (swiftc 5.10.1, superset of 5.9)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Foundation / Dispatch ship as separate packages on Linux and their
        # shared libs (libFoundation.so, libdispatch.so) must be on the runtime
        # library path, otherwise even SwiftPM's manifest compile fails.
        swiftLibs = [
          pkgs.swiftPackages.Foundation
          pkgs.swiftPackages.Dispatch
          # XCTest is a separate package on Linux too; needed for `swift test`.
          pkgs.swiftPackages.XCTest
        ];

        # `swift file.swift` (interpret mode) can't import Foundation in nixpkgs.
        # `srun file.swift` compiles + runs instead, which works with Foundation.
        srun = pkgs.writeShellScriptBin "srun" ''
          set -euo pipefail
          if [ $# -lt 1 ]; then echo "usage: srun <file.swift> [args...]" >&2; exit 2; fi
          src="$1"; shift
          out="$(mktemp -d)/$(basename "''${src%.swift}")"
          ${pkgs.swift}/bin/swiftc "$src" -o "$out"
          exec "$out" "$@"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          name = "tutoswift";

          packages = with pkgs; [
            swift          # swiftc compiler + REPL
            swiftpm        # Swift Package Manager (swift build / run / test)
            swift-format   # formatter
            # Native toolchain SwiftPM/Foundation need on Linux:
            binutils       # provides `ar`, `ld` (SwiftPM requires `ar`)
            clang          # C/C++ compiler used for linking & C interop
            srun           # `srun file.swift` = compile + run (Foundation-safe)
            python3        # runs the swiftlings exercise checker
          ] ++ swiftLibs;

          # Make the Foundation/Dispatch shared objects discoverable at runtime.
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (swiftLibs ++ [
            "${pkgs.swiftPackages.Foundation}/lib/swift/linux"
            "${pkgs.swiftPackages.XCTest}/lib/swift/linux"
          ]);

          # The nixpkgs swift wrapper appends these to every swiftc *compile*,
          # so `swiftc foo.swift` (and therefore `srun`) can `import Foundation`
          # without you passing -I by hand. SwiftPM finds them on its own.
          # (Interpret mode, `swift foo.swift`, still won't see Foundation.)
          NIX_SWIFTFLAGS_COMPILE =
            "-I ${pkgs.swiftPackages.Foundation}/lib/swift/linux "
            + "-I ${pkgs.swiftPackages.Dispatch}/lib/swift "
            + "-I ${pkgs.swiftPackages.XCTest}/lib/swift/linux";
          NIX_LDFLAGS =
            "-L ${pkgs.swiftPackages.Foundation}/lib/swift/linux "
            + "-L ${pkgs.swiftPackages.Dispatch}/lib "
            + "-L ${pkgs.swiftPackages.XCTest}/lib/swift/linux";

          shellHook = ''
            echo ""
            echo "  swift learning shell"
            swiftc --version | head -n1 | sed 's/^/  /'
            echo ""
            echo "  swift               start the REPL"
            echo "  srun file.swift     compile + run one file (use this for Foundation)"
            echo "  swiftc file.swift   compile to a binary"
            echo "  swift run           run a SwiftPM package (cd example)"
            echo "  swift-format ...    format your code"
            echo ""
            echo "  exercices:  python swiftlings.py        (watch)"
            echo "              python swiftlings.py list    (avancement)"
            echo "              python swiftlings.py hint    (un indice)"
            echo "  tuto: https://swift.crea-troyes.fr/"
            echo ""
          '';
        };
      });
}
