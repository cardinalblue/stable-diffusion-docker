#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

echo "Container is running"

# Sync venv to workspace to support Network volumes
echo "Syncing venv to workspace, please wait..."
rsync -au /venv/ /workspace/venv/
rm -rf /venv

# Sync Web UI to workspace to support Network volumes
echo "Syncing Stable Diffusion Web UI to workspace, please wait..."
rsync -au /stable-diffusion-webui/ /workspace/stable-diffusion-webui/
rm -rf /stable-diffusion-webui

# Fix the venvs to make them work from /workspace
echo "Fixing Stable Diffusion Web UI venv..."
/fix_venv.sh /venv /workspace/venv

# Link models and VAE if they are not already linked
if [[ ! -L /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0.safetensors ]]; then
    ln -s /sd-models/sd_xl_base_1.0.safetensors /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0.safetensors
fi

if [[ ! -L /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_refiner_1.0.safetensors ]]; then
    ln -s /sd-models/sd_xl_refiner_1.0.safetensors /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_refiner_1.0.safetensors
fi

if [[ ! -L /workspace/stable-diffusion-webui/models/VAE/sdxl_vae.safetensors ]]; then
    ln -s /sd-models/sdxl_vae.safetensors /workspace/stable-diffusion-webui/models/VAE/sdxl_vae.safetensors
fi

# Configure accelerate
echo "Configuring accelerate..."
mkdir -p /root/.cache/huggingface/accelerate
mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

# Create logs directory
mkdir -p /workspace/logs

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the applications will not be started automatically"
    echo "You can launch them manually using the launcher scripts:"
    echo ""
    echo "   Stable Diffusion Web UI:"
    echo "   ---------------------------------------------"
    echo "   /start_a1111.sh"
else
    /start_a1111.sh
fi

if [ ${ENABLE_TENSORBOARD} ];
then
    /start_tensorboard.sh
fi

echo "Copying existing models..."
cp /instruments_downloaded/lora/* /workspace/stable-diffusion-webui/models/Lora/
cp /instruments_downloaded/stable-diffusion/* /workspace/stable-diffusion-webui/models/Stable-diffusion/

echo "Starting watchers..."
cd /
python ./watch-dirs.py > /workspace/logs/watch-dir.log 2>&1 &
nohup ./watcher.sh > /workspace/logs/watcher.log 2>&1 &
nohup ./sd-logs-watcher.sh > /workspace/logs/sd-logs-watcher.log 2>&1 &

echo "All services have been started"
