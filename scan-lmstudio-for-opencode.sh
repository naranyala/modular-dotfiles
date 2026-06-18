import json
import urllib.request
import urllib.error
import socket
import os
import re

CONFIG_PATH="/home/$(whoami)/.config/opencode/opencode.jsonc"
PORT_RANGE = range(1230, 1245)

def scan_lm_studios():
    found_studios = []
    for port in PORT_RANGE:
        url = f"http://localhost:{port}/v1/models"
        try:
            with urllib.request.urlopen(url, timeout=1) as response:
                if response.status == 200:
                    data = json.loads(response.read().decode())
                    models = data.get("data", [])
                    if models:
                        found_studios.append({
                            "port": port,
                            "models": {m["id"]: {"name": m["id"]} for m in models}
                        })
        except (urllib.error.URLError, json.JSONDecodeError, socket.timeout, ConnectionRefusedError):
            continue
    return found_studios

def load_jsonc(path):
    with open(path, 'r') as f:
        content = f.read()
    # A more robust way to remove comments without breaking URLs:
    # This regex matches // or /* */ but tries to avoid matching inside strings.
    # However, for simplicity in this script, we'll use a regex that requires
    # a space before // or it being at the start of a line.
    content = re.sub(r'(?<!:)\/\/.*', '', content)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    return json.loads(content)

def update_config(studios):
    if not studios:
        print("No LM Studio instances found.")
        return

    studio = studios[0]
    base_url = f"http://127.0.0.1:{studio['port']}/v1"

    try:
        config = load_jsonc(CONFIG_PATH)
    except Exception as e:
        print(f"Error loading config: {e}")
        return

    if "provider" not in config:
        config["provider"] = {}

    config["provider"]["lmstudio"] = {
        "npm": "@ai-sdk/openai-compatible",
        "name": "LM Studio (local)",
        "options": {
            "baseURL": base_url,
            "apiKey": "lm-studio"
        },
        "models": studio["models"]
    }

    try:
        with open(CONFIG_PATH, 'w') as f:
            json.dump(config, f, indent=2)
        print(f"Successfully updated {CONFIG_PATH}")
        print(f"Found LM Studio at port {studio['port']} with models: {list(studio['models'].keys())}")
    except Exception as e:
        print(f"Error writing config: {e}")

if __name__ == "__main__":
    print("Scanning for LM Studio instances...")
    studios = scan_lm_studios()
    update_config(studios)

