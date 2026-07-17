import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'env.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'APP_NAME: ${EnvironmentConfig.APP_NAME}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'APP_SUFFIX: ${EnvironmentConfig.APP_SUFFIX}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Package Name',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  FutureBuilder<PackageInfo>(
                    future: _getPackageInfo(),
                    builder: (BuildContext context,
                        AsyncSnapshot<PackageInfo> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('ERROR');
                      } else if (!snapshot.hasData) {
                        return const Text('Loading...');
                      }

                      final data = snapshot.data!;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('App Name: ${data.appName}'),
                          Text('Package Name: ${data.packageName}'),
                          Text('Version: ${data.version}'),
                          Text('Build Number: ${data.buildNumber}'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
