# Dartuv

Please note: this package uses the `--enable-experiment=native-assets` feature for accessing ffi functions from dart.

In addition you will need to add `native_assets_cli` as a dev dependency :

### pubspec.yaml
```
dev_dependencies:
  native_assets_cli: ^0.1.0
```
to run the example:

`cd example && dart --enable-experiment=native-assets run`
should give a similar output

```
Resolving dependencies in `...example`... 
Downloading packages... 
Got dependencies in `...example`.
Building package executable... 
Built example:example.
Now quitting.
```