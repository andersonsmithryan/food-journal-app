#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "features" / "feature-config.yml"
ID_MAP_PATH = ROOT / "features" / "feature-id-map.json"

SCENARIO_RE = re.compile(r"^\s*Scenario:\s*(.+?)\s*$")
TAG_RE = re.compile(r"^\s*@([A-Z]+-\d+)\s*$")
DEPRECATED_RE = re.compile(r"^\s*@deprecated\s*$", re.IGNORECASE)


def load_feature_config(path: Path) -> dict:
    config = {}
    current = None
    for raw in path.read_text().splitlines():
        line = raw.rstrip()
        if not line or line.strip().startswith("#"):
            continue
        if line.startswith("  ") and line.endswith(":") and not line.strip().startswith("prefix"):
            current = line.strip().rstrip(":")
            config[current] = {}
            continue
        if current and "prefix:" in line:
            _, value = line.split("prefix:", 1)
            config[current]["prefix"] = value.strip()
    return config


def next_id(prefix: str, existing: set) -> str:
    nums = [
        int(match.group(1))
        for tag in existing
        if (match := re.match(rf"{re.escape(prefix)}-(\d+)$", tag))
    ]
    next_num = max(nums or [0]) + 1
    return f"{prefix}-{next_num:03d}"


def sync_feature(feature_path: Path, prefix: str, id_map: dict) -> tuple[bool, list[str], list[str]]:
    lines = feature_path.read_text().splitlines()
    updated = []
    existing_ids = {tag for tags in id_map.values() for tag in tags.values()}
    changed = False
    duplicates = []
    deprecated_titles = []
    pending_tags = []
    seen_titles = set()

    for line in lines:
        if DEPRECATED_RE.match(line):
            pending_tags.append("deprecated")
            updated.append(line)
            continue
        tag_match = TAG_RE.match(line)
        if tag_match:
            pending_tags.append(tag_match.group(1))
            updated.append(line)
            continue

        scenario_match = SCENARIO_RE.match(line)
        if scenario_match:
            title = scenario_match.group(1)
            if title in seen_titles:
                duplicates.append(title)
            seen_titles.add(title)
            scenario_ids = {tag for tag in pending_tags if tag.startswith(prefix)}
            is_deprecated = "deprecated" in pending_tags
            if not scenario_ids:
                new_id = id_map.get(title)
                if not new_id:
                    new_id = next_id(prefix, existing_ids)
                updated.append(f"  @{new_id}")
                id_map[title] = new_id
                existing_ids.add(new_id)
                changed = True
            if is_deprecated:
                deprecated_titles.append(title)
            updated.append(line)
            pending_tags = []
            continue

        pending_tags = []
        updated.append(line)

    if changed:
        feature_path.write_text("\n".join(updated) + "\n")
    return changed, duplicates, deprecated_titles


def main() -> None:
    config = load_feature_config(CONFIG_PATH)
    id_map = json.loads(ID_MAP_PATH.read_text())
    changed = False
    duplicate_titles = []
    deprecated_titles = []

    for feature_file, meta in config.items():
        prefix = meta.get("prefix")
        if not prefix:
            continue
        path = ROOT / "features" / feature_file
        if not path.exists():
            continue
        id_map.setdefault(feature_file, {})
        updated, duplicates, deprecated = sync_feature(path, prefix, id_map[feature_file])
        duplicate_titles.extend([f"{feature_file}: {title}" for title in duplicates])
        deprecated_titles.extend([f"{feature_file}: {title}" for title in deprecated])
        if updated:
            changed = True

    if changed:
        ID_MAP_PATH.write_text(json.dumps(id_map, indent=2) + "\n")

    if deprecated_titles:
        print("Deprecated scenarios:", *deprecated_titles, sep="\n  ")

    if duplicate_titles:
        print("Duplicate scenario titles detected:", *duplicate_titles, sep="\n  ")
        raise SystemExit(1)


if __name__ == "__main__":
    main()
