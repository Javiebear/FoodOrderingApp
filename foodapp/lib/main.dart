import 'package:flutter/material.dart';
import 'foodDatabaseHelper.dart';
import 'package:flutter/services.dart';
import 'orderPlanPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering',
      theme: ThemeData(
        // This is the theme of the application.

        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFDED0A4)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Food Ordering'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _food = []; // List to store food table data

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // Initialize the database and fetch data
  }

  // initializing the database
  Future<void> _initializeDatabase() async {

    // getting the database in the imported file
    final dbHelper = DatabaseHelper();

    // mapping all items in the table to the list
    List<Map<String, dynamic>> foodItems = await dbHelper.getAllFoodItems();

    setState(() {
      _food = foodItems;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            // Row with "List of Food" title and "View Order Plan" button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "List of Food",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // navigating the user to view the order plan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderPlanPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "View Order Plan",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Adds spacing between title and content

            // Check if the list is empty
            _food.isEmpty
            // if list is empty
            ? const Text('Nothing has been loaded')

            : Expanded(
              // Container will store all the food items if the list isn't empty
              child:Container(
                // Appearance of the container
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4, 
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                // Adjusting the spacing in the container
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(20),

                child: ListView.builder(
                  shrinkWrap: true, // Fits content
                  physics: const BouncingScrollPhysics(), // Stretches and bounces items on scroll

                  // Setting up to get the item from the list
                  itemCount: _food.length,
                  itemBuilder: (context, index) {
                    final item = _food[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),

                      // Making the list items have a background
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),

                        // Displaying the list
                        child: ListTile(
                          title: Text(
                            item['itemName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '\$${item['cost'].toStringAsFixed(2)}',
                          ),
                          // Adding a select button to the right side 
                          trailing: TextButton(
                            child: const Text(
                                "Select",
                                style: TextStyle(color: Colors.blue),
                              ),                        
                            onPressed: () {
                              // Pop up that displays the item with entry values for date and value
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  TextEditingController _quantityController = TextEditingController(); // variable to store the quantity of items
                                  DateTime? dateSelected; // Variable to store the selected date
                                  TextEditingController _dateController = TextEditingController();

                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min, // Makes the dialog size adjust to content
                                      children: [
                                        // Display the cost of the item
                                        Text(item['itemName']),
                                        Text('Cost: \$${item['cost'].toStringAsFixed(2)}'),
                                        
                                        const SizedBox(height: 10), // spacer

                                        // getting the number target cost per day with the quantity
                                        TextField(
                                          controller: _quantityController,

                                          // enabling on number inputs
                                          keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly, 
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: "Target Quantity",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),

                                        const SizedBox(height: 10),
                                        
                                        // Selecting a date for the input
                                        GestureDetector(
                                          onTap: () async {
                                            // Show the date picker when the user taps on the field
                                            DateTime? date = await showDatePicker(
                                              context: context,
                                              // setting up variables for the calander and initial date selected
                                              initialDate: dateSelected ?? DateTime.now(), 
                                              firstDate: DateTime(2024), 
                                              lastDate: DateTime(3000),
                                            );

                                            // updating the value of the user selected date
                                            if (date != null) {
                                              setState(() {
                                                dateSelected = date;
                                                _dateController.text = '${dateSelected!.toLocal()}'.split(' ')[0]; // Update text field
                                              });
                                            }
                                          },

                                          // setting up the input for the date
                                          child: AbsorbPointer(
                                            child: TextField(
                                              controller: _dateController,
                                              decoration: const InputDecoration(
                                                labelText: 'SELECT DATE',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {

                                          // check if the fields are inputted
                                          if (dateSelected != null && _quantityController.text.isNotEmpty){

                                            // getting the values to input to the order table
                                            final dbHelper = DatabaseHelper();
                                            int targetQuantity = int.tryParse(_quantityController.text) ?? 0;
                                            double cost = item['cost'];
                                            dbHelper.insertOrder(targetQuantity * cost, dateSelected.toString(), item['id']);

                                            Navigator.of(context).pop(); // Close the dialog
                                          }
                                          print("not working bro");
                                        },
                                        child: const Text('submit'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
