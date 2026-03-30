# Contributing

Contributions are welcome. This setup aims to be the best production-ready Claude Code configuration for AI-native SaaS development.

## How to Contribute

### Adding a new command
1. Create `.claude/commands/your-command.md`
2. Follow the pattern: role description → mission → process → output format → `$ARGUMENTS`
3. Add it to the README command table
4. Update the CHANGELOG

### Adding a new skill
1. Create `.claude/skills/your-skill.md`
2. Include actual implementation code, not just descriptions
3. Reference it from relevant commands (especially `/implement`)
4. Add it to the README skills table
5. Update the CHANGELOG

### Adding a new agent
1. Create `.claude/agents/your-agent.md`
2. Define: capabilities, trigger conditions, boundaries, output format
3. Add it to the README agents table
4. Update the CHANGELOG

### Adding a new hook
1. Create `.claude/hooks/your-hook.mjs`
2. Read input from stdin (JSON), use exit code 0 (allow) or 2 (block with stderr message)
3. Register it in `.claude/settings.json` under the appropriate event
4. Add it to the README hooks table
5. Update the CHANGELOG

## Quality Checklist

Before submitting:
- [ ] Every command has `$ARGUMENTS` at the end
- [ ] Every skill has actual code patterns, not just descriptions
- [ ] Every hook reads from stdin and uses correct exit codes (0 or 2)
- [ ] Every new file is referenced in README.md with accurate counts
- [ ] Cross-references between files are valid (check paths exist)
- [ ] CHANGELOG.md is updated
- [ ] No stale counts or references anywhere

## Conventions

- Commands are named as verbs: `/implement`, `/review`, `/ship`
- Skills are named as nouns: `ai-integration`, `database`, `error-handling`
- Agents are named as roles: `librarian`, `reviewer`, `qa`
- Hooks are named as actions: `pre-write-guard`, `security-scanner`
