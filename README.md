# pulsar_cli

> Command Line Interface for the **Pulsar** Web Framework

## Activate

Activate the pulsar_cli using

```bash
  dart pub global activate pulsar_cli
```

Then use the command `pulsar` for creating and serve Pulsar projects.

## Usage

Use `create` to make a new project.

```bash
  pulsar create app_name
```

## Serving

Serve a local server using the following command
```bash
  pulsar serve
```
> Note: For the moment Pulsar use webdev to serve the local server while the DevServer is still in development.

### TODO

- `build` command
- Hot Reload
- DevServer for `serve` command
