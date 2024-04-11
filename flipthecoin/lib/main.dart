import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(CoinFlipApp());
}

class CoinFlipApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coin Flip',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: CoinFlipScreen(),
    );
  }
}

class CoinFlipScreen extends StatefulWidget {
  @override
  _CoinFlipScreenState createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends State<CoinFlipScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xRotation;
  late Animation<double> _yRotation;
  String _headLabel = 'Head';
  String _tailLabel = 'Tail';
  int _headCount = 0;
  int _tailCount = 0;
  bool _isFlipping = false;
  String _selectedCurrency = 'USD'; // Default currency
  late AudioCache _audioCache; // Audio cache for playing sound
  bool _isHead = true; // Variable to track the result of the coin flip

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _xRotation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);

    _yRotation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);

    _xRotation.addListener(() {
      setState(() {});
    });

    _yRotation.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isHead = Random().nextBool(); // Update the result of the coin flip
          if (_isHead) {
            _headCount++;
          } else {
            _tailCount++;
          }
          _isFlipping = false;

          _playCoinTossSound(); // Play sound when coin toss is completed
        });
      }
    });

    _audioCache = AudioCache(); // Initialize audio cache
    _audioCache.load('sounds/coin.mp3'); // Load coin toss sound
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCoin() {
    if (!_isFlipping) {
      _isFlipping = true;
      _controller.forward(from: 0.0);
    }
  }

  void _resetCounters() {
    setState(() {
      _headCount = 0;
      _tailCount = 0;
    });
  }

  void _changeCurrency(String newCurrency) {
    setState(() {
      _selectedCurrency = newCurrency;
    });
    Navigator.pop(context); // Close the drawer
  }

  // void _playCoinTossSound() {
  //   _audioCache.play('sounds/coin.mp3'); // Play the coin toss sound
  // }

  void _playCoinTossSound() async {
  try {
    await _audioCache.load('sounds/coin.mp3'); // Pre-load the sound file
    await _audioCache.play('sounds/coin.mp3'); // Play the coin toss sound
  } catch (e) {
    print('Error playing sound: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Flip'),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.currency_exchange),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blue[50],
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 48, 48, 48),
                ),
                child: Center(
                  child: Text(
                    'Choose Currency',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: const Text('USD'),
                onTap: () {
                  _changeCurrency('USD');
                },
              ),
              ListTile(
                title: const Text('EUR'),
                onTap: () {
                  _changeCurrency('EUR');
                },
              ),
              ListTile(
                title: const Text('INR'),
                onTap: () {
                  _changeCurrency('INR');
                },
              ),
              // Add more currency options here
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Transform(
                    transform: Matrix4.rotationX(_xRotation.value)
                      ..rotateY(_yRotation.value),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/${_selectedCurrency.toLowerCase()}/${_isHead ? 'head' : 'tail'}.jpeg',
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _flipCoin,
                    child: const Text('TOSS'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resetCounters,
                    child: const Text('Reset Counters'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$_headLabel: $_headCount',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '$_tailLabel: $_tailCount',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Customize Labels: '),
                      const SizedBox(height: 10),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _headLabel = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter Head Label',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _tailLabel = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter Tail Label',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100), // Added extra space to accommodate keyboard
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}