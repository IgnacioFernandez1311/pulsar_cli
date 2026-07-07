# pulsar_cli

> Official Command Line Interface for the **Pulsar Web Framework**

Pulsar CLI provides project scaffolding, dependency management, development server, production builds, environment diagnostics, and advanced tooling designed for a clean and scalable developer experience.

---

## Installation

Activate globally:

```bash
dart pub global activate pulsar_cli
```

After activation:

```bash
pulsar --help
```

---

## Creating a project

Use the `create` command to launch the interactive project setup:

```bash
pulsar create
```

Or pass options directly to skip the prompts:

| Option        | Description              | Values                            |
| ------------- | ------------------------ | --------------------------------- |
| `--template`  | Project template         | `default`, `minimum`, `empty`     |
| `--use-cdn`   | UI CDN integration       | `none`, `tailwind`, `materialize` |
| `--icons`     | Icon library             | `none`, `material`, `bootstrap`   |
| `-y`          | Skip interactive prompts | —                                 |

Example:

```bash
pulsar create my_app --template default --use-cdn tailwind --icons bootstrap
```

`create` generates a complete project including `pubspec.yaml`, `analysis_options.yaml`, and all template files. The `analysis_options.yaml` is pre-configured with `custom_lint` and `pulsar_lint` so static analysis works from the first run.

After creating a project, run:

```bash
cd my_app
pulsar get
pulsar serve
```

---

## Dependencies and linting

Resolve dependencies and run the Pulsar linter in one step:

```bash
pulsar get
```

This command always runs `dart pub get` followed by `dart run custom_lint`. Running both together ensures the linter plugin is fully initialized after any dependency change — including after `pulsar clean`, after switching branches, or after a fresh clone.

### Options

| Option      | Description                          |
| ----------- | ------------------------------------ |
| `--no-pub`  | Skip `dart pub get`, only run linter |

Use `--no-pub` when you know your dependencies are up to date and only want to re-run the linter:

```bash
pulsar get --no-pub
```

### Why a dedicated command?

`dart pub get` and `dart run custom_lint` are related operations that are almost always needed together. `pulsar get` unifies them under a single command with clear progress output, so you never have to remember to run both manually.

---

## Development server

Start the Pulsar dev server:

```bash
pulsar serve
```

Default port: `8080`

### Options

| Option         | Description                        |
| -------------- | ---------------------------------- |
| `--port`, `-p` | Custom port                        |
| `--watch`      | Enable file watching (live reload) |

If `--watch` is disabled, you can control the server manually:

- Press `r` → rebuild
- Press `q` → quit

The dev server:

- Compiles Dart to JavaScript
- Extracts CSS to avoid FOUC
- Serves assets from `.dart_tool/pulsar`
- Supports SPA routing fallback
- Injects live reload via WebSocket

---

## Production build

Build for production:

```bash
pulsar build
```

### Options

| Option         | Description                       |
| -------------- | --------------------------------- |
| `--release`    | Optimized build (default)         |
| `--no-release` | Development-level compilation     |

The build command:

- Compiles Dart to optimized JS
- Extracts precomputed CSS
- Copies static assets
- Generates SPA redirects (`_redirects`, `vercel.json`)
- Outputs to `build/`

---

## Environment diagnostics

Check the health of your Pulsar environment:

```bash
pulsar doctor
```

Example output:

```
  Pulsar Doctor
────────────────────────────────
✓ Dart SDK detected (0ms)
✓ Project structure valid (1ms)
✓ Dependencies resolved (2ms)
✓ .dart_tool directory present (0ms)
✓ pulsar_lint active and running (312ms)
✓ Routing base configuration looks valid (0ms)
✓ CSS extraction present (0ms)

────────────────────────────────
Score: 97 / 100 (Excellent)

6 checks passed
```

The doctor verifies:

- Dart SDK availability
- Project structure (`web/`, `lib/`, `web/main.dart`)
- Resolved dependencies (`pubspec.lock`)
- `.dart_tool` directory presence
- `pulsar_lint` configuration and runtime status
- Routing base (`web/index.html`)
- Build hygiene (no stale `build/` directory)
- JS bundle size (if built)
- CSS extraction status

### Linter check

The doctor validates three things for `pulsar_lint`:

1. `pubspec.yaml` declares `custom_lint` and `pulsar_lint` as dev dependencies
2. `analysis_options.yaml` has the `custom_lint` plugin enabled
3. `dart run custom_lint` runs without errors

If any of these fail, the doctor reports what is missing and suggests running `pulsar get` to restore the linter.

### CI mode

```bash
pulsar doctor --ci
```

In CI mode:

- Output is simplified to a single health score line
- Exit code is `1` if the health score is below 70
- Designed for GitHub Actions, GitLab CI, and similar pipelines

---

## Clean

Remove internal build artifacts:

```bash
pulsar clean
```

This clears:

- `.dart_tool/pulsar`
- Compiled JS bundles
- Extracted CSS artifacts

Useful when debugging build inconsistencies. After cleaning, run `pulsar get` to restore the linter and `pulsar serve` to recompile.

---

## Typical workflow

```bash
# Create and set up a new project
pulsar create my_app
cd my_app
pulsar get

# Develop
pulsar serve

# After pulling changes or adding dependencies
pulsar get

# After cleaning build artifacts
pulsar clean
pulsar get
pulsar serve

# Check environment health
pulsar doctor

# Build for production
pulsar build
```

---

## Architecture overview

**Pulsar CLI** is built around:

- **PulsarCompiler** — centralized compilation pipeline, CSS extraction, output isolation inside `.dart_tool/pulsar`
- **DevServer** — WebSocket live reload, manual rebuild mode, SPA fallback support
- **Doctor** — environment validation, health scoring, CI-ready diagnostics, linter status check

---

## Requirements

- Dart SDK `^3.9.0`
- Modern browser
