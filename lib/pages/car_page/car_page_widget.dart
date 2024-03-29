// ignore_for_file: unnecessary_import

import 'package:moto_re_minder/edit_page/edit_page_widget.dart';
import 'package:moto_re_minder/car_object.dart';
import 'package:moto_re_minder/index.dart';
import 'package:moto_re_minder/pages/checklist_page/checklist_page.dart';
import 'package:moto_re_minder/pages/help_page/help_page.dart';
import 'package:moto_re_minder/settings_page/settings_page_widget.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'car_page_model.dart';
export 'car_page_model.dart';
import 'dart:io';

class CarPageWidget extends StatefulWidget {
  final Car? car;
  final ValueChanged<bool> onThemeChanged;
  CarPageWidget({this.car, required this.onThemeChanged});

  @override
  _CarPageWidgetState createState() => _CarPageWidgetState();
}

class _CarPageWidgetState extends State<CarPageWidget> {
  CarPageModel model = CarPageModel();

  // List of cars
  List<Car> cars = [];

  int _currentIndex = 0; // Index of the selected bottom navigation item

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HelpPage()),
        );
      }
      // Handle other index values if needed
      if (_currentIndex == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EditPageWidget(onThemeChanged: widget.onThemeChanged)),
        );
      }
      // Handle other index values if needed
    });
  }

  @override
  void initState() {
    //runs when the page is first loaded
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    // Get the path to the directory where the text files are located
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final carsDirectory = Directory('$path/cars');

    // Get all the files in the directory
    final files = carsDirectory.listSync();

    //for each car file, read the file and parse the contents into a car object
    for (final file in files) {
      final fileContent = await File(file.path).readAsString();
      final car = Car.parseCar(fileContent);
      cars.add(car);
    }

    // Update the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title at the top
        centerTitle: true,
        title: Text('Welcome to MotoReMinder!'),
        actions: <Widget>[
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("Help Page"),
              ),
              PopupMenuItem(
                value: 2,
                child: Text("Settings Page"),
              ),
            ],
            onSelected: (value) {
              // if (value == 1) {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => HelpPage()),
              //   );
              //} else
              if (value == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsPageWidget(
                          onThemeChanged: widget.onThemeChanged)),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/appIcon.png'),
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.25), // You can adjust the opacity here
              BlendMode.dstATop,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: GridView.count(
          //grid of cars
          crossAxisCount: 2, //number of cars per row
          children: cars.map((car) {
            //for each car in the list of cars, make a button that can be clicked and navigates
            //to the checklist page, passing through the car you clicked on as an object to the checklist page
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChecklistPage(
                            car: car,
                            onThemeChanged: widget.onThemeChanged,
                          )),
                );
              },
              onLongPress: () {
                //hold to edit car
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditPageWidget(
                            car: car,
                            onThemeChanged: widget.onThemeChanged,
                          )),
                );
              },
              child: Container(
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    //image: AssetImage('assets/images/appIcon.png'),
                    image: car.imageProvider ??
                        AssetImage(
                            'assets/images/appIcon.png'), // provide a default image in case car.picture is null
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                    child: Text(car.nickname,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            backgroundColor: Color.fromARGB(78, 0, 0, 0),
                            fontSize: 32))),
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
            label: 'New Car',
          ),
          // Add more BottomNavigationBarItems as needed
        ],
      ),
    );
  }
}
