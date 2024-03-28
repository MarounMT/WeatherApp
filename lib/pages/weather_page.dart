import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/services/weather_service.dart';
import '../models/weather_model.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('d48fd97064a6408f8ed110923241403');
  Weather? _weather;
  late Timer _timer;
  late DateTime _currentTime;
  late List<String> _locations;
  late String _selectedLocation;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _currentTime = DateTime.now();
    _locations = ['Current Location', 'New York', 'London', 'Paris'];
    _selectedLocation = 'Current Location';
    // Update the clock every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  _fetchWeather() async {
    String cityName = _selectedLocation == 'Current Location' ? await _weatherService.getCurrentCity() : _selectedLocation;
    try {
      final weather = await _weatherService.getWeatherByCity(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'Sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'haze':
      case 'mist':
      case 'smoke':
        return 'Haze.json';
      case 'clouds':
      case 'dust':
      case 'fog':
        return 'Cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'Rainy.json';
      case 'thunderstorm':
        return 'Thunder.json';
      case 'clear':
        return 'Sunny.json';
      default:
        return 'Sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLocation = newValue!;
                  _fetchWeather();
                });
              },
              items: _locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(_weather?.cityName ?? "loading city.."),
            Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
            Text('${_weather?.temperature.round()}°C'),
            Text(_weather?.mainCondition ?? ""),
            SizedBox(height: 20),
            Text(
              '${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
