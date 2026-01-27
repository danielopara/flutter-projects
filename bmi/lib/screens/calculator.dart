import 'package:bmi/data/enums/gender.dart';
import 'package:bmi/models/bmi_model.dart';
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
  String _name = '';
  double _weight = 0.0;
  double _height = 0.0;
  int _age = 0;
  final _bmi = 0.0;

  List<BmiModel> bmiList = [
    BmiModel(
      id: DateTime.now().toString(),
      name: 'John',
      weight: 23.4,
      height: 172.2,
      gender: Genders.male,
      age: 20,
      bmi: 24,
      status: 'Normal',
    ),
  ];

  String _getAgeAdjustedRating(double bmi, int age) {
    if (age < 18) return "Consult Pediatric Chart"; // BMI for kids is different

    if (age >= 19 && age <= 24) {
      return (bmi >= 19 && bmi <= 24) ? "Normal" : _getStandardRating(bmi);
    }
    if (age >= 25 && age <= 34) {
      return (bmi >= 20 && bmi <= 25) ? "Normal" : _getStandardRating(bmi);
    }
    if (age >= 35 && age <= 44) {
      return (bmi >= 21 && bmi <= 26) ? "Normal" : _getStandardRating(bmi);
    }
    if (age >= 45 && age <= 54) {
      return (bmi >= 22 && bmi <= 27) ? "Normal" : _getStandardRating(bmi);
    }
    if (age >= 55 && age <= 64) {
      return (bmi >= 23 && bmi <= 28) ? "Normal" : _getStandardRating(bmi);
    }
    if (age >= 65) {
      return (bmi >= 24 && bmi <= 29) ? "Normal" : _getStandardRating(bmi);
    }
    return _getStandardRating(bmi);
  }

  String _getStandardRating(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25.0) return "Normal";
    if (bmi < 30.0) return "Overweight";
    return "Obese";
  }

  void _showResultDialog(double bmi, String rating) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hello: $_name!"),
        content: Text(
          "Your BMI is ${bmi.toStringAsFixed(1)}\n"
          "Status: $rating",
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _addBMI(String status, double bmiResult) {
    setState(() {
      bmiList.add(
        BmiModel(
          id: DateTime.now().toString(),
          name: _name,
          age: _age,
          weight: _weight,
          height: _height,
          status: status,
          gender: selectedGender!,
          bmi: bmiResult,
        ),
      );
    });
  }

  void _submitForm() {
    bool isFormValid = _formKey.currentState!.validate();

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a Gender'),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    if (isFormValid) {
      _formKey.currentState!.save();
      double heightInMeters = _height / 100;
      double bmiResult = _weight / (heightInMeters * heightInMeters);
      print("Age: $_age");

      String rating = _getAgeAdjustedRating(bmiResult, _age);

      _addBMI(rating, bmiResult);

      print(bmiList);

      _showResultDialog(bmiResult, rating);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BMI Calculator")),
      drawer: AppDrawer(widget: widget, bmiHistory: bmiList),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
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
                        maxLength: 30,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a valid name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value!;
                        },
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
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    double.tryParse(value)! <= 0 ||
                                    double.tryParse(value) == null) {
                                  return 'Enter a validated weight';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _weight = double.parse(value!);
                              },
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
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    double.tryParse(value)! <= 0 ||
                                    double.tryParse(value) == null) {
                                  return 'Enter a validated height';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _height = double.parse(value!);
                              },
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
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value)! <= 0 ||
                              int.tryParse(value) == null) {
                            return 'Enter a validated age';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _age = int.parse(value!);
                        },
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
                            onPressed: _submitForm,
                            child: const Text('Submit'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              _formKey.currentState!.reset();
                            },
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
        ),
      ),
    );
  }
}

// Drawer

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.widget, required this.bmiHistory});

  final Calculator widget;
  final List<BmiModel> bmiHistory;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: ListTile(
                title: const Text(
                  'BMI History',
                  style: TextStyle(fontSize: 24),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          SwitchListTile(
            title: const Text('Dark Mode'),
            value: widget.isDarkMode,
            onChanged: (value) => widget.onThemeToggle(),
          ),

          const Divider(),
          Expanded(
            child: bmiHistory.isEmpty
                ? const Center(child: Text('No history yet!'))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: bmiHistory.length,
                    itemBuilder: (ctx, index) {
                      final item = bmiHistory[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.status == 'Normal'
                              ? Colors.green
                              : Colors.orange,
                          child: Text(
                            item.bmi.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text("${item.name}'s ${item.status}"),
                        subtitle: Text(
                          'Weight: ${item.weight}kg | Age: ${item.age}',
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
