# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ralph is a Bash-based agent orchestration system that automates user story implementation. It reads stories from `stories.yaml`, executes an AI agent (Claude) to implement them iteratively, and tracks progress until all stories pass or max iterations are reached.

## Running Ralph

```bash
./ralph.sh
```

The script loops up to `max_iterations` (default 25), passing instructions to Claude via stdin. It exits successfully when output contains `<promise>COMPLETE</promise>` or fails after max iterations.

## Configuration Files

- **ralph.yaml**: Agent binary path, max iterations, story ID regex, and agent instructions
- **stories.yaml**: User story backlog (see `stories.yaml.template` for structure)
- **progress.md**: Implementation tracking (append-only log)

## Story Implementation Workflow

When implementing a story:
1. Pick highest priority story where `passes: false`
2. Implement that ONE story only
3. Run checks and tests
4. Update `stories.yaml` with `passes: true` on success
5. Append learnings to `progress.md` using the format in ralph.yaml
6. Commit with story title and description

## Dependencies

- `yq` - YAML parser
- `claude` CLI - AI agent binary
- `git` - Version control
