import 'package:flutter/material.dart';

class TypingText extends StatefulWidget {
  const TypingText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 25),
  });

  final String text;
  final TextStyle? style;
  final Duration duration;

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String _displayed = '';
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  @override
  void didUpdateWidget(TypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _displayed = '';
      _index = 0;
      _tick();
    }
  }

  void _tick() {
    if (_index < widget.text.length) {
      Future.delayed(widget.duration, () {
        if (!mounted) return;
        setState(() {
          _index++;
          _displayed = widget.text.substring(0, _index);
        });
        _tick();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayed, style: widget.style);
  }
}
