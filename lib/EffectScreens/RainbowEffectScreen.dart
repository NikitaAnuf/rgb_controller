import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../DataHelper.dart';
import '../main.dart';

class RainbowEffectScreen extends StatefulWidget {
  const RainbowEffectScreen({super.key});

  @override
  State<RainbowEffectScreen> createState() => _RainbowEffectScreenState();
}

class _RainbowEffectScreenState extends State<RainbowEffectScreen> {
  var globalSettingsController = Get.put(GlobalSettingsController());
  var btController = Get.put(BlueToothController());

  bool invertDirection = false;
  bool? lastSentInvertDirectionValue;
  int speed = 100;
  int? lastSentSpeedValue;

  Timer? sentTimer;

  DateTime lastSendTime = DateTime.now();

  void setParams() {
    List<int> bytes = List.filled(21, 0);
    bytes[0] = 64;
    int bitPosition = 2;
    bitPosition = appendByteArray(1, [globalSettingsController.smoothEffectChanging.value ? 0 : 1, invertDirection ? 0 : 1, speed], bytes, bitPosition);
    btController.targetCharacteristic.value!.write(bytes.sublist(0, (bitPosition / 8.0).ceil()));
  }

  void onParamsChanged(bool d, int s) {
    setState(() {
      invertDirection = d;
      speed = s;
    });

    sentTimer?.cancel();

    final now = DateTime.now();
    sentTimer = Timer(Duration(milliseconds: 100), () {
      if (invertDirection != lastSentInvertDirectionValue || speed != lastSentSpeedValue)
      {
        lastSendTime = now;
        setParams();
      }
    });

    if (now.difference(lastSendTime).inMilliseconds >= 100) {
      lastSendTime = now;
      setParams();
      lastSentInvertDirectionValue = invertDirection;
      lastSentSpeedValue = speed;
    }
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
            Slider(
              value: speed.toDouble(),
              min: 1,
              max: 1000,
              label: '$speed',
              divisions: 100,
              activeColor: theme.primaryColor,
              inactiveColor: theme.navigationBarTheme.backgroundColor,
              onChangeEnd: (value) => {
                onParamsChanged(invertDirection, value.toInt())
              },
              onChanged: (value) => {
                setState(() {
                  speed = value.toInt();
                })
              },
            ),
            Checkbox(
              value: invertDirection,
              activeColor: theme.primaryColor,
              onChanged: (value) => {
                setState(() {
                  onParamsChanged(value!, speed);
                })
              },
            ),
          ],
        )
      ],
    );
  }
}