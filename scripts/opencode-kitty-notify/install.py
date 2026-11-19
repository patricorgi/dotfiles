"""Install this package into the current user's OpenCode V2 CLI configuration."""

import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import uuid


def install():
    executable = shutil.which("opencode") or str(Path.home() / ".opencode/bin/opencode")
    version = subprocess.check_output([executable, "--version"], text=True).strip()
    match = re.search(r"(?:v|\s)(\d+)\.(\d+)\.(\d+)", version)
    if not match or tuple(map(int, match.groups())) < (2, 2, 7) or match[1] != "2":
        raise RuntimeError("This plugin requires OpenCode V2 >= 2.2.7; found " + version)
    config_dir = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "opencode"
    config_path = config_dir / "cli.json"
    source = Path(__file__).resolve().parent
    target = config_dir / "plugins/kitty-session-notify"
    if target.exists() and any(target.iterdir()):
        manifest = target / "package.json"
        if not manifest.exists() or json.loads(manifest.read_text()).get("name") != "opencode-kitty-session-notify":
            raise RuntimeError("Refusing to overwrite an unrelated plugin directory: " + str(target))
    config_dir.mkdir(parents=True, exist_ok=True)
    original = config_path.read_text() if config_path.exists() else None
    config = json.loads(original) if original else {"$schema": "https://opencode.ai/v2/cli.json"}
    plugins = config.setdefault("plugins", [])
    if not isinstance(plugins, list):
        raise ValueError("Existing plugins configuration is not an array")
    runtime_files = ("package.json", "core.js", "settings.js", "tui.js")
    revision = hashlib.sha256(b"".join((source / name).read_bytes() for name in runtime_files)).hexdigest()[:16]
    index = next((i for i, entry in enumerate(plugins)
                  if (entry.get("package") if isinstance(entry, dict) else entry) == str(target)), None)
    if index is None:
        plugins.append({"package": str(target), "options": {"revision": revision}})
    else:
        if isinstance(plugins[index], str):
            plugins[index] = {"package": str(target)}
        options = plugins[index].setdefault("options", {})
        if not isinstance(options, dict):
            raise ValueError("Existing plugin options are not an object")
        options["revision"] = revision
    plugins[:] = [entry for entry in plugins if entry != "-opencode.notifications"]
    plugins.append("-opencode.notifications")
    attention = config.setdefault("attention", {})
    attention["notifications"] = True
    attention.setdefault("sound", False)
    target.mkdir(parents=True, exist_ok=True)
    for filename in (*runtime_files, "README.md"):
        incoming = (source / filename).read_bytes()
        destination = target / filename
        if destination.exists() and destination.read_bytes() != incoming:
            shutil.copy2(destination, destination.with_name(filename + ".backup-" + uuid.uuid4().hex[:12]))
        if not destination.exists() or destination.read_bytes() != incoming:
            fd, staging = tempfile.mkstemp(prefix=".notify-", dir=str(target))
            with os.fdopen(fd, "wb") as stream:
                stream.write(incoming)
            os.replace(staging, destination)
    updated = json.dumps(config, indent=2) + "\n"
    if updated != original:
        if original is not None:
            backup = config_path.with_name("cli.json.before-kitty-notify-" + uuid.uuid4().hex[:12])
            shutil.copy2(config_path, backup)
            print("Config backup:", backup)
        fd, staging = tempfile.mkstemp(prefix=".cli-notify-", dir=str(config_dir))
        with os.fdopen(fd, "w") as stream:
            stream.write(updated)
        if config_path.exists() and config_path.read_text() != original:
            os.unlink(staging)
            raise RuntimeError("CLI config changed concurrently; not overwritten")
        os.replace(staging, config_path)
    print("Plugin installed:", target)
    print("CLI configuration:", config_path)


if __name__ == "__main__":
    install()
