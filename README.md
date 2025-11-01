# pulsar_cli

> Command Line Interface for the **Pulsar** Web Framework

## Activate

Activate the pulsar_cli using

```bash
  dart pub global activate pulsar_cli
```

Then use the command `pulsar` for creating and serve Pulsar projects.

## Usage

> Disclaimer: The versions 0.0.x can be strongly modified in future versions of the CLI.

Use `create` to make a new project. The `create` can define the `--template` as `default`, `empty` or `minimum`.

```bash
  pulsar create app_name
```

## Serving

Serve a local server using the following command.
```bash
  pulsar serve
```
The server will be running at the 8080 port by default.

## Building

You can build a project to production using the following command.
```bash
  pulsar build
```

> Note: For the moment Pulsar use webdev to serve the local server while the DevServer is still in development.

### TODO

- DevServer for `serve` command
- Hot reload for `serve` command
- `build` command minification for production
