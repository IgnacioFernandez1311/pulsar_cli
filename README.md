# pulsar_cli

> Official Command Line Interface for the **Pulsar Web Framework**

Pulsar CLI provides project scaffolding, development server, production builds,
environment diagnostics, and advanced tooling designed for a clean and scalable developer experience.

---

## Installation

Activate globally:

```bash
dart pub global activate pulsar_cli
```

after activation use 
̣
```bash
pulsar --help
```

## Creating a project

Use the `create` command to use the project configuration prompt:

```bash
pulsar create
```

or use the configuration options:

| Option        | Description              | Values                            |
| ------------- | ------------------------ | --------------------------------- |
| `--template`  | Project template         | `default`, `minimum`, `empty`     |
| `--use-cdn`   | UI CDN integration       | `none`, `tailwind`, `materialize` |
| `--icons`     | Icon library             | `none`, `material`, `bootstrap`   |
| `-y`          | Skip interactive prompts | —                                 |

Example:
```bash
pulsar create project_name --template default --use-cdn tailwind --icons bootstrap
```

## Development Server

Start the Pulsar Dev Server:
```bash
pulsar serve
```
Default port: *8080*

### Options
| Option         | Description                        |
| -------------- | ---------------------------------- |
| `--port`, `-p` | Custom port                        |
| `--watch`      | Enable file watching (live reload) |

If --watch is disabled, you can manually rebuild:

- Press r → rebuild

- Press q → quit server

The Dev Server:

- Compiles Dart to JavaScript

- Extracts CSS to avoid FOUC

- Serves assets from .dart_tool/pulsar

- Supports SPA routing fallback

- Injects live reload via WebSocket

## Production build

Build for production:

```bash
pulsar build
```

### Options
| Option         | Description                   |
| -------------- | ----------------------------- |
| `--release`    | Optimized build (default)     |
| `--no-release` | Development-level compilation |

The build command:

- Compiles Dart to optimized JS

- Extracts precomputed CSS

- Copies static assets

- Generates SPA redirects (_redirects, vercel.json)

- Outputs to build/

## Environment Diagnostics

Run `doctor` command:

```bash
pulsar doctor
```

Example output

```bash
  Pulsar Doctor
────────────────────────────────
✓ Dart SDK detected (0.1s)
✓ Project structure valid (1ms)
✓ Dependencies look good (2ms)
✓ .dart_tool directory present (0ms)
✓ Routing base configuration looks valid (0ms)
✓ CSS extraction present (0ms)

────────────────────────────────
Score: 92 / 100 (Excellent)

6 checks passed
Pulsar environment looks healthy 

```

### CI Mode

```bash
pulsar doctor --ci
```

In CI mode:

- Output is simplified

- Exit code is 1 if health score < 70

- Designed for GitHub Actions / GitLab / CI pipelines

## Clean Commando

Remove internal build artifacts:

```bash
pulsar clean
```

This clears:

- .dart_tool/pulsar

- Compiled JS bundles

- Extracted CSS artifacts

Useful when debugging build inconsistencies.

## Architecture Overview

- Pulsar CLI is built around:

  - PulsarCompiler

  - Centralized compilation pipeline

  - CSS extraction

  - Output isolation inside .dart_tool/pulsar

- DevServer

  - WebSocket live reload

  - Manual rebuild mode

  - SPA fallback support

- Doctor

  - Environment validation

  - Health scoring

  - CI-ready diagnostics

## Requirements

- Dart SDK ^3.9.0

- Modern browser