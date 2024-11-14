import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rgb_controller/EffectScreens/RainbowEffectScreen.dart';
import 'DataHelper.dart';
import 'EffectScreens/AuroraEffectScreen.dart';
import 'EffectScreens/ColoredStripsEffectScreen.dart';
import 'EffectScreens/SolidColorEffectScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter RGB Controller App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 0, 73, 183),
            titleTextStyle: TextStyle(
              color: Colors.white,
            )),
        primaryColor: const Color.fromARGB(255, 0, 73, 183),
        primaryColorLight: const Color.fromARGB(255, 187, 187, 187),
        scaffoldBackgroundColor: Colors.white,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 245, 245, 245),
        ),
        textTheme: const TextTheme(
            labelSmall: TextStyle(
              color: Colors.white,
            ),
            headlineMedium: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            labelMedium: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            )),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all(Color.fromARGB(255, 0, 73, 183)),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const NavigationMenu(),
    );
  }
}

class BlueToothScreen extends StatefulWidget {
  const BlueToothScreen({super.key});

  @override
  State<BlueToothScreen> createState() => _BlueToothScreenState();
}

class _BlueToothScreenState extends State<BlueToothScreen> {
  List<BluetoothDevice> devices = [];

  final bluetoothController = Get.find<BlueToothController>();

  final String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  void ConnectToDevice(BluetoothDevice device) async {
    await device.connect();

    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUUID) {
            bluetoothController.targetCharacteristic.value = characteristic;
            break;
          }
        }
      }
    }
    setState(() {
      bluetoothController.BTDevice.value = device;
    });
  }

  void _startScanning() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device) && mounted) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });
    for (BluetoothDevice connectedDevice
        in FlutterBluePlus.connectedDevices.toList()) {
      if (!devices.contains(connectedDevice) && mounted) {
        setState(() {
          devices.add(connectedDevice);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Подключение по BlueTooth',
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: Text(
                devices[index].platformName == ''
                    ? 'Device name undefined'
                    : devices[index].platformName,
                style: const TextStyle(color: Colors.black),
              ),
              subtitle: Text(devices[index].remoteId.toString()),
              trailing:
                  bluetoothController.BTDevice.value?.remoteId.toString() ==
                          devices[index].remoteId.toString()
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
              onTap: () {
                ConnectToDevice(devices[index]);
              });
        },
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }
}

class EffectsScreen extends StatefulWidget {
  const EffectsScreen({super.key});

  @override
  State<EffectsScreen> createState() => _EffectsScreenState();
}

class _EffectsScreenState extends State<EffectsScreen> {
  List<StatefulWidget> effectsScreens = [
    SolidColorEffectScreen(),
    RainbowEffectScreen(),
    AuroraEffectScreen(),
    ColoredStripsEffectScreen()
  ];

  List<String> effects = ['Solid Color', 'Rainbow', 'Aurora', 'Colored Strips'];

  late String dropDownValue;

  final controller = Get.put(EffectsController());
  var btController = Get.put(BlueToothController());

  @override
  void initState() {
    dropDownValue = effects[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Эффекты', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Список эффектов',
                  style: theme.textTheme.headlineMedium,
                ),
                DropdownButton<String>(
                  items: effects.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  value: dropDownValue,
                  dropdownColor: theme.navigationBarTheme.backgroundColor,
                  onChanged: (selectedValue) => {
                    setState(() {
                      dropDownValue = selectedValue.toString();
                      controller.selectedIndex.value =
                          effects.indexOf(dropDownValue);
                    })
                  },
                )
              ],
            ),
            Expanded(
                child: Obx(
                    () => controller.screens[controller.selectedIndex.value]))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.navigationBarTheme.backgroundColor,
        onPressed: () {
          List<int> bytes = List.filled(21, 0);
          bytes[0] = 64;
          int bitPosition = 2;
          bitPosition = appendByteArray(0, [0, 0, 0, 0], bytes, bitPosition);
          btController.targetCharacteristic.value!
              .write(bytes.sublist(0, (bitPosition / 8.0).ceil()));
        },
        child: Icon(Icons.power_settings_new, color: theme.primaryColor),
      ),
    );
  }
}

