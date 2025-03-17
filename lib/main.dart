import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  Map<String, dynamic>? weatherData;
  String errorMessage = '';
  String selectedCity = 'Current Location';
  final List<String> cities = [
    'Current Location',
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Sydney',
    'Dubai',
    'Singapore',
    'Hong Kong',
    'Mumbai',
    'Berlin',
    'Rome',
    'Madrid',
    'Seoul',
    'Beijing',
    'Shanghai',
    'Bangkok',
    'Kuala Lumpur',
    'Jakarta',
    'Manila',
  ];

  // City coordinates
  final Map<String, Map<String, double>> cityCoordinates = {
    'London': {'lat': 51.5074, 'lon': -0.1278},
    'New York': {'lat': 40.7128, 'lon': -74.0060},
    'Tokyo': {'lat': 35.6762, 'lon': 139.6503},
    'Paris': {'lat': 48.8566, 'lon': 2.3522},
    'Sydney': {'lat': -33.8688, 'lon': 151.2093},
    'Dubai': {'lat': 25.2048, 'lon': 55.2708},
    'Singapore': {'lat': 1.3521, 'lon': 103.8198},
    'Hong Kong': {'lat': 22.3193, 'lon': 114.1694},
    'Mumbai': {'lat': 19.0760, 'lon': 72.8777},
    'Berlin': {'lat': 52.5200, 'lon': 13.4050},
    'Rome': {'lat': 41.9028, 'lon': 12.4964},
    'Madrid': {'lat': 40.4168, 'lon': -3.7038},
    'Seoul': {'lat': 37.5665, 'lon': 126.9780},
    'Beijing': {'lat': 39.9042, 'lon': 116.4074},
    'Shanghai': {'lat': 31.2304, 'lon': 121.4737},
    'Bangkok': {'lat': 13.7563, 'lon': 100.5018},
    'Kuala Lumpur': {'lat': 3.1390, 'lon': 101.6869},
    'Jakarta': {'lat': -6.2088, 'lon': 106.8456},
    'Manila': {'lat': 14.5995, 'lon': 120.9842},
  };

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    getCurrentWeather();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getCurrentWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      double latitude;
      double longitude;

      if (selectedCity == 'Current Location') {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = 'Location permission denied. Please enable it in settings.';
            isLoading = false;
          });

          return;
        }

        Position position = await Geolocator.getCurrentPosition();
        latitude = position.latitude;
        longitude = position.longitude;
      } else {
        latitude = cityCoordinates[selectedCity]!['lat']!;
        longitude = cityCoordinates[selectedCity]!['lon']!;
      }

      const apiKey = 'Replace Actual API Key';
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
        _controller.reset();
        _controller.forward();
      } else {
        setState(() {
          errorMessage = 'Failed to load weather data. Please check your API key and internet connection.';

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  IconData _getWeatherIcon(String description) {
    description = description.toLowerCase();
    if (description.contains('clear')) {
      return Icons.wb_sunny;
    } else if (description.contains('cloud')) {
      return Icons.cloud;
    } else if (description.contains('rain')) {
      return Icons.beach_access;
    } else if (description.contains('snow')) {
      return Icons.ac_unit;
    } else if (description.contains('thunder')) {
      return Icons.flash_on;
    } else {
      return Icons.wb_sunny;
    }
  }

  Widget _buildWeatherGif(String description) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            height: 80,
            width: 80,
            child: Icon(
              _getWeatherIcon(description),
              color: Colors.white,
              size: 60,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedCity,
                                  isExpanded: true,
                                  dropdownColor: Colors.blue.shade900,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  items: cities.map((String city) {
                                    return DropdownMenuItem<String>(
                                      value: city,
                                      child: Text(city),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedCity = newValue;
                                      });
                                      getCurrentWeather();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotateAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: getCurrentWeather,
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: SpinKitDoubleBounce(
                          color: Colors.white,
                          size: 50.0,
                        ),
                      )
                    : errorMessage.isNotEmpty
                        ? Center(
                            child: Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        : weatherData == null
                            ? const Center(
                                child: Text(
                                  'No weather data available',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedBuilder(
                                        animation: _controller,
                                        builder: (context, child) {
                                          return Opacity(
                                            opacity: _fadeAnimation.value,
                                            child: Transform.translate(
                                              offset: Offset(
                                                  0, _slideAnimation.value),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    weatherData!['name'],
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${weatherData!['main']['temp'].round()}°C',
                                                        style: const TextStyle(
                                                          fontSize: 48,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      _buildWeatherGif(
                                                          weatherData![
                                                                  'weather'][0]
                                                              ['description']),
                                                    ],
                                                  ),
                                                  Text(
                                                    weatherData!['weather'][0]
                                                        ['description'],
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 40),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildWeatherInfo(
                                            'UV Index',
                                            '${weatherData!['main']['temp'].round()}°C',
                                            Icons.wb_sunny,
                                          ),
                                          _buildWeatherInfo(
                                            'Humidity',
                                            '${weatherData!['main']['humidity']}%',
                                            Icons.water_drop,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildWeatherInfo(
                                            'Wind',
                                            '${weatherData!['wind']['speed']} m/s',
                                            Icons.air,
                                          ),
                                          _buildWeatherInfo(
                                            'Feels Like',
                                            '${weatherData!['main']['feels_like'].round()}°C',
                                            Icons.thermostat,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildWeatherInfo(
                                            'Pressure',
                                            '${weatherData!['main']['pressure']} hPa',
                                            Icons.speed,
                                          ),
                                          _buildWeatherInfo(
                                            'Visibility',
                                            '${(weatherData!['visibility'] / 1000).toStringAsFixed(1)} km',
                                            Icons.visibility,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 40),
                                    ],
                                  ),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
