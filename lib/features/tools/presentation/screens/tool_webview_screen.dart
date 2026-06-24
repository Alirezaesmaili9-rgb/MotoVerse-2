import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../garage/presentation/providers/garage_providers.dart';
import '../../domain/entities/embedded_tool.dart';
import '../providers/tool_providers.dart';

/// Hosts an embedded HTML tool (MotoFix / MotoSanj / MotoType) in a WebView,
/// loading the bundled asset **unmodified**.
///
/// Bridge:
///  • app → tool: injects `window.MotoVerseContext` + a `motoverse:context`
///    event so the tool can pre-fill the user's motorcycle.
///  • tool → app: exposes `window.MotoVerse.sendResult(obj)` (backed by the
///    `MotoVerseBridge` JS channel); incoming results are persisted to
///    `tool_results` against the user + primary motorcycle.
class ToolWebViewScreen extends ConsumerStatefulWidget {
  const ToolWebViewScreen({super.key, required this.tool});

  final EmbeddedTool tool;

  @override
  ConsumerState<ToolWebViewScreen> createState() => _ToolWebViewScreenState();
}

class _ToolWebViewScreenState extends ConsumerState<ToolWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'MotoVerseBridge',
        onMessageReceived: _onResult,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _injectBridge();
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadFlutterAsset(widget.tool.assetPath);
  }

  /// Injects the app context + the tool→app result helper.
  Future<void> _injectBridge() async {
    final context = ref.read(toolContextProvider);
    final json = jsonEncode(context.toJson());
    await _controller.runJavaScript('''
      (function () {
        window.MotoVerseContext = $json;
        window.MotoVerse = window.MotoVerse || {};
        window.MotoVerse.context = window.MotoVerseContext;
        window.MotoVerse.sendResult = function (result) {
          try {
            MotoVerseBridge.postMessage(
              typeof result === 'string' ? result : JSON.stringify(result)
            );
          } catch (e) {}
        };
        window.dispatchEvent(
          new CustomEvent('motoverse:context', { detail: window.MotoVerseContext })
        );
      })();
    ''');
  }

  Future<void> _onResult(JavaScriptMessage message) async {
    Map<String, dynamic> payload;
    String? summary;
    try {
      final decoded = jsonDecode(message.message);
      if (decoded is Map<String, dynamic>) {
        payload = decoded;
        summary = decoded['summary'] as String?;
      } else {
        payload = {'value': decoded};
      }
    } catch (_) {
      payload = {'raw': message.message};
    }

    final bikeId = ref.read(primaryMotorcycleProvider)?.id;
    final result = await ref.read(toolsRepositoryProvider).saveResult(
          tool: widget.tool,
          motorcycleId: bikeId,
          summary: summary,
          payload: payload,
        );

    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(summary ?? 'نتیجه در پروفایل شما ذخیره شد ✓')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tool.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(height: 2, color: widget.tool.accent),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            ColoredBox(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: widget.tool.accent),
                    const SizedBox(height: 12),
                    Text('در حال بارگذاری ${widget.tool.title}...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
