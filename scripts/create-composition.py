import requests
import argparse
import json
import os

# Initialize argument parser
parser = argparse.ArgumentParser(description='Send data to DRF endpoint.')
parser.add_argument('filepath', type=str, help='Filepath containing data to send.')

# Parse command-line arguments
args = parser.parse_args()
filename = os.path.basename(args.filepath)

# Read data from file
with open(f'/workspace/logs/parameters/{filename}', 'r') as f:
    parameters = json.load(f)

folder_name = filename.strip('.json')
folder_path = f"/workspace/stable-diffusion-webui/outputs/img2img-images/{folder_name}"

if os.path.isdir(folder_path):
    print(f"The folder '{folder_path}' exists.")
    action_type = 'img2img'
else:
    print(f"The folder '{folder_path}' does not exist.")
    action_type = 'txt2img'

# Define the URL of the DRF endpoint you want to send data to
url = 'http://django:8000/django/api/compositions/'

# Define the data you want to send as a dictionary (replace with your data)
data_to_send = {
    "name": filename.strip('.json'),
    "replacements": "",
    "parameters": parameters,
    "action_type": action_type,
    "description": ""
}

print(data_to_send)

# Make a POST request to the DRF endpoint with the data
headers = {'Authorization': 'Token faa8ac6ea11a1278e63c7da4c54641f38a8022c8'}
response = requests.post(url, json=data_to_send, headers=headers)

# Check the response status code and content
if response.status_code == 201:  # Assuming 201 indicates a successful POST request
    print('Data sent successfully!')
    print('Response Content:', response.content.decode('utf-8'))  # Decode the response content if needed
else:
    print('Failed to send data. Status code:', response.status_code)
    print('Response Content:', response.content.decode('utf-8'))  # Decode the response content if needed
