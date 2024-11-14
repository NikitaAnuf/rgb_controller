import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../DataHelper.dart';
import '../main.dart';

class AuroraEffectScreen extends StatefulWidget {
  const AuroraEffectScreen({super.key});

  @override
  State<AuroraEffectScreen> createState() => _AuroraEffectScreenState();
}

class _AuroraEffectScreenState extends State<AuroraEffectScreen> {
  var globalSettingsController = Get.put(GlobalSettingsController());
  var btController = Get.put(BlueToothController());

  int nodesCount = 2, projectilesCount = 25;
  int? lastSentNodesCountValue, lastSentProjectilesCountValue;

  Timer? sentTimer;

  DateTime lastSendTime = DateTime.now();

  void setParams() {
    List<int> bytes = List.filled(21, 0);
    bytes[0] = 64;
    int bitPosition = 2;
    bitPosition = appendByteArray(2, [globalSettingsController.smoothEffectChanging.value ? 0 : 1, nodesCount, projectilesCount], bytes, bitPosition);
    btController.targetCharacteristic.value!.write(bytes.sublist(0, (bitPosition / 8.0).ceil()));
  }

  void onParamsChanged(int n, int p) {
    setState(() {
      nodesCount = n;
      projectilesCount = p;
    });

    sentTimer?.cancel();

    final now = DateTime.now();
    sentTimer = Timer(Duration(milliseconds: 100), () {
      if (nodesCount != lastSentNodesCountValue || projectilesCount != lastSentProjectilesCountValue)
      {
        lastSendTime = now;
        setParams();
      }
    });

    if (now.difference(lastSendTime).inMilliseconds >= 100) {
      lastSendTime = now;
      lastSentNodesCountValue = nodesCount;
      lastSentProjectilesCountValue = projectilesCount;
      setParams();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Nodes count',
                  style: theme.textTheme.headlineMedium,
                ),
                Slider(
                  value: nodesCount.toDouble(),
                  min: 1,
                  max: 5,
                  label: '$nodesCount',
                  divisions: 4,
                  activeColor: theme.primaryColor,
                  inactiveColor: theme.navigationBarTheme.backgroundColor,
                  onChangeEnd: (value) => {
                    onParamsChanged(value.toInt(), projectilesCount)
                  },
                  onChanged: (value) => {
                    setState(() {
                      nodesCount = value.toInt();
                    })
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Projectiles count',
                  style: theme.textTheme.headlineMedium,
                ),
                Slider(
                  value: projectilesCount.toDouble(),
                  min: 1,
                  max: 60,
                  label: '$projectilesCount',
                  divisions: 59,
                  activeColor: theme.primaryColor,
                  inactiveColor: theme.navigationBarTheme.backgroundColor,
                  onChangeEnd: (value) => {
                    onParamsChanged(nodesCount, value.toInt())
                  },
                  onChanged: (value) => {
                    setState(() {
                      projectilesCount = value.toInt();
                    })
                  },
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}