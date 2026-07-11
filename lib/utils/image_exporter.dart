import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

class ImageExporter {
  static Future<void> export(GlobalKey key, BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _show(messenger, '書き出し対象が見つかりませんでした');
        return;
      }

      final hasAccess = await Gal.hasAccess(toAlbum: false);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: false);
        if (!granted) {
          _show(messenger, '写真ライブラリへのアクセスが許可されていません');
          return;
        }
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _show(messenger, '画像の生成に失敗しました');
        return;
      }

      final bytes = Uint8List.view(byteData.buffer);
      await Gal.putImageBytes(bytes);
      _show(messenger, '画像を保存しました');
    } catch (e) {
      _show(messenger, '書き出しに失敗しました: $e');
    }
  }

  static void _show(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
