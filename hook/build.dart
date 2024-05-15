import 'package:native_assets_cli/native_assets_cli.dart';

const assetName = 'libuv.so.1';
final packageAssetPath = Uri.file('$assetName');

void main(List<String> args) async {
  await build(args, (config, output) async {
    final packageName = config.packageName;

    output.addAsset(NativeCodeAsset(
      package: packageName,
      name: 'src/bindings/libuv.dart',
      linkMode: DynamicLoadingSystem(packageAssetPath),
      os: config.targetOS,
      architecture: config.targetArchitecture,
    ));
  });
}