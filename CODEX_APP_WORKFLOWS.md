# Codex App Workflows

How to run parallel AI workstreams using Codex App and Claude Code with the
workstream contract (`.workstream/`).

## The Model

You have two engines:

| Engine | Strengths | How it runs |
|--------|-----------|-------------|
| **Codex App** | Fire-and-forget threads, automatic worktree isolation, good for well-scoped tasks | Each thread gets its own git worktree. You give it a task, it works autonomously, it opens a PR. |
| **Claude Code** | Deep interactive work, multi-step orchestration, debugging, exploration | You work together in a terminal. For parallel work, you manually create worktrees. |

Both use the same `.workstream/` scripts for environment setup and verification.
You can run them simultaneously — Codex threads working on features while you
pair with Claude Code on something else.

## One-Time Setup (Per Project)

### 1. Sync workstream scripts to your project

From the toolkit directory:

```bash
/update-target-projects
# Or for a specific project:
/setup ~/Projects/my-app
```

This copies `.workstream/` and `.codex/` into your project.

### 2. Configure Codex App

In **Codex App** for your project:

1. Open **Settings** (Cmd+, or gear icon)
2. Go to the **Local Environments** section
3. Set the setup script to:
   ```
   bash .codex/setup.sh
   ```
   This runs automatically when Codex creates a worktree for a new thread.
4. When creating a new thread, select **Worktree** under the composer and
   choose the local environment you just configured

### 3. Create workstream.json (optional)

If your project has a dev server or custom verification steps, create
`workstream.json` at your project root:

```bash
cp .workstream/workstream.json.example workstream.json
```

Edit it with your project's specifics:

```json
{
  "project": "my-app",
  "services": {
    "dev": {
      "command": "pnpm dev -- --port $WS_PORT_DEV",
      "defaultPort": 4321
    }
  },
  "verify": {
    "steps": ["typecheck", "lint", "test", "build"],
    "commands": {
      "typecheck": "pnpm tsc --noEmit"
    }
  }
}
```

If you skip this, the scripts auto-detect everything from your lockfile,
package.json, and `.claude/verification-config.json`.

---

## Workflow A: Codex App Thread (Fire-and-Forget)

The simplest workflow. Give Codex a scoped task, let it work, review the PR.

### Steps

1. **Open Codex App** and select your project
2. **Create a new thread** with a clear task description:

   > "Add a dark mode toggle to the settings page. Use the existing theme
   > context in src/contexts/theme.tsx. Include unit tests."

3. **Select Worktree** under the composer and pick your local environment
4. **Codex creates a worktree** and **runs `.codex/setup.sh`** — installs
   deps, copies `.env.local`, symlinks settings
5. **Codex works autonomously** — writes code, runs tests
6. **Before creating a PR**, Codex should run:
   ```bash
   bash .workstream/verify.sh
   ```
   (The `.codex/AGENTS.md` instructs it to do this)
7. **Codex opens a PR** — you review and merge

### What happens under the hood

```
Your project (main checkout)
  └── Codex creates: ../my-app-codex-abc123/  (worktree)
        ├── .workstream/setup.sh runs automatically
        │   ├── Copies .env.local from main checkout
        │   ├── Symlinks .claude/settings.local.json
        │   └── Runs pnpm install
        ├── Codex writes code on branch: codex/dark-mode-toggle
        ├── Codex runs .workstream/verify.sh
        └── Codex opens PR → you review → merge
```

### Good tasks for fire-and-forget

- Bug fixes with clear reproduction steps
- Adding a component/page with a defined spec
- Writing tests for existing code
- Refactoring with clear before/after criteria
- Documentation updates

### Tasks that need more guidance

- Architecture changes (use Claude Code interactively instead)
- Features requiring design decisions
- Debugging without clear reproduction steps
- Anything where you'd say "let me think about this"

---

## Workflow B: Parallel Codex Threads

Run 2-5 Codex threads simultaneously on different tasks.

### Steps

1. **Identify independent tasks** — features or fixes that don't touch the
   same files
2. **Create a thread for each task** in Codex App
3. Each thread gets its own worktree, branch, and port allocation
4. **Monitor progress** in the Codex App thread list
5. **Review PRs** as they come in — merge in any order

### Example: Three parallel threads

```
Thread 1: "Add user avatar upload to profile page"
  → branch: codex/avatar-upload
  → worktree port: 12847 (auto-allocated)

Thread 2: "Fix timezone handling in the scheduling API"
  → branch: codex/fix-timezone
  → worktree port: 11203 (auto-allocated)

Thread 3: "Add CSV export to the reports page"
  → branch: codex/csv-export
  → worktree port: 13592 (auto-allocated)
```

### Avoiding conflicts

- **File overlap:** If two tasks might edit the same file, run them
  sequentially instead
