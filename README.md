![](https://raw.githubusercontent.com/mxflutter/mxflutter/master/mxflutter/mxflutterlogo.png)

## MX_Mirror_Builder

开发MXFlutter TypeScript(以下简称：TS)工程时如果你需要将某些Dart层API接口扩展成TS层API接口，可以借助mx-mirror-builder生成桥接类。
桥接类包括两部分:TS API和Dart Mirror，调用TS API可以桥接到对应的Dart层API接口。

## 环境依赖

Flutter: 1.22.3

Dart: 2.10.3

## 安装

```bash
# 添加环境变量DART_HOME或者通过sdk参数指定dartsdk路径
$ git clone https://github.com/mxflutter/mx_mirror_builder.git
$ dart pub global activate --source path {mx-mirror-builder project path}
```

## 使用

```bash
# 指定入口main文件
$ mxbuilder --entry-point {your project}/lib/main.dart
```

```bash
$ mxbuilder --help
    --pubspec         pubspec.yaml path
    --entry-point     main.dart path
    --sdk             dart sdk path, default DART_HOME
-o, --output          output path, defalut current path
    --filter-mode     chose filter mode black or white
                      (defaults to "black")
    --type            all ts dart js
                      (defaults to "all")
    --build-config    build proxy confing filePath
-h, --help            Displays this help information.
```

mxbuilder支持黑白名单两种过滤方法，可以通过build-config参数指定配置文件，配置文件格式如下:

```json
{
  "FileWhiteList": [
    "package:flutter"
  ],
  "ClassWhiteList": [
    "Widget",
    "Text",
    "State",
    "Color",
  ],
  "FileBlackList": [
    "package:characters",
    "package:collection",
    "package:nested",
    "package:typed_data",
    "package:flutter/src/foundation/assertions.dart"
  ],
  "ClassBlackList": [
    "Iterable",
    "ByteConversionSinkBase",
    "DiagnosticsNode",
    "Diagnosticable",
    "Error",
    "FlutterErrorDetails",
    "LinkedListEntry"
  ]
}
```

## 示例

如何使用第三方库[flutter_svg](https://pub.flutter-io.cn/packages/flutter_svg)

1. 添加依赖

```
dependencies:
  flutter_svg: ^0.18.0
```

2. 安装

```bash
flutter pub get
```diff
-***注意*** 必须在工程内任何地方导入 import 'package:flutter_svg/flutter_svg.dart'，否则索引不到会导致无法正常生成产物;
```

3. 使用mxbuilder生成代理类, 默认使用黑名单生成，如果觉得生成太多无用代码可以通过配置文件控制

```bash
mxbuilder --entry {your project}/lib/main.dart --output {your project}/mx_mirror/
```

![产物.png](https://i.loli.net/2021/03/17/o2uCbsf8HBN7mkz.png)

4. 找到SvgPicture的产物并注册

* 生成的Dart Mirror

```dart
//把自己能处理的类注册到分发器中
...
Map<String, MXFunctionInvoke> registerSvgSeries() {
  var m = <String, MXFunctionInvoke>{};
  ...
  m[_svgPicture_asset.funName] = _svgPicture_asset;
  ...
  return m;
}
...
var _svgPicture_asset = MXFunctionInvoke(
  "SvgPicture.asset",
  ({
    String assetName,
    Key key,
    bool matchTextDirection = false,
    AssetBundle bundle,
    String package,
    dynamic width,
    dynamic height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    dynamic placeholderBuilder,
    Color color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    String semanticsLabel,
    bool excludeFromSemantics = false,
    Clip clipBehavior = Clip.hardEdge,
  }) => SvgPicture.asset(
    assetName,
    key: key,
    matchTextDirection: matchTextDirection,
    bundle: bundle,
    package: package,
    width: width?.toDouble(),
    height: height?.toDouble(),
    fit: fit,
    alignment: alignment,
    allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
    placeholderBuilder: null,
    color: color,
    colorBlendMode: colorBlendMode,
    semanticsLabel: semanticsLabel,
    excludeFromSemantics: excludeFromSemantics,
    clipBehavior: clipBehavior,
  ),
  [
    "assetName",
    "key",
    "matchTextDirection",
    "bundle",
    "package",
    "width",
    "height",
    "fit",
    "alignment",
    "allowDrawingOutsideViewBox",
    "placeholderBuilder",
    "color",
    "colorBlendMode",
    "semanticsLabel",
    "excludeFromSemantics",
    "clipBehavior",
  ],
);
...
}
```

拷贝Dart Mirror到你的工程，并在工程中注册SvgPicture

```dart
MXMirror.getInstance().registerFunctions(registerSvgSeries());
```

* 生成的TS API

```typescript
...
class SvgPicture extends StatefulWidget {
  width: number;
  height: number;
  fit: BoxFit;
  alignment: AlignmentGeometry;
  pictureProvider: PictureProvider;
  placeholderBuilder: any;
  matchTextDirection: boolean;
  allowDrawingOutsideViewBox: boolean;
  semanticsLabel: string;
  excludeFromSemantics: boolean;
  clipBehavior: Clip;
  ...
  static asset(assetName?: string, namedParameters: {key?: Key, matchTextDirection?: boolean, bundle?: AssetBundle, __mx_package?: string, width?: number, height?: number, fit?: BoxFit, alignment?: AlignmentGeometry, allowDrawingOutsideViewBox?: boolean, placeholderBuilder?: any, color?: Color, colorBlendMode?: BlendMode, semanticsLabel?: string, excludeFromSemantics?: boolean, clipBehavior?: Clip} = {}) {
    var jsObj = new SvgPicture();
    jsObj['assetName'] = assetName;
    jsObj.key = namedParameters.key;
    jsObj.matchTextDirection = namedParameters.matchTextDirection;
    jsObj['bundle'] = namedParameters.bundle;
    jsObj['__mx_package'] = namedParameters.__mx_package;
    jsObj.width = namedParameters.width;
    jsObj.height = namedParameters.height;
    jsObj.fit = namedParameters.fit;
    jsObj.alignment = namedParameters.alignment;
    jsObj.allowDrawingOutsideViewBox = namedParameters.allowDrawingOutsideViewBox;
    jsObj.placeholderBuilder = namedParameters.placeholderBuilder;
    jsObj['color'] = namedParameters.color;
    jsObj['colorBlendMode'] = namedParameters.colorBlendMode;
    jsObj.semanticsLabel = namedParameters.semanticsLabel;
    jsObj.excludeFromSemantics = namedParameters.excludeFromSemantics;
    jsObj.clipBehavior = namedParameters.clipBehavior;
    jsObj['constructorName'] = 'asset';
    return jsObj;
  }
 ....
}
```

拷贝TS API至TS工程并使用

```typescript
...
SvgPicture.asset(image,
        {width: width, height: height, fit: BoxFit.contain});
...
```
