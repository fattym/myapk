import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Wraps the app: shows a banner while offline and a reconnect pop-up
/// whenever the connection drops (on whatever page the user is on).
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child});
  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  final _online = ConnectivityService.instance.online;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _online.addListener(_onChange);
  }

  @override
  void dispose() {
    _online.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (!_online.value) _showDialog();
  }

  Future<void> _showDialog() async {
    final ctx = appNavigatorKey.currentContext;
    if (_dialogOpen || ctx == null) return;
    _dialogOpen = true;
    await showDialog<void>(
      context: ctx,
      builder: (_) => const _ReconnectDialog(),
    );
    _dialogOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _online,
      builder: (context, online, _) {
        return Column(
          children: [
            Expanded(child: widget.child),
            if (!online)
              Material(
                color: const Color(0xFF424242),
                child: SafeArea(
                  top: false,
                  child: InkWell(
                    onTap: _showDialog,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.wifi_off, size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "You're offline · Tap to reconnect",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReconnectDialog extends StatefulWidget {
  const _ReconnectDialog();

  @override
  State<_ReconnectDialog> createState() => _ReconnectDialogState();
}

class _ReconnectDialogState extends State<_ReconnectDialog> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _reconnect() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    await ConnectivityService.instance.check();
    if (!mounted) return;
    if (ConnectivityService.instance.online.value) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _busy = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.wifi_off, size: 32),
      title: const Text("You're offline"),
      content: Text(_failed
          ? 'Still no connection. Check your Wi-Fi or mobile data and try again.'
          : 'Check your internet connection to see the latest products and place orders.'),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Dismiss'),
        ),
        FilledButton(
          onPressed: _busy ? null : _reconnect,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Reconnect'),
        ),
      ],
    );
  }
}
