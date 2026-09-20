import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

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
  final _money = NumberFormat('#,##0.00');
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
    final amount = double.tryParse(_amount.text.replaceAll(',', ''));
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
                  formatters: [ThousandsFormatter(allowFraction: true)],
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
                            "Interest: NGN ${_money.format(interest!)}",
                            style: GoogleFonts.robotoMono(fontSize: 20),
                          ),
                          Text(
                            "Total: NGN ${_money.format(total!)}",
                            style: GoogleFonts.robotoMono(fontSize: 20),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget input({
    required String title,
    required TextEditingController controller,
    required String hint,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.robotoMono(fontSize: 16)),
        SizedBox(height: 20),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            inputFormatters: formatters,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 0, 84, 152),
                  width: 2.5,
                ),
              ),
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
