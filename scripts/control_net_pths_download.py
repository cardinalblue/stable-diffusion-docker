import os
import wget


def download_file(url, filepath):
    wget.download(url, filepath)


# Base URL for the files
base_url = "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/"


# List of file names to download
file_names = [
    "control_v11e_sd15_ip2p.pth",
    "control_v11e_sd15_shuffle.pth",
    "control_v11f1e_sd15_tile.pth",
    "control_v11f1p_sd15_depth.pth",
    "control_v11p_sd15_canny.pth",
    "control_v11p_sd15_inpaint.pth",
    "control_v11p_sd15_lineart.pth",
    "control_v11p_sd15_mlsd.pth",
    "control_v11p_sd15_normalbae.pth",
    "control_v11p_sd15_openpose.pth",
    "control_v11p_sd15_scribble.pth",
    "control_v11p_sd15_seg.pth",
    "control_v11p_sd15_softedge.pth",
    "control_v11p_sd15s2_lineart_anime.pth"
]


directory = './preloaded/extensions/sd-webui-controlnet/models/'

# Create a directory to store the files
os.makedirs(directory, exist_ok=True)

# Download each file
for file_name in file_names:
    file_url = base_url + file_name
    filepath = os.path.join(directory, file_name)
    if not os.path.exists(filepath):
        download_file(file_url, filepath)
    print(f" Downloaded {file_name}")
