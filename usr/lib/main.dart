import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const ServoApp());
}

class ServoApp extends StatelessWidget {
  const ServoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servo Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ServoControlScreen(),
      },
    );
  }
}

class ServoControlScreen extends StatefulWidget {
  const ServoControlScreen({super.key});

  @override
  State<ServoControlScreen> createState() => _ServoControlScreenState();
}

class _ServoControlScreenState extends State<ServoControlScreen> {
  // Servo state
  double _currentAngle = 90.0;
  bool _isConnected = false;
  String _statusMessage = "Disconnected";

  // Simulate connecting to an Arduino via Bluetooth
  void _toggleConnection() {
    setState(() {
      if (_isConnected) {
        _isConnected = false;
        _statusMessage = "Disconnected";
      } else {
        // Simulate connection delay
        _statusMessage = "Connecting...";
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isConnected = true;
              _statusMessage = "Connected to HC-05";
            });
          }
        });
      }
    });
  }

  // Update angle and simulate sending data
  void _updateAngle(double value) {
    setState(() {
      _currentAngle = value;
    });
    
    if (_isConnected) {
      // In a real app, you would send this value via Bluetooth here
      // e.g., bluetoothCharacteristic.write([value.toInt()]);
      debugPrint("Sending to Arduino: ${value.toInt()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arduino Servo Control'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
            onPressed: _toggleConnection,
            tooltip: _isConnected ? 'Disconnect' : 'Connect',
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _isConnected ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Visual Representation of Servo Arm
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Servo Body
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                    // Rotating Arm
                    Transform.rotate(
                      angle: (_currentAngle - 90) * (math.pi / 180),
                      child: Container(
                        width: 180,
                        height: 40,
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Center Pin
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),

                // Angle Display
                Text(
                  '${_currentAngle.toInt()}°',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                
                const SizedBox(height: 20),

                // Slider Control
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 10,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 30),
                  ),
                  child: Slider(
                    value: _currentAngle,
                    min: 0,
                    max: 180,
                    divisions: 180,
                    label: _currentAngle.round().toString(),
                    onChanged: _updateAngle,
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Presets
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPresetButton(0),
                    _buildPresetButton(90),
                    _buildPresetButton(180),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(double angle) {
    return OutlinedButton(
      onPressed: () => _updateAngle(angle),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text('${angle.toInt()}°'),
    );
  }
}
