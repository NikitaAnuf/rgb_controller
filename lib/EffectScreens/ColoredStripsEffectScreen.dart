import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';

import '../DataHelper.dart';
import '../main.dart';

class ColoredStripsEffectScreen extends StatefulWidget {
  const ColoredStripsEffectScreen({super.key});

  @override
  State<ColoredStripsEffectScreen> createState() =>
      _ColoredStripsEffectScreenState();
}

class _ColoredStripsEffectScreenState extends State<ColoredStripsEffectScreen> {
  var globalSettingsController = Get.put(GlobalSettingsController());
  var btController = Get.put(BlueToothController());

  List<Color> colors = [Colors.white];
  int speed = 100, batches = 2, range = 12, spacing = 4;
  bool invertDirection = false;

  void setEffect() {
    List<int> bytes = List.filled(512, 0);
    bytes[0] = 64;
    int bitPosition = 2;
    List<int> params = [
      globalSettingsController.smoothEffectChanging.value ? 0 : 1,
      invertDirection ? 1 : 0,
      speed,
      batches,
      range,
      spacing,
      colors.length
    ];
    for (int i = colors.length - 1; i >= 0; i--) {
      params.add(colors[i].red);
      params.add(colors[i].green);
      params.add(colors[i].blue);
    }
    bitPosition = appendByteArray(3, params, bytes, bitPosition);
    btController.targetCharacteristic.value!
        .write(bytes.sublist(0, (bitPosition / 8.0).ceil()));
  }

  void openColorPicker(int index) {
    Color pickedColor = colors[index];
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
                  colors[index] = pickedColor;
                });
                setEffect();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addColorPicker() {
    if (colors.length > 8) {
      return;
    }
    setState(() {
      colors.add(Colors.white);
    });
    setEffect();
  }

  void removeColorPicker() {
    if (colors.length < 2) {
      return;
    }
    setState(() {
      colors.removeLast();
    });
    setEffect();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Speed',
            style: theme.textTheme.headlineMedium,
          ),
          Slider(
            value: speed.toDouble(),
            min: 0,
            max: 1000,
            label: '$speed',
            divisions: 100,
            activeColor: theme.primaryColor,
            inactiveColor: theme.navigationBarTheme.backgroundColor,
            onChanged: (value) {
              setState(() {
                speed = value.toInt();
              });
            },
            onChangeEnd: (value) {
              setState(() {
                speed = value.toInt();
              });
              setEffect();
            },
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Batches',
            style: theme.textTheme.headlineMedium,
          ),
          Slider(
            value: batches.toDouble(),
            min: 1,
            max: 12,
            label: '$batches',
            divisions: 11,
            activeColor: theme.primaryColor,
            inactiveColor: theme.navigationBarTheme.backgroundColor,
            onChanged: (value) {
              setState(() {
                batches = value.toInt();
              });
            },
            onChangeEnd: (value) {
              setState(() {
                batches = value.toInt();
              });
              setEffect();
            },
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Range',
            style: theme.textTheme.headlineMedium,
          ),
          Slider(
            value: range.toDouble(),
            min: 0,
            max: 100,
            label: '$range',
            divisions: 100,
            activeColor: theme.primaryColor,
            inactiveColor: theme.navigationBarTheme.backgroundColor,
            onChanged: (value) {
              setState(() {
                range = value.toInt();
              });
            },
            onChangeEnd: (value) {
              setState(() {
                range = value.toInt();
              });
              setEffect();
            },
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Spacing',
            style: theme.textTheme.headlineMedium,
          ),
          Slider(
            value: spacing.toDouble(),
            min: 1,
            max: 60,
            label: '$spacing',
            divisions: 59,
            activeColor: theme.primaryColor,
            inactiveColor: theme.navigationBarTheme.backgroundColor,
            onChanged: (value) {
              setState(() {
                spacing = value.toInt();
              });
            },
            onChangeEnd: (value) {
              setState(() {
                spacing = value.toInt();
              });
              setEffect();
            },
          )
        ],
      ),
      Checkbox(
        value: invertDirection,
        activeColor: theme.primaryColor,
        onChanged: (value) {
          setState(() {
            invertDirection = value!;
          });
          setEffect();
        },
      ),
      Expanded(
        child: ListView.builder(
          itemCount: colors.length,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: theme.elevatedButtonTheme.style,
                    onPressed: () => openColorPicker(index),
                    child: Text(
                      'Выбрать цвет ${index + 1}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors[index],
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: theme.elevatedButtonTheme.style,
          onPressed: addColorPicker,
          child: Text(
            'Добавить цвет',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: theme.elevatedButtonTheme.style,
          onPressed: removeColorPicker,
          child: Text(
            'Удалить цвет',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ),
    ]);
  }
}
