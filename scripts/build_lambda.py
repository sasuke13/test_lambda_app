import os
import shutil

def build_lambda_package():
    # Create a temporary build directory
    build_dir = "build"
    if os.path.exists(build_dir):
        shutil.rmtree(build_dir)
    os.makedirs(build_dir)

    # Copy only your application code
    shutil.copytree("src", os.path.join(build_dir, "src"))

    # Create deployment zip
    shutil.make_archive("lambda_function", "zip", build_dir)

if __name__ == "__main__":
    build_lambda_package()
