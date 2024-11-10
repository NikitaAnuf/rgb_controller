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
            )
        ),
        primaryColor: const Color.fromARGB(255, 0, 73, 183),
        textTheme: const TextTheme(
          labelSmall: TextStyle(
            color: Colors.white,
          )
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

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
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
                  devices[index].platformName == '' ? 'Device name undefined' : devices[index].platformName,
                  style: const TextStyle(color: Colors.black),
                ),
                subtitle: Text(devices[index].remoteId.toString()),
                onTap: () {
                  print('Device tapped');
                });
          },
        ),
      // bottomNavigationBar: const NavigationMenu(),
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
            onDestinationSelected: (index) => controller.selectedIndex.value = index,
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
                  Icons.list,
                  color: theme.iconTheme.color,
                ),
                icon: const Icon(Icons.list_outlined),
                label: 'Режимы',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.settings,
                  color: theme.iconTheme.color,
                ),
                icon: const Icon(Icons.settings_outlined),
                label: 'Настройки',
              ),
            ],
          ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;

  final screens = [const BlueToothScreen(), Container(color: Colors.blue), Container(color: Colors.red)];
}