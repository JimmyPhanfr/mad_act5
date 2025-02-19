import 'package:flutter/material.dart';
import 'dart:async';

/*
Jimmy Phan
Richard Chai
John Rollins
*/

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  const DigitalPetApp({super.key});

  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50, energyLevel = 50;
  String gameMessage = "";
  final _textController = TextEditingController();

  Timer? _statusTimer;
  Timer? _winTimer;
  bool _isHappinessHigh = false;

  @override
  void initState() {
    super.initState();
      setState(() {
        _statusTimer = Timer.periodic(Duration(seconds: 30), (timer) {
        _decreaseStatus();
      });
    });
  }

   @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
    });
  }

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  // Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

    String _getPetMood() {
    if (happinessLevel > 70) {
      return "Happy 😄";
    } else if (happinessLevel > 50) {
      return "Neutral 😐";
    } else {
      return "Unhappy ☹️";
    }
  }

  void _decreaseStatus() {
    setState(() {
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      happinessLevel = (happinessLevel - 5).clamp(0, 100);
      energyLevel = (energyLevel - 5).clamp(0, 100);
      if (hungerLevel > 70) {
        happinessLevel = (happinessLevel - 5).clamp(0, 100);
      }
    });
     _checkGameOver();
    _checkWinCondition();
  }

  void _checkWinCondition() {
    if (happinessLevel > 80) {
      if (!_isHappinessHigh) {
        _isHappinessHigh = true;
        _winTimer = Timer(Duration(seconds: 3), () {
          _showGameMessage("You Win!");
        });
      }
    } else {
      _isHappinessHigh = false;
      _winTimer?.cancel();
    }
  }

  void _checkGameOver() {
    if (hungerLevel == 100 && happinessLevel <= 10) {
      _showGameMessage("Game Over!");
      _statusTimer?.cancel();
      _winTimer?.cancel();
    }
  }

  void _showGameMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 18.0)),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _decreaseEnergy() {
    setState(() {
      energyLevel = (energyLevel - 5).clamp(0, 100);
    });
  }


  Widget _buildEnergyBar() {
    return Column(
      children: [
        Text('Energy Level:', style: TextStyle(fontSize: 20.0)),
        SizedBox(height: 5.0),
        Container(
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: LinearProgressIndicator(
            value: energyLevel / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              energyLevel > 50 ? Colors.green : energyLevel > 20 ? Colors.orange : Colors.red,
            ),
            minHeight: 10.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Name: $petName',
              style: TextStyle(
                fontSize: 20.0,
                color: (happinessLevel > 70) ? Colors.green : (happinessLevel > 30) ? Colors.amber : Colors.red,
              ),
            ),
            TextField(
              // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Rename Pet',
                hintText: 'Choose a fun name for your pet!',
                suffixIcon: IconButton(
                  onPressed: () {
                    _textController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
             MaterialButton(
              onPressed: () {
                setState(() {
                  petName = _textController.text;
                  _textController.clear();
                });
              },
              color: Colors.blue,
              child: const Text('Rename here',
                  style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16.0),
            Text(
              'Happiness Level: $happinessLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Hunger Level: $hungerLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            Text(
              'Mood: ${_getPetMood()}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
            _buildEnergyBar(),
            DropdownButton<String>(
              items: <String>['Play Ball', 'Jump', 'Run', 'Nap'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            )
          ],
        ),
      ),
    );
  }
}
