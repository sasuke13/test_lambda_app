import os
import shutil
import subprocess
import sys

def build_layer():
    # Create layer directory structure
    layer_dir = "layer"
    python_path = os.path.join(layer_dir, "python", "lib", "python3.11", "site-packages")
    
    if os.path.exists(layer_dir):
        shutil.rmtree(layer_dir)
    os.makedirs(python_path)

    # Get the virtual environment path
    result = subprocess.run(
        ["poetry", "env", "info", "--path"],
        capture_output=True,
        text=True,
        check=True
    )
    venv_path = result.stdout.strip()
    site_packages = os.path.join(venv_path, "lib", f"python{sys.version_info.major}.{sys.version_info.minor}", "site-packages")

    # Copy dependencies to layer
    for item in os.listdir(site_packages):
        source = os.path.join(site_packages, item)
        destination = os.path.join(python_path, item)
        if os.path.isdir(source):
            shutil.copytree(source, destination)
        else:
            shutil.copy2(source, destination)

    # Create layer zip
    shutil.make_archive("lambda_layer", "zip", layer_dir)

if __name__ == "__main__":
    build_layer()
