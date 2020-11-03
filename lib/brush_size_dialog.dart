import 'package:flutter/material.dart';

class BrushSizeDialog extends StatefulWidget {
  BrushSizeDialog({this.initialSize});
  final double initialSize;

  @override
  _BrushSizeDialogState createState() => _BrushSizeDialogState();
}

class _BrushSizeDialogState extends State<BrushSizeDialog> {

  double _brushSize;

  @override
  void initState() {
    _brushSize = widget.initialSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Brush Size"),
      content: Slider(
        min: 0,
        max: 50,
        divisions: 20,
        value: _brushSize,
        onChanged: (value) {
          setState(() {
            _brushSize = value;
          });
        },
      ),
      actions: [
        FlatButton(
          child: Text("Select Size"),
          onPressed: () {
            Navigator.pop(context, _brushSize);
          },
        )
      ],
    );
  }
}
