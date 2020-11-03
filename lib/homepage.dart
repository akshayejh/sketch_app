import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sketch_app/brush_size_dialog.dart';
import 'package:sketch_app/draw_point.dart';
import 'package:sketch_app/sketch_canvas.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  // Create a list of drawPoints to store all drag events
  List<DrawPoint> _drawPoints = [];

  // Color Picker Variables
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  // Brush Size Variables
  double _brushSize = 5;

  // Screenshot canvas variables
  File _imageFile;
  ScreenshotController screenshotController = ScreenshotController();

  // Color change callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Select Size'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showBrushSizeDialog() async {
    double selectedSize = await showDialog(
      context: context,
      child: BrushSizeDialog(
        initialSize: _brushSize,
      ),
    );

    if(selectedSize != null) {
      _brushSize = selectedSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (event) {
              // Start Drawing
              setState(() {
                _drawPoints.add(
                    DrawPoint(
                      position: event.localPosition,
                      paint: Paint()
                        ..color = currentColor
                        ..strokeWidth = _brushSize
                        ..strokeCap = StrokeCap.round,
                    )
                );
              });
            },
            onPanUpdate: (event) {
              // Keep Drawing
              setState(() {
                _drawPoints.add(
                    DrawPoint(
                      position: event.localPosition,
                      paint: Paint()
                        ..color = currentColor
                        ..strokeWidth = _brushSize
                        ..strokeCap = StrokeCap.round,
                    )
                );
              });
            },
            onPanEnd: (event) {
              // Stop Drawing
              _drawPoints.add(null);
            },
            child: Screenshot(
              controller: screenshotController,
              child: Container(
                color: Colors.white,
                child: CustomPaint(
                  painter: SketchCanvas(
                    drawPoints: _drawPoints,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              margin: EdgeInsets.all(15.0),
              padding: EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Show Color Picker
                      _showColorPicker();
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: currentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  FlatButton(
                    child: Text("Brush Size"),
                    onPressed: () {
                      // Show BrushSize Dialog
                      _showBrushSizeDialog();
                    },
                  ),
                  FlatButton(
                    child: Text("Save"),
                    onPressed: () async {
                      // Save Image
                      var storagePermission = await Permission.storage.status;

                      if(storagePermission.isGranted) {
                        screenshotController.capture().then((File image) async {
                          //Capture Done
                          setState(() {
                            _imageFile = image;
                          });
                          print("Screenshot taken");

                          final result = await ImageGallerySaver.saveImage(image.readAsBytesSync());
                          print("Result: $result");

                        }).catchError((onError) {
                          print(onError);
                        });
                      } else {
                        Permission.storage.request();
                      }
                    },
                  ),
                  FlatButton(
                    child: Text("Clear"),
                    onPressed: () {
                      // Clear all the drawPoints
                      setState(() {
                        _drawPoints.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