class EffectsController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const SolidColorEffectScreen(),
    const RainbowEffectScreen(),
    const AuroraEffectScreen(),
    const ColoredStripsEffectScreen()
  ];
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String ssid = '';
  String password = '';

  int brightness = 255;
  int? lastSentBrightnessValue;
  Timer? sentTimer;

  var btController = Get.put(BlueToothController());
  var globalSettingsController = Get.put(GlobalSettingsController());

  DateTime lastSendTime = DateTime.now();

  void setBrightness(int value) {
    List<int> bytes = List.filled(9, 0);
    bytes[0] = 128;
    int bitPosition = 2;
    bitPosition = appendByteArray(1, [value], bytes, bitPosition);
    btController.targetCharacteristic.value!
        .write(bytes.sublist(0, (bitPosition / 8.0).ceil()));
  }

  void onBrightnessSliderChanged(double value) {
    setState(() {
      brightness = value.toInt();
    });

    sentTimer?.cancel();

    final now = DateTime.now();
    // Запускаем таймер, который выполнит проверку через 0.1 секунды
    sentTimer = Timer(Duration(milliseconds: 100), () {
      if (lastSentBrightnessValue != brightness) {
        lastSendTime = now;
        setBrightness(brightness);
        lastSentBrightnessValue = brightness;
      }
    });

    // Проверяем, прошло ли достаточно времени и отличается ли значение
    if (now.difference(lastSendTime).inMilliseconds >= 100) {
      if (lastSentBrightnessValue != brightness) {
        lastSendTime = now;
        setBrightness(brightness);
        lastSentBrightnessValue = brightness;
      }
    }
  }

  double effectChangeSeconds = 3;

  final ssidController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Общие настройки', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // DecoratedBox(
            //   decoration: BoxDecoration(
            //     border: Border.all(
            //       color: theme.primaryColorLight,
            //       width: 1,
            //     ),
            //   ),
            //   child: Column(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         const Padding(
            //           padding: EdgeInsets.all(5),
            //         ),
            //         Text('Параметры Wi-Fi',
            //             style: theme.textTheme.headlineMedium),
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             Text(
            //               'SSID',
            //               style: theme.textTheme.labelMedium,
            //             ),
            //             SizedBox(
            //               width: 300,
            //               child: TextFormField(
            //                 style: theme.textTheme.labelMedium,
            //                 controller: ssidController,
            //               ),
            //             ),
            //           ],
            //         ),
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             Text(
            //               'Пароль:',
            //               style: theme.textTheme.labelMedium,
            //             ),
            //             SizedBox(
            //               width: 300,
            //               child: TextFormField(
            //                 style: theme.textTheme.labelMedium,
            //                 controller: passwordController,
            //               ),
            //             ),
            //           ],
            //         ),
            //         const Padding(
            //           padding: EdgeInsets.all(5),
            //         ),
            //         ElevatedButton(
            //           style: theme.elevatedButtonTheme.style,
            //           child: Text(
            //             'Сохранить',
            //             style: theme.textTheme.labelSmall,
            //           ),
            //           onPressed: () => {
            //             setState(() {
            //               ssid = ssidController.text;
            //               password = passwordController.text;
            //               print('$ssid, $password');
            //             })
            //           },
            //         ),
            //         const Padding(
            //           padding: EdgeInsets.all(5),
            //         ),
            //       ]),
            // ),
            const Padding(
              padding: EdgeInsets.all(10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Яркость свечения',
                  style: theme.textTheme.headlineMedium,
                ),
                Slider(
                  value: brightness.toDouble(),
                  min: 0,
                  max: 255,
                  label: '$brightness',
                  divisions: 256,
                  activeColor: theme.primaryColor,
                  inactiveColor: theme.navigationBarTheme.backgroundColor,
                  onChanged: onBrightnessSliderChanged,
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Плавная смена (с.)',
                  style: theme.textTheme.headlineMedium,
                ),
                Checkbox(
                  value: globalSettingsController.smoothEffectChanging.value,
                  activeColor: theme.primaryColor,
                  onChanged: (value) => {
                    setState(() {
                      globalSettingsController.smoothEffectChanging.value =
                          !globalSettingsController.smoothEffectChanging.value;
                    })
                  },
                ),
                Slider(
                  value: effectChangeSeconds,
                  min: 0.1,
                  max: 5,
                  label: '$effectChangeSeconds',
                  divisions: 49,
                  activeColor: theme.primaryColor,
                  inactiveColor: theme.navigationBarTheme.backgroundColor,
                  onChanged: (newSeconds) {
                    setState(() {
                      effectChangeSeconds = double.parse(newSeconds.toStringAsFixed(1));
                    });
                  },
                  onChangeEnd: (newSeconds) {
                    setState(() {
                      effectChangeSeconds = double.parse(newSeconds.toStringAsFixed(1));
                    });
                    List<int> bytes = List.filled(9, 0);
                    bytes[0] = 128;
                    int bitPosition = 2;
                    bitPosition = appendByteArray(2, [(effectChangeSeconds * 1000).toInt()], bytes, bitPosition);
                    btController.targetCharacteristic.value!
                        .write(bytes.sublist(0, (bitPosition / 8.0).ceil()));
                  },
                ),
              ],
            )
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }
}

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          indicatorColor: theme.primaryColor,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: Icon(
                Icons.bluetooth,
                color: theme.iconTheme.color,
              ),
              icon: const Icon(Icons.bluetooth_outlined),
              label: 'Подключение',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.star,
                color: theme.iconTheme.color,
              ),
              icon: const Icon(Icons.star_outlined),
              label: 'Эффект',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.settings,
                color: theme.iconTheme.color,
              ),
              icon: const Icon(Icons.settings_outlined),
              label: 'Настройки',
            )
          ],
          backgroundColor: theme.navigationBarTheme.backgroundColor,
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class GlobalSettingsController extends GetxController {
  Rx<bool> smoothEffectChanging = Rx<bool>(true);
}

class BlueToothController extends GetxController {
  Rx<BluetoothDevice?> BTDevice = Rx<BluetoothDevice?>(null);
  Rx<BluetoothCharacteristic?> targetCharacteristic =
      Rx<BluetoothCharacteristic?>(null);
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 1.obs;

  final bluetoothController = Get.put(BlueToothController());

  final screens = [
    const BlueToothScreen(),
    const EffectsScreen(),
    const SettingsScreen()
  ];
}
