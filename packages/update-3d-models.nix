{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "update-3d-models";
  runtimeInputs = [pkgs.curl pkgs.jq pkgs.gnutar];
  text = ''
    root="$(git rev-parse --show-toplevel)"

    echo "Fetching latest 3d-models release..."
    tag=$(curl -sf "https://api.github.com/repos/etu/3d-models/releases/latest" | jq -r '.tag_name')
    url="https://github.com/etu/3d-models/releases/download/''${tag}/3d-models.tar.gz"
    echo "Latest release: ''${tag}"

    echo "Downloading release..."
    tmpdir=$(mktemp -d)
    trap 'chmod -R u+w "''${tmpdir}"; rm -rf "''${tmpdir}"' EXIT

    curl -sL "''${url}" | tar -xz -C "''${tmpdir}" --strip-components=1

    echo "Generating 3d-models page..."
    model3d=$(jq -c '[.[] | {
      title: .title,
      description: .description,
      license: {name: .license.spdxId, url: .license.url},
      homepage: .homepage,
      files: [{
        name: (.name + ".3mf"),
        modelFile: ("/3d-models/" + .name + ".3mf"),
        modelViewer: ("/3d-models/" + .name + ".glb")
      }]
    }]' "''${tmpdir}/metadata.json")

    cat > "''${root}/content/3d-models.md" <<EOF
    ---
    title: ~elis/3d-models/
    type: 3d-models
    model3d: ''${model3d}
    ---
    This is an overview of different 3D models that I have created.
    EOF

    echo "Copying model files..."
    rm -rf "''${root}/static/3d-models"
    mkdir -p "''${root}/static/3d-models"
    cp "''${tmpdir}"/models/*.3mf "''${tmpdir}"/models/*.glb "''${root}/static/3d-models/"
    chmod -R u+w "''${root}/static/3d-models/"

    echo "Done! Updated to release: ''${tag}"
  '';
}
