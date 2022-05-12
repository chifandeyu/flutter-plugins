import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rich_clipboard/rich_clipboard.dart';

class Pasteboard {
  static const MethodChannel _channel = MethodChannel('pasteboard');

  /// Returns the image data of the pasteboard.
  static Future<Uint8List?> get image async {
    final image = await _channel.invokeMethod<Object>('image');

    if (image == null) {
      return null;
    }
    if (Platform.isMacOS || Platform.isLinux || Platform.isIOS) {
      return image as Uint8List;
    } else if (Platform.isWindows) {
      final file = File(image as String);
      final bytes = await file.readAsBytes();
      await file.delete();
      return bytes;
    }
    return null;
  }

  /// get rich text by rich_clipboard
  ///
  /// get html data from system pasteboard.
  static Future<String?> get html async {
    final data = await RichClipboard.getData();
    return data.html;
  }

  /// get text by rich_clipborad
  ///
  /// get text data from system pasteboard.
  static Future<String?> get text async {
    final data = await RichClipboard.getData();
    return data.text;
  }

  ///set text to system pasteboard
  static Future<void> setText(String text) async {
    return await RichClipboard.setData(
        RichClipboardData(text: text, html: null));
  }

  ///set html to system pasteboard
  static Future<void> setHtml(String plainText, String htmlText) async {
    final data = RichClipboardData(
      text: plainText.isEmpty ? null : plainText,
      html: htmlText.isEmpty ? null : htmlText,
    );
    return await RichClipboard.setData(data);
  }

  /// only available on iOS
  ///
  /// set image data to system pasteboard.
  static Future<void> writeImage(Uint8List? image) async {
    if (image == null) {
      return;
    }
    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('writeImage', image);
    }
  }

  /// Only available on desktop platforms.
  ///
  /// Get files from system pasteboard.
  static Future<List<String>> files() async {
    final files = await _channel.invokeMethod<List>('files');
    return files?.cast<String>() ?? const [];
  }

  /// Only available on desktop platforms.
  ///
  /// Set files to system pasteboard.
  static Future<bool> writeFiles(List<String> files) async {
    try {
      await _channel.invokeMethod<Object>('writeFiles', files);
      return true;
    } catch (e) {
      debugPrint('$e');
      return false;
    }
  }
}
