# CW Node Helper

CoreWeave DCT terminal companion — Jira + NetBox + Grafana queue browser.
Single-file Python CLI for data center operations ticket management.

## Quick Reference

```bash
# Run
source load_env.sh && python3 get_node_context.py

# Run (if installed as package)
source load_env.sh && cwhelper

# Test
python3 test_integrity.py
python3 test_map.py

# Install as editable package
pip install -e .
```

## Tech Stack

- **Language:** Python 3.10+
- **Dependencies:** `requests>=2.28.0` (only runtime dep)
- **Optional:** `openpyxl` (Excel cutsheet processing only)
- **APIs:** Jira Cloud, NetBox, Grafana (URL generation only)

## Project Structure

```
get_node_context.py      # Main app (monolith, ~7k lines)
test_integrity.py        # Unit tests (74 tests, all API calls mocked)
test_map.py              # Rack visualization math tests
pyproject.toml           # Package config, entry point: cwhelper
requirements.txt         # requests>=2.28.0
load_env.sh              # Loads .env into shell
update.sh                # Self-updater script
.env                     # Credentials (gitignored, never commit)
.env.example             # Credential template
.cwhelper_state.json     # User state: bookmarks, recents (auto-created)
dh_layouts.json          # Data hall rack configs (auto-created)
ib_topology.json         # InfiniBand port mappings (pre-generated, read-only)
docs/                    # Documentation
site/                    # Visual docs website
source/                  # Reference Excel cutsheets (gitignored)
.github/workflows/       # CI (test on push) + release (tag → zip)
```

## Code Layout (get_node_context.py)

| Lines (approx) | Section |
|-----------------|---------|
| 1–140 | Constants, globals, ANSI colors, feature flags |
| 141–590 | Utilities, auth, Jira API (`_jira_get/post/put`) |
| 591–840 | NetBox API (`_netbox_get`, `_netbox_find_device`) |
| 841–1160 | Data extraction, JQL search, context building |
| 1161–1690 | Queue browser, history search, background watcher |
| 1691–2640 | Display, action panel, rack neighbors, bookmarks |
| 2641–2980 | Ticket detail hotkeys |
| 2981–3720 | Interactive menu (main loop) |
| 3721–4020 | Rack visualization (ASCII maps) |
| 4021–4650 | Output formats, CLI entry (`main()`) |

## Conventions

- **All functions are private** (`_function_name` prefix)
- **Constants:** `UPPER_CASE` (e.g., `JIRA_BASE_URL`, `CUSTOM_FIELDS`)
- **Context dict:** `ctx` — passed through functions with ticket/node data
- **Caching:** In-memory dicts with 60s TTL (`_issue_cache`, `_jql_cache`)
- **Error handling:** Graceful degradation — NetBox down = Jira-only mode
- **No exceptions to user** — all caught and printed as warnings
- **Env vars for config** — credentials via `JIRA_EMAIL`, `JIRA_API_TOKEN`, `NETBOX_API_URL`, `NETBOX_API_TOKEN`

## CLI Modes

1. **Interactive menu** — no args, TUI with hotkeys
2. **One-shot subcommands** — `queue`, `history`, `watch`, `weekend-assign`, or pass a ticket ID directly
3. **Common flags:** `--site`, `--status`, `--project`, `--json`, `--limit`

## Testing

- All tests mock API calls — no real Jira/NetBox requests
- CI runs on Python 3.9, 3.11, 3.13
- Run `python3 test_integrity.py` before any release

## Important Files to Never Commit

- `.env` / `.env.local` — credentials
- `.cwhelper_state.json` — personal state
- `source/` — large Excel binaries
