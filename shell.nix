{ pkgs ? import <nixpkgs> {} }: with pkgs;

mkShell {
    buildInputs = [
        nodejs-16_x
        yarn
    ];

    shellHook = ''
        export REACH_CONNECTOR_MODE=ETH-devnet
        export PATH=$PWD/node_modules/.bin:$PATH
    '';
}
