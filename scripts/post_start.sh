#!/bin/bash

# Temporary file
TMPFILE=$(mktemp)

# Ensure the temporary file gets deleted upon exit
trap "rm -f $TMPFILE" EXIT

# Write existing crontab entries to temporary file
crontab -l > "$TMPFILE"

# Add new cron job to temporary file
echo "* * * * * rsync -a /workspace/ComfyUI/models/checkpoints/ /instruments_downloaded/stable-diffusion" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/clip/ /instruments_downloaded/clip" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/clip_vision/ /instruments_downloaded/clip_vision" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/configs/ /instruments_downloaded/configs" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/controlnet/ /instruments_downloaded/controlnet" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/custom-nodes/ /instruments_downloaded/custom-nodes" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/diffusers/ /instruments_downloaded/diffusers" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/embeddings/ /instruments_downloaded/embeddings" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/gligen/ /instruments_downloaded/gligen" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/hypernetworks/ /instruments_downloaded/hypernetworks" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/loras/ /instruments_downloaded/lora" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/style_models/ /instruments_downloaded/style_models" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/unet/ /instruments_downloaded/unet" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/upscale_models/ /instruments_downloaded/upscale_models" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/vae/ /instruments_downloaded/vae" >> "$TMPFILE"
echo "* * * * * rsync -a /workspace/ComfyUI/models/vae_approx/ /instruments_downloaded/vae_approx" >> "$TMPFILE"

# Load the updated crontab file
crontab "$TMPFILE"