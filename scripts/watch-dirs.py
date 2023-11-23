import os
import time
import shutil

def list_files_in_directory(directory):
    with os.scandir(directory) as entries:
        return {entry.name: entry.stat().st_size for entry in entries if entry.is_file()}

def compare_and_copy(src, dest, delay=5):

    os.makedirs(src, exist_ok=True)

    files_src = list_files_in_directory(src)
    files_dest = list_files_in_directory(dest)

    missing_in_dest = set(files_src.keys()) - set(files_dest.keys())
    for filename in missing_in_dest:
        src_path = os.path.join(src, filename)
        first_size_check = os.path.getsize(src_path)

        # Wait and then check the file size again
        time.sleep(delay)
        second_size_check = os.path.getsize(src_path)

        if first_size_check == second_size_check:
            dest_path = os.path.join(dest, filename)
            shutil.copy2(src_path, dest_path)
            print(f"Copied {filename} to {dest}")
        else:
            print(f"{filename} is still being written to.")

if __name__ == "__main__":
    directory_pairs = [
        ("/instruments_downloaded/lora", "/workspace/stable-diffusion-webui/models/Lora"),
        ("/instruments_downloaded/stable-diffusion", "/workspace/stable-diffusion-webui/models/Stable-diffusion"),
        ("/instruments_downloaded/controlnet", "/workspace/stable-diffusion-webui/models/ControlNet"),
        ("/instruments_downloaded/vae", "/workspace/stable-diffusion-webui/models/VAE"),
    ]

    print(f"Watching {len(directory_pairs)} directories")
    print(directory_pairs)
    while True:
        for src, dest in directory_pairs:
            try:
                compare_and_copy(src, dest)
            except:
                # we do not want the script to die if there is an error
                print(f"Failed to copy from {src} to {dest}")
        time.sleep(5)  # Sleep for 5 seconds before polling again
