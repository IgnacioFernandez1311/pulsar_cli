# pulsar_cli

> Command Line Interface for the **Pulsar** Web Framework

## Activate

Activate the pulsar_cli using

```bash
  dart pub global activate pulsar_cli
```

Then use the command `pulsar` for creating and serve Pulsar projects.

## Usage


Use `create` to make a new project. The `create` can define two options:
- `--template`: `default`, `minimum`, `empty`
- `--use-cdn`: `none`, `materialize`, `tailwind`. Defaults on `none`.

```bash
  pulsar create app_name
```

## Serving

Serve a local server using the following command.
```bash
  pulsar serve
```
The server will be running at the 8080 port by default. If you want to use another port you can use the `--port` option of this command. Run `pulsar help` for more information.

Also you can use the `--watch` option for live reload.

## Building

You can build a project to production using the following command.
```bash
  pulsar build
```

Note that you can use `--release` and `--[no]-release` flags. Defaults on `--release`.