- **Database migrations:** Only one thread should create migrations at a time
- **Merge order:** After merging one PR, other threads' PRs may need a rebase
- **Shared state:** Environment variables and database are shared across
  worktrees (each worktree points at the same `.env.local` by default)

---

## Workflow C: Claude Code + Worktrees

For interactive work where you want parallelism but also want to pair with
Claude.

### Steps

1. **Create a worktree manually:**

   ```bash
   git worktree add ../my-app-feature -b feature/my-feature
   ```

2. **Set it up:**

   ```bash
   cd ../my-app-feature
   bash .workstream/setup.sh
   ```

3. **Start a dev server** (if needed):

   ```bash
   bash .workstream/dev.sh
   # Output: [workstream] Dev server port: 12847
   ```

4. **Work with Claude Code** in that directory:

   ```bash
   claude   # or open in your IDE with Claude Code extension
   ```

5. **When done, verify:**

   ```bash
   bash .workstream/verify.sh
   ```

6. **Create a PR:**

   ```bash
   /create-pr
   ```

7. **Clean up after merge:**

   ```bash
   cd ../my-app
   git worktree remove ../my-app-feature
   ```

### Running multiple Claude Code sessions

Open multiple terminal tabs/windows, each in a different worktree:

```
Terminal 1:  cd ../my-app-feature-a && claude
Terminal 2:  cd ../my-app-feature-b && claude
Terminal 3:  cd ../my-app              (main checkout — orchestration)
```

Each session has isolated dependencies and its own dev server port.

---

## Workflow D: Mixed (Claude Code + Codex App)

The most powerful pattern. Use Claude Code for complex work while Codex
handles simpler tasks in the background.

### Example session

```
You (in Claude Code, main checkout):
  "I'm going to work on the auth refactor. While I do that,
   I've kicked off two Codex threads for the CSV export and
   the timezone fix."

Your setup:
  ├── Terminal: Claude Code in main checkout (auth refactor)
  ├── Codex Thread 1: CSV export (fire-and-forget)
  └── Codex Thread 2: Timezone fix (fire-and-forget)
```

### Coordination tips

- **Start Codex threads first** — they work autonomously while you focus
- **Work on the hardest task yourself** with Claude Code
- **Check Codex thread status** periodically in the Codex App UI
- **Review Codex PRs** during natural breaks in your Claude Code session
- **Merge Codex PRs before your own** if they're ready — fewer conflicts

---

## Checking on Workstreams

### List active worktrees

```bash
git worktree list
```

Output:

```
/Users/you/Projects/my-app              abc1234 [main]
/Users/you/Projects/my-app-feature-a    def5678 [feature/auth-refactor]
/tmp/codex-worktree-xyz                 ghi9012 [codex/csv-export]
```

### Check which ports are in use

```bash
# See all workstream dev servers
lsof -i -P | grep LISTEN | grep -E '1[0-4][0-9]{3}'
```

### Check a worktree's verification status

```bash
cd ../my-app-feature-a
bash .workstream/verify.sh
```

---

## Cleanup

### Remove a single worktree

```bash
git worktree remove ../my-app-feature-a
```

### Remove all non-main worktrees

```bash
# List them first
git worktree list

# Remove each one (will refuse if there are uncommitted changes)
git worktree remove ../path-to-worktree

# Prune stale worktree references
git worktree prune
```

### After merging PRs

Worktrees for merged branches can be safely removed. The branch itself can
be deleted too:

```bash
git worktree remove ../my-app-feature
git branch -d feature/my-feature
```

---

## Troubleshooting

### "Port already in use"

The workstream scripts auto-walk to the next free port. If you see this
warning, it's handled automatically:

```
[workstream] WARN: Port 4321 in use, trying next...
[workstream] Dev server port: 4322
```

### "setup.sh: .env.local not found"

This means the main checkout doesn't have a `.env.local` file. Create one
in the main checkout first, then re-run setup in the worktree:

```bash
cd ../my-app          # main checkout
cp .env.example .env.local
# Edit .env.local with your values

cd ../my-app-feature  # worktree
bash .workstream/setup.sh
```

### "npm ci failed" in setup

This usually means the lockfile is out of sync. Run in the main checkout
first:

```bash
cd ../my-app
npm install
# Commit the updated lockfile if needed

cd ../my-app-feature
bash .workstream/setup.sh
```

### Codex thread didn't run verify.sh

If a Codex PR arrives without passing verification, run it yourself:

```bash
cd /path/to/codex/worktree
bash .workstream/verify.sh
```

Or request changes on the PR asking Codex to run verification.

### Worktree has stale dependencies

If the main branch has updated dependencies since the worktree was created:

```bash
cd ../my-app-feature
git merge main        # or rebase
bash .workstream/setup.sh   # re-installs deps
```
