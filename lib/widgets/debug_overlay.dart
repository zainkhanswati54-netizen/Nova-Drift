import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/debug_log.dart';

/// A small floating bug button, present on every screen (wired in via
/// `MaterialApp.builder` in main.dart), that opens a scrollable panel
/// of everything [DebugLog] has recorded - app startup steps, caught
/// exceptions, and where in the game's load/update cycle things went
/// wrong. Meant to make bugs like "blue screen on every mode"
/// diagnosable directly on the phone, with no PC or adb needed.
class DebugOverlay extends StatefulWidget {
  const DebugOverlay({super.key});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      bottom: 8,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_open) _LogPanel(onClose: () => setState(() => _open = false)),
            const SizedBox(height: 6),
            _ToggleButton(
              open: _open,
              onTap: () => setState(() => _open = !_open),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: ValueListenableBuilder<List<String>>(
            valueListenable: DebugLog.instance.lines,
            builder: (context, lines, _) => Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  open ? Icons.close : Icons.bug_report,
                  color: Colors.white70,
                  size: 20,
                ),
                if (!open && lines.isNotEmpty)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFF3BC98F),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogPanel extends StatelessWidget {
  const _LogPanel({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
            child: Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'Debug log',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const Spacer(),
                ValueListenableBuilder<List<String>>(
                  valueListenable: DebugLog.instance.lines,
                  builder: (context, lines, _) => IconButton(
                    tooltip: 'Copy all',
                    icon: const Icon(Icons.copy, color: Colors.white54, size: 16),
                    onPressed: lines.isEmpty
                        ? null
                        : () => Clipboard.setData(
                              ClipboardData(text: lines.join('\n')),
                            ),
                  ),
                ),
                IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white54, size: 16),
                  onPressed: DebugLog.instance.clear,
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: DebugLog.instance.lines,
              builder: (context, lines, _) {
                if (lines.isEmpty) {
                  return const Center(
                    child: Text(
                      'No log entries yet.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemCount: lines.length,
                  itemBuilder: (context, i) {
                    final line = lines[lines.length - 1 - i];
                    final isError = line.contains('ERROR') ||
                        line.contains('failed') ||
                        line.contains('Uncaught');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: SelectableText(
                        line,
                        style: TextStyle(
                          color: isError ? const Color(0xFFFF8A8A) : Colors.white70,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
