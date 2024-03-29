with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    gleam
    erlang
    rebar3
  ];
}