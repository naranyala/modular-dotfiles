import json
import requests
import sys
import os

def scan_models(base_url):
    print(f"Scanning models at {base_url}/models...")
    try:
        response = requests.get(f"{base_url}/models")
        response.raise_for_status()
        data = response.json()
        model_ids = [model['id'] for model in data.get('data', [])]
        return model_ids
    except Exception as e:
        print(f"Error scanning models: {e}")
        return None

def update_models_json(models_file, base_url, model_ids):
    try:
        if os.path.exists(models_file):
            with open(models_file, 'r') as f:
                config = json.load(f)
        else:
            config = {}
    except json.JSONDecodeError:
        print(f"Error: Failed to decode JSON from {models_file}.")
        return False

    if 'providers' not in config:
        config['providers'] = {}

    lm_studio_config = config['providers'].get('lm-studio', {})
    new_lm_studio_config = {
        "baseUrl": base_url,
        "api": lm_studio_config.get("api", "openai-completions"),
        "apiKey": lm_studio_config.get("apiKey", "lm-studio"),
        "models": [{"id": mid} for mid in model_ids]
    }
    config['providers']['lm-studio'] = new_lm_studio_config

    with open(models_file, 'w') as f:
        json.dump(config, f, indent=2)
    print(f"Updated {models_file} with {len(model_ids)} models from {base_url}.")
    return True

def update_settings_json(settings_file, provider, model_id):
    try:
        if os.path.exists(settings_file):
            with open(settings_file, 'r') as f:
                settings = json.load(f)
        else:
            settings = {}
    except json.JSONDecodeError:
        print(f"Error: Failed to decode JSON from {settings_file}.")
        return False

    settings['defaultProvider'] = provider
    settings['defaultModel'] = model_id

    with open(settings_file, 'w') as f:
        json.dump(settings, f, indent=2)
    print(f"Updated {settings_file} with default provider '{provider}' and model '{model_id}'.")
    return True

def main():
    # Defaults
    base_url = os.environ.get("LMSTUDIO_URL", "http://127.0.0.1:1234/v1")
    set_default = True  # always set first model as default

    # Anchor paths to ~/.pi/agent
    agent_dir = os.path.expanduser("~/.pi/agent")
    os.makedirs(agent_dir, exist_ok=True)
    models_file = os.path.join(agent_dir, "models.json")
    settings_file = os.path.join(agent_dir, "settings.json")

    base_url = base_url.rstrip('/')
    model_ids = scan_models(base_url)
    if model_ids:
        if update_models_json(models_file, base_url, model_ids):
            if set_default:
                update_settings_json(settings_file, 'lm-studio', model_ids[0])
    else:
        print("No models found or error occurred.")
        sys.exit(1)

if __name__ == "__main__":
    main()

