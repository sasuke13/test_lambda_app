import os
import shutil
import subprocess
import sys

def build_lambda_package():
    # Create a temporary build directory
    build_dir = "build"
    if os.path.exists(build_dir):
        shutil.rmtree(build_dir)
    os.makedirs(build_dir)

    # Get the virtual environment path
    result = subprocess.run(
        ["poetry", "env", "info", "--path"],
        capture_output=True,
        text=True,
        check=True
    )
    venv_path = result.stdout.strip()
    site_packages = os.path.join(venv_path, "lib", f"python{sys.version_info.major}.{sys.version_info.minor}", "site-packages")

    # Copy dependencies directly to build directory (not in site-packages subdirectory)
    for item in os.listdir(site_packages):
        source = os.path.join(site_packages, item)
        destination = os.path.join(build_dir, item)
        if os.path.isdir(source):
            shutil.copytree(source, destination)
        else:
            shutil.copy2(source, destination)

    # Copy your application code
    shutil.copytree("src", os.path.join(build_dir, "src"))

    # Create deployment zip
    shutil.make_archive("lambda_function", "zip", build_dir)

if __name__ == "__main__":
    build_lambda_package()
