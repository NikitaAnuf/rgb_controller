import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

class ModesScreen extends StatefulWidget {
  const ModesScreen({super.key});

  @override
  State<ModesScreen> createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Режим работы RGB-ленты',
            style: theme.appBarTheme.titleTextStyle),
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
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.primaryColorLight,
                  width: 1,
                ),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Параметры Wi-Fi',
                        style: theme.textTheme.headlineMedium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'SSID:',
                          style: theme.textTheme.labelMedium,
                        ),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            initialValue: 'SSID',
                            style: theme.textTheme.labelMedium,
                            onFieldSubmitted: (text) => {print("$text")},
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Пароль:',
                          style: theme.textTheme.labelMedium,
                        ),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            initialValue: 'Пароль',
                            style: theme.textTheme.labelMedium,
                            onFieldSubmitted: (text) => {print("$text")},
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: theme.elevatedButtonTheme.style,
                      child: Text(
                        'Сохранить',
                        style: theme.textTheme.labelSmall,
                      ),
                      onPressed: () => {print('Pressed')},
                    )
                  ]),
            ),
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



void sendBytes(List<int> byteArray, int size)
{
  Get.put(BlueToothController()).targetCharacteristic.value!.write(byteArray.sublist(0, size));
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
    BlueToothScreen(),
    Container(),
    const ModesScreen()
  ];
}