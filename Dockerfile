# Stage 1: Base
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 as base

ARG WEBUI_VERSION=v1.6.0
ARG DREAMBOOTH_COMMIT=cf086c536b141fc522ff11f6cffc8b7b12da04b9

ENV WEBUI_VERSION=${WEBUI_VERSION}
ENV DREAMBOOTH_COMMIT=${DREAMBOOTH_COMMIT}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/London \
    PYTHONUNBUFFERED=1 \
    SHELL=/bin/bash

# Create workspace working directory
WORKDIR /

# Install Ubuntu packages
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
        build-essential \
        software-properties-common \
        python3.10-venv \
        python3-pip \
        python3-tk \
        python3-dev \
        nodejs \
        npm \
        bash \
        dos2unix \
        git \
        git-lfs \
        ncdu \
        nginx \
        net-tools \
        inetutils-ping \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        zip \
        unzip \
        p7zip-full \
        htop \
        pkg-config \
        plocate \
        inotify-tools \
        libcairo2-dev \
        libgoogle-perftools4 \
        libtcmalloc-minimal4 \
        apt-transport-https \
        bsdmainutils \
        jq \
        ca-certificates && \
    update-ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Install Torch, xformers and tensorrt
RUN pip3 install --no-cache-dir torch==2.0.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    pip3 install --no-cache-dir xformers==0.0.22 tensorrt

# Stage 2: Install applications
FROM base as setup

RUN mkdir -p /sd-models

# Add SD models
# These need to already have been downloaded:
#   wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.safetensors
#   wget https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors
COPY preloaded/v1-5-pruned.safetensors /sd-models/v1-5-pruned.safetensors
COPY preloaded/vae-ft-mse-840000-ema-pruned.safetensors /sd-models/vae-ft-mse-840000-ema-pruned.safetensors

# Add SDXL models and VAE
# These need to already have been downloaded:
#   wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
#   wget https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
#   wget https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors
COPY preloaded/sd_xl_base_1.0.safetensors /sd-models/sd_xl_base_1.0.safetensors
COPY preloaded/sd_xl_refiner_1.0.safetensors /sd-models/sd_xl_refiner_1.0.safetensors
COPY preloaded/sdxl_vae.safetensors /sd-models/sdxl_vae.safetensors

# Clone the git repo of the Stable Diffusion Web UI by Automatic1111
# and set version
WORKDIR /
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
    cd /stable-diffusion-webui && \
    git fetch --all && \
    git checkout tags/${WEBUI_VERSION}

WORKDIR /stable-diffusion-webui
RUN python3 -m venv --system-site-packages /venv && \
    source /venv/bin/activate && \
    pip install --no-cache-dir torch==2.0.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    pip install --no-cache-dir xformers && \
    deactivate

# Install the dependencies for the Automatic1111 Stable Diffusion Web UI
COPY a1111/requirements.txt a1111/requirements_versions.txt ./
COPY a1111/cache-sd-model.py a1111/install-automatic.py ./
RUN source /venv/bin/activate && \
    python -m install-automatic --skip-torch-cuda-test && \
    deactivate

# Cache the Stable Diffusion Models
# SDXL models result in OOM kills with 8GB system memory, probably need 12GB+ to cache these
RUN source /venv/bin/activate && \
    python3 cache-sd-model.py --use-cpu=all --ckpt /sd-models/sd_xl_base_1.0.safetensors && \
    python3 cache-sd-model.py --use-cpu=all --ckpt /sd-models/sd_xl_refiner_1.0.safetensors && \
    deactivate

# Clone the Automatic1111 Extensions
RUN git clone https://github.com/d8ahazard/sd_dreambooth_extension.git extensions/sd_dreambooth_extension && \
    git clone --depth=1 https://github.com/deforum-art/sd-webui-deforum.git extensions/deforum && \
    git clone --depth=1 https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet && \
    git clone --depth=1 https://github.com/ashleykleynhans/a1111-sd-webui-locon.git extensions/a1111-sd-webui-locon && \
    git clone --depth=1 https://github.com/ashleykleynhans/sd-webui-roop.git extensions/sd-webui-roop && \
    git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing && \
    git clone --depth=1 https://github.com/Uminosachi/sd-webui-inpaint-anything.git extensions/inpaint-anything && \
    git clone --depth=1 https://github.com/Bing-su/adetailer.git extensions/adetailer && \
    git clone --depth=1 https://github.com/civitai/sd_civitai_extension.git extensions/sd_civitai_extension && \
    git clone --depth=1 https://github.com/huchenlei/sd-webui-api-payload-display extensions/sd-webui-api-payload-display && \
    git clone --depth=1 https://github.com/djbielejeski/a-person-mask-generator.git extensions/a-person-mask-generator

# Install dependencies for Deforum, ControlNet, roop, and After Detailer extensions
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/deforum && \
    pip3 install -r requirements.txt
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/sd-webui-controlnet && \
    pip3 install -r requirements.txt
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/sd-webui-roop && \
    pip3 install -r requirements.txt
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/infinite-image-browsing && \
    pip3 install -r requirements.txt
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/adetailer && \
    python -m install
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/sd_civitai_extension && \
    pip3 install -r requirements.txt
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/a-person-mask-generator && \
    pip3 install -r requirements.txt && \
    deactivate

# Install dependencies for inpaint anything extension
RUN source /venv/bin/activate && \
    pip3 install segment_anything lama_cleaner && \
    deactivate

# Set Dreambooth extension version
WORKDIR /stable-diffusion-webui/extensions/sd_dreambooth_extension
RUN git checkout main && \
    git reset ${DREAMBOOTH_COMMIT} --hard

# Install the dependencies for the Dreambooth extension
WORKDIR /stable-diffusion-webui
COPY a1111/requirements_dreambooth.txt ./requirements.txt
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/sd_dreambooth_extension && \
    pip3 install -r requirements.txt && \
    deactivate

# Add inswapper model for the roop extension
RUN mkdir -p /workspace/stable-diffusion-webui/models/roop
COPY preloaded/inswapper_128.onnx /workspace/stable-diffusion-webui/models/roop/inswapper_128.onnx

# Fix Tensorboard
RUN source /venv/bin/activate && \
    pip3 uninstall -y tensorboard tb-nightly && \
    pip3 install tensorboard tensorflow && \
    pip3 cache purge && \
    deactivate

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Install croc
RUN curl https://getcroc.schollz.com | bash

# Install CivitAI Model Downloader
RUN git clone --depth=1 https://github.com/ashleykleynhans/civitai-downloader.git && \
    mv civitai-downloader/ /usr/local/bin/download-model && \
    chmod +x /usr/local/bin/download-model

# Copy Stable Diffusion Web UI config files
COPY a1111/relauncher.py a1111/webui-user.sh a1111/config.json a1111/ui-config.json /stable-diffusion-webui/

# ADD SDXL styles.csv
ADD https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv /stable-diffusion-webui/styles.csv

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/502.html /usr/share/nginx/html/502.html
COPY nginx/README.md /usr/share/nginx/html/README.md

WORKDIR /

# NVIDIA Container Toolkit
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
RUN dpkg -i cuda-keyring_1.0-1_all.deb
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends cuda-11-8

# setup your paths
RUN echo 'export PATH=/usr/local/cuda-11.8/bin:$PATH' >> ~/.bashrc
RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

# Copy ControlNet .PTH files
COPY /preloaded/extensions/sd-webui-controlnet/models /workspace/stable-diffusion-webui/extensions/sd-webui-controlnet/models

# Copy the scripts
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]