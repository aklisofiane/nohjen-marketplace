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
