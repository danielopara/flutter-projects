import 'package:bmi/data/enums/gender.dart';
import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });
  final bool isDarkMode;
  final void Function() onThemeToggle;

  @override
  State<StatefulWidget> createState() {
    return _CalculatorState();
  }
}

class _CalculatorState extends State<Calculator> {
  Genders? selectedGender;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BMI Calculator")),
      drawer: AppDrawer(widget: widget),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedGender = Genders.male;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: selectedGender == Genders.male
                          ? Colors.blue
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    width: 150,
                    height: 100,
                    child: const Text(
                      'Male',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedGender = Genders.female;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: selectedGender == Genders.female
                          ? const Color.fromARGB(255, 216, 8, 78)
                          : Colors.grey,
                    ),
                    width: 150,
                    height: 100,
                    child: const Text(
                      'Female',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name (Nickname)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Submit'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {},
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.widget});

  final Calculator widget;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            // decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: ListTile(
              title: const Text('BMI History', style: TextStyle(fontSize: 24)),
              trailing: IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          Divider(),
          Padding(
            padding: EdgeInsets.all(16),
            child: ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: widget.isDarkMode,
                onChanged: (value) {
                  widget.onThemeToggle();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
