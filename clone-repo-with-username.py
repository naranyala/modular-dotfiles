import os
import re
import subprocess
import sys
from pathlib import Path

def clone_repo(repo_url, target_path="."):
    # Define patterns for GitHub, GitLab, and Codeberg URLs
    # Support both HTTPS and SSH-style URLs
    patterns = [
        # HTTPS GitHub URLs
        (r"(?:https?://)?github\.com/([^/]+)/([^/]+)(?:\.git)?$", "GitHub HTTPS"),
        # SSH GitHub URLs
        (r"git@github\.com:([^/]+)/([^/]+)(?:\.git)?$", "GitHub SSH"),
        
        # HTTPS GitLab URLs (with optional subdomains)
        (r"(?:https?://)?(?:[\w-]+\.)?gitlab\.com/([^/]+)/([^/]+)(?:\.git)?$", "GitLab HTTPS"),
        # SSH GitLab URLs (with optional subdomains)
        (r"git@(?:[\w-]+\.)?gitlab\.com:([^/]+)/([^/]+)(?:\.git)?$", "GitLab SSH"),
        
        # HTTPS GitLab Subdomain URLs
        (r"(?:https?://)?(?:[\w-]+\.)?gitlab\.[^/]+/([^/]+)/([^/]+)(?:\.git)?$", "GitLab Subdomain HTTPS"),
        # SSH GitLab Subdomain URLs
        (r"git@(?:[\w-]+\.)?gitlab\.[^/]+:([^/]+)/([^/]+)(?:\.git)?$", "GitLab Subdomain SSH"),
        
        # HTTPS Codeberg URLs
        (r"(?:https?://)?codeberg\.org/([^/]+)/([^/]+)(?:\.git)?$", "Codeberg HTTPS"),
        # SSH Codeberg URLs
        (r"git@codeberg\.org:([^/]+)/([^/]+)(?:\.git)?$", "Codeberg SSH")
    ]
    
    # Try to match the repo_url with the patterns
    for pattern, platform in patterns:
        match = re.match(pattern, repo_url)
        if match:
            username, repo_name = match.groups()
            new_dir_name = f"{username}-{repo_name}"
            final_dir = Path(target_path) / new_dir_name
            # Perform a shallow clone
            try:
                subprocess.run(["git", "clone", "--depth", "1", repo_url, str(final_dir)], check=True)
                print(f"Cloned {platform} repository into {final_dir}")
                return
            except subprocess.CalledProcessError:
                print(f"Error: Failed to clone {platform} repository.")
                sys.exit(1)
    # If no match found, show error
    print("Error: Invalid repository URL.")
    sys.exit(1)

if __name__ == "__main__":
    # Example usage
    if len(sys.argv) < 2:
        print("Usage: python clone_repo.py <repo_url> [target_path]")
        sys.exit(1)
    
    repo_url = sys.argv[1]
    target_path = sys.argv[2] if len(sys.argv) > 2 else "."
    clone_repo(repo_url, target_path)

# example-usage 
# HTTPS URLs
# python clone_repo.py https://github.com/octocat/Hello-World.git
# python clone_repo.py https://gitlab.com/octocat/Hello-World.git
# python clone_repo.py https://gitlab.gnome.org/octocat/Hello-World.git
# python clone_repo.py https://codeberg.org/octocat/Hello-World.git

# SSH URLs
# python clone_repo.py git@github.com:octocat/Hello-World.git
# python clone_repo.py git@gitlab.com:octocat/Hello-World.git
# python clone_repo.py git@gitlab.gnome.org:octocat/Hello-World.git
# python clone_repo.py git@codeberg.org:octocat/Hello-World.git
