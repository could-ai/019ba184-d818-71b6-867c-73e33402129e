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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
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
        _statusMessage = "Scanning...";
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isConnected = true;
              _statusMessage = "Connected to HC-05";
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Connected! Ready to send commands.")),
            );
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
      debugPrint("Sending to Arduino: ${value.toInt()}");
    }
  }

  void _showSetupGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Arduino Setup Guide",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              _buildSectionTitle("1. Wiring Diagram"),
              const SizedBox(height: 8),
              _buildWiringCard(),
              
              const SizedBox(height: 24),
              
              _buildSectionTitle("2. Arduino Code"),
              const Text("Upload this sketch to your Arduino board:"),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SelectableText(
                  """#include <Servo.h>

Servo myservo;

void setup() {
  myservo.attach(9); // Servo Pin
  Serial.begin(9600); // Bluetooth Baud
}

void loop() {
  if (Serial.available() > 0) {
    int angle = Serial.read();
    if (angle >= 0 && angle <= 180) {
      myservo.write(angle);
      delay(15);
    }
  }
}""",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle("3. Troubleshooting"),
              _buildTroubleshootingItem("Servo jitters?", "Check your power supply. Servos need more current than USB can provide."),
              _buildTroubleshootingItem("No movement?", "Verify the Bluetooth TX connects to Arduino RX."),
              _buildTroubleshootingItem("Wrong angle?", "Ensure the baud rate is 9600 in both code and module."),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildWiringCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildWireRow("Servo Red (VCC)", "5V (External Power)"),
            _buildWireRow("Servo Brown (GND)", "GND"),
            _buildWireRow("Servo Orange (Signal)", "Digital Pin 9"),
            const Divider(),
            _buildWireRow("Bluetooth VCC", "5V or 3.3V"),
            _buildWireRow("Bluetooth GND", "GND"),
            _buildWireRow("Bluetooth TX", "Arduino RX"),
            _buildWireRow("Bluetooth RX", "Arduino TX"),
          ],
        ),
      ),
    );
  }

  Widget _buildWireRow(String from, String to) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(from, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Icon(Icons.arrow_right_alt, color: Colors.grey),
          Text(to, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingItem(String issue, String fix) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.help_outline, size: 20, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(text: "$issue ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: fix),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servo Controller'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: _showSetupGuide,
            tooltip: 'Arduino Code & Wiring',
          ),
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
                
                if (!_isConnected)
                  const Text(
                    "Tap the Bluetooth icon to connect",
                    style: TextStyle(color: Colors.grey),
                  ),
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
