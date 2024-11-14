import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';

import '../DataHelper.dart';
import '../main.dart';

class SolidColorEffectScreen extends StatefulWidget {
  const SolidColorEffectScreen({super.key});

  @override
  State<SolidColorEffectScreen> createState() => _SolidColorEffectScreenState();
}

class _SolidColorEffectScreenState extends State<SolidColorEffectScreen> {
  var globalSettingsController = Get.put(GlobalSettingsController());
  var btController = Get.put(BlueToothController());

  Color currentColor = Colors.white;

  void setColor() {
    List<int> bytes = List.filled(21, 0);
    bytes[0] = 64;
    int bitPosition = 2;
    bitPosition = appendByteArray(
        0,
        [
          globalSettingsController.smoothEffectChanging.value ? 0 : 1,
          currentColor.red,
          currentColor.green,
          currentColor.blue
        ],
        bytes,
        bitPosition);
    btController.targetCharacteristic.value!
        .write(bytes.sublist(0, (bitPosition / 8.0).ceil()));
  }

  void openColorPicker() {
    Color pickedColor = currentColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              enableAlpha: false,
              pickerColor: pickedColor,
              onColorChanged: (Color color) {
                setState(() {
                  pickedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Select'),
              onPressed: () {
                setState(() {
                  currentColor = pickedColor;
                });
                setColor();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: theme.elevatedButtonTheme.style,
                  onPressed: openColorPicker,
                  child: Text(
                    'Выбрать цвет',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentColor,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
