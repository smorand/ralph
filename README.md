# Ralph

Bash-based agent orchestration system that automates user story implementation using Claude AI.

## How it works

Ralph reads user stories from `stories.yaml`, passes instructions to Claude, and iterates until all stories are implemented or max iterations are reached. Each iteration:

1. Agent picks the highest priority story where `passes: false`
2. Implements that ONE story
3. Runs tests and updates `passes: true` on success
4. Commits changes and appends learnings to `progress.md`

## Installation

```bash
# From your project directory
/path/to/ralph/ralph_install.sh
```

This creates:
- `ralph.sh` → symlink to ralph script
- `ralph.yaml` → symlink to default config
- `stories.yaml` → copy of template (editable)

## Usage

```bash
./ralph.sh check   # Validate tools and stories.yaml
./ralph.sh run     # Start the implementation loop
```

## Configuration

### ralph.yaml

```yaml
agent: "claude --dangerously-skip-permissions"
max_iterations: 25
user_story_id_regex: "^US-[0-9]{5}$"
instructions: |-
    # Agent instructions...
```

### stories.yaml

```yaml
- id: US-00001
  title: Initialize project
  priority: 1
  description: |
    Optional description of what to implement.
  tests:
    - make build succeeds
    - make test passes
  passes: false
```

**Required fields:** `id`, `title`, `tests`
**Optional fields:** `description`, `priority` (default: 1), `passes` (default: false)

Stories are processed by lowest `priority` first, then lowest US number.

## Dependencies

- `yq` - YAML parser
- `claude` - Claude Code CLI
- `git` - Version control

## Files

| File | Tracked | Purpose |
|------|---------|---------|
| `ralph.sh` | Yes | Main orchestration script |
| `ralph.yaml` | Yes | Agent configuration and instructions |
| `stories.yaml.template` | Yes | Template for user stories |
| `stories.yaml` | No | Project-specific user stories |
| `progress.md` | No | Implementation progress log |
