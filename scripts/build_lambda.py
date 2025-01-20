import os
import shutil
import subprocess

def build_lambda_package():
    # Create a temporary build directory
    build_dir = "build"
    if os.path.exists(build_dir):
        shutil.rmtree(build_dir)
    os.makedirs(build_dir)

    # Export dependencies using poetry
    subprocess.run([
        "poetry", 
        "export", 
        "-f", "requirements.txt", 
        "--without-hashes", 
        "-o", f"{build_dir}/requirements.txt"
    ])

    # Install dependencies into the build directory
    subprocess.run([
        "pip", 
        "install", 
        "-r", f"{build_dir}/requirements.txt", 
        "-t", build_dir
    ])

    # Copy your application code
    shutil.copytree("src", f"{build_dir}/src")

    # Create deployment zip
    shutil.make_archive("lambda_function", "zip", build_dir)

if __name__ == "__main__":
    build_lambda_package()
