import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MaterialApp(home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _interestRate = TextEditingController();
  final TextEditingController _months = TextEditingController();
  double? interest;
  double? total;

  @override
  void dispose() {
    _amount.dispose();
    _interestRate.dispose();
    _months.dispose();
    super.dispose();
  }

  void calculate() {
    final amount = double.tryParse(_amount.text);
    final interestRate = double.tryParse(_interestRate.text);
    final period = int.tryParse(_months.text);

    if (amount == null || interestRate == null || period == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers for all fields'),
        ),
      );
      return;
    }
    final calculateInterestRate = (interestRate / 100 / 12) * period;
    final calculateInterest = calculateInterestRate * (amount);
    setState(() {
      interest = calculateInterest;
      total = (amount) + interest!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.notes, size: 25, color: Colors.white),
        toolbarHeight: 30,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 0, 84, 152),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.info, size: 25, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: body(),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.grey[300],
        child: Column(
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 84, 152),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(100),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Fixed Deposit',
                        style: GoogleFonts.robotoMono(
                          fontSize: 35,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Calculator',
                        style: GoogleFonts.robotoMono(
                          fontSize: 35,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 10, 40, 0),
              child: Column(
                children: [
                  input(
                    title: 'Amount',
                    controller: _amount,
                    hint: 'Enter Amount',
                  ),
                  input(
                    title: 'Rate %',
                    controller: _interestRate,
                    hint: 'Enter interest',
                  ),
                  input(
                    title: 'Months',
                    controller: _months,
                    hint: 'Enter Period (in months)',
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      calculate();
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 84, 152),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          'CALCULATE',
                          style: GoogleFonts.robotoMono(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  interest == null
                      ? SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Interest: NGN ${interest!.toStringAsFixed(2)}",
                              style: GoogleFonts.robotoMono(fontSize: 20),
                            ),
                            Text(
                              "Total: NGN ${total!.toStringAsFixed(2)}",
                              style: GoogleFonts.robotoMono(fontSize: 20),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget input({
    required String title,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.robotoMono(fontSize: 16)),
        SizedBox(height: 20),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
              hint: Text(hint),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
