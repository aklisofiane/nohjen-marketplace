# nohjen-marketplace

Nohjen's Claude Code plugin marketplace for skills, agents, commands, and hooks.

## Install

```bash
/plugin marketplace add aklisofiane/nohjen-marketplace
```

Then browse and install:

```bash
/plugin
```

## Plugins

### [feature-flow](plugins/feature-flow/README.md)

Takes a feature from an open question to shipped, documented code. You answer the decisions on HTML pages that open beside the chat.

```
feature-brainstorm → feature-spec → feature-implement → doc-generator
   options page       spec page      phases checked by    docs/ updated,
                                     spec-verifier,       spec closed
                                     report page
```

| Skill / agent | In one line |
|---|---|
| `feature-brainstorm` | 2-3 grounded options with a recommendation, or an umbrella plan for a big feature |
| `feature-spec` | Writes the chosen direction into `.specs/<slug>.md`, reviewed on a page |
| `feature-spec-audit` | Read-only check of an umbrella's sub-specs for contradictions and gaps |
| `feature-implement` | Builds a spec in this session or with a team of agents, and ends with a report page |
| `doc-generator` | Writes or updates `docs/` from the latest commit or named files |
| `bug-investigate` | Finds a bug's root cause read-only and offers 1-3 fixes before changing anything |
| `spec-verifier` (agent) | Gives a pass/fail verdict with proof that code matches a spec, and never edits |

See the [feature-flow README](plugins/feature-flow/README.md) for the full flow, the pages and the `.specs/` layout.

## Layout

```
nohjen-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace manifest (lists all plugins)
└── plugins/
    └── <plugin-name>/
        ├── .claude-plugin/
        │   └── plugin.json   # Plugin manifest
        ├── skills/           # Optional: skills
        ├── agents/           # Optional: subagents
        ├── commands/         # Optional: slash commands
        └── hooks/            # Optional: hooks
```

## Add a new plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json` with at least `{ "name": "<name>", "version": "0.1.0" }`.
2. Drop your `skills/`, `agents/`, `commands/`, or `hooks/` folders inside `plugins/<name>/`.
3. Register the plugin in `.claude-plugin/marketplace.json` under `plugins[]`:
   ```json
   {
     "name": "<name>",
     "source": "./plugins/<name>",
     "description": "What it does"
   }
   ```
4. Reload: `/plugin marketplace update nohjen-marketplace`.
