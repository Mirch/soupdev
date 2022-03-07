import os
import sys

# the folder that contains the lambda functions (one function per folder)
project_folder = next(iter(sys.argv[1:]))
build_target = "x86_64-unknown-linux-musl"
output_file_name = "bootstrap"

commands = []

commands.append("echo [BUILD] Installing musl-tools...")
commands.append("sudo apt install musl-tools")

commands.append("echo [BUILD] Building the Rust project...")
commands.append(f"cargo build --release --target {build_target}")

os.system("; ".join(commands))
commands.clear()

commands.append("echo [BUILD] Starting Rust functions building process...")
commands.append("mkdir bin")
function_folders = [name for name in os.listdir(project_folder)]
for function_folder in function_folders:
    commands.append(f"echo [BUILD] Creating {function_folder} output file...")
    
    # create the bootstrap file
    commands.append(f"mkdir bin/{function_folder}")
    commands.append(f"cp ./target/{build_target}/release/{function_folder} ./bin/{function_folder}/{output_file_name}")
    
    os.system("; ".join(commands))
    commands.clear()
    
    