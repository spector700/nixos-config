{
  imports = [
    # nix fmt
    ./fmt.nix
    # pre-commit checks that run on 'nix flake check'
    ./pre-commit-hooks.nix
    # devShell
    ./shell.nix
  ];
}
