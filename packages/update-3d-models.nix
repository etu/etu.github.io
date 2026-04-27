{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "update-3d-models";
  runtimeInputs = [
    pkgs.curl
    pkgs.jq
    pkgs.gnutar
  ];
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
    dest="''${root}/static/3d-models"
    old_meta="''${dest}/metadata.json"
    new_meta="''${tmpdir}/metadata.json"

    mkdir -p "''${dest}"

    # Build lookup of old sourceHashes
    declare -A old_hashes
    if [[ -f "''${old_meta}" ]]; then
      while IFS=$'\t' read -r name hash; do
        old_hashes[''${name}]=''${hash}
      done < <(jq -r '.[] | [.name, .sourceHash] | @tsv' "''${old_meta}")
    fi

    # Copy only files whose source changed
    declare -A new_names
    while IFS=$'\t' read -r name hash; do
      new_names[''${name}]=1
      if [[ "''${old_hashes[''${name}]:-}" == "''${hash}" ]]; then
        echo "skip ''${name} (source unchanged)"
      else
        echo "copy ''${name} (source changed)"
        for ext in 3mf glb; do
          src="''${tmpdir}/models/''${name}.''${ext}"
          [[ -f "''${src}" ]] && cp "''${src}" "''${dest}/''${name}.''${ext}"
        done
      fi
    done < <(jq -r '.[] | [.name, .sourceHash] | @tsv' "''${new_meta}")

    # Remove files for models no longer in the release
    for name in "''${!old_hashes[@]}"; do
      if [[ -z "''${new_names[''${name}]:-}" ]]; then
        echo "remove ''${name} (no longer in release)"
        rm -f "''${dest}/''${name}.3mf" "''${dest}/''${name}.glb"
      fi
    done

    cp "''${new_meta}" "''${old_meta}"
    chmod -R u+w "''${dest}/"

    echo "Done! Updated to release: ''${tag}"
  '';
}
