import 'package:flutter/material.dart';
import 'package:foodapp/main.dart';
import 'foodDatabaseHelper.dart'; // Assuming this is where DatabaseHelper is defined
import 'package:flutter/services.dart';

class OrderPlanPage extends StatefulWidget {
  const OrderPlanPage({super.key});

  @override
  _OrderPlanPageState createState() => _OrderPlanPageState();
}

class _OrderPlanPageState extends State<OrderPlanPage> {
  List<Map<String, dynamic>> _orders = []; // list to store orderplan table data
  List<Map<String, dynamic>> _food = []; // List to store food table data
  TextEditingController _searchController = TextEditingController(); // Search bar controller
  List<Map<String, dynamic>> _queriedOrders = []; // Filtered list for display

  @override
  // on initialization, the database is created and a listener is put with the a list to listen for any changes to the search bar
  void initState() {
    super.initState();
    _initializeDatabase(); 
    _searchController.addListener(_updateOrders); 
  }

  // method to populate database
  Future<void> _initializeDatabase() async {
    final dbHelper = DatabaseHelper();

    // populating the lists 
    List<Map<String, dynamic>> foodItems = await dbHelper.getAllFoodItems(); 
    List<Map<String, dynamic>> orderPlanItems = await dbHelper.getAllOrderPlans(); 

    setState(() {
      _orders = orderPlanItems;
      _food = foodItems;
      _queriedOrders = orderPlanItems; // Initialize filtered orders with the full list
    });
  }


  // Method to load orders from the database with a search
  Future<void> _updateOrders() async {
    String query = _searchController.text.toLowerCase(); // obtaining the query in the search bar

    final dbHelper = DatabaseHelper();
    
    // query the database
    List<Map<String, dynamic>> updatedOrderList = await dbHelper.getSearchedOrderList(query); 

    setState(() {
      _queriedOrders = _orders
          .where((order) =>
              order['itemName'].toString().toLowerCase().contains(query))
          .toList();
    });

  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Food Ordering"),
      ),
      body: Center(
        child: Column(
          children: [
            // Row with "List of Food" title and "View Order Plan" button
            Row(
              children: [
                const Text(
                  "List of Order Plans",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Adds spacing between title and content
            
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20), // Adds spacing between title and content


            // Check if the list is empty
            _queriedOrders.isEmpty
            // if list is empty
            ? const Text('Nothing has been found or loaded')

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
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final item = _orders[index];
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
                            item['itemName'], // Display the item name
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Aligning the text to the left
                            children: [
                              Text(
                                '\$${item['cost'].toStringAsFixed(2)}', // Display the cost
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Quantity: ${item['targetCost']}', // Display the quantity
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Date: ${item['date']}', // Display the date
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
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
                                            dbHelper.updateOrderPlan(item['id'],targetQuantity * cost, dateSelected.toString());

                                          // updating the list
                                          setState(() {
                                            _orders.removeWhere((order) => order['id'] == item['id']);
                                          });

                                            Navigator.of(context).pop(); // Close the dialog
                                          }
                                        },
                                        child: const Text('submit'),
                                      ),

                                      const SizedBox(height: 10), // Adds spacing between title and content

                                      TextButton(
                                        onPressed: () async {
                                          final dbHelper = DatabaseHelper();

                                          // Call the delete method to remove the item
                                          int result = await dbHelper.deleteOrderPlan(item['id']);

                                          // updating the list
                                          setState(() {
                                            _orders.removeWhere((order) => order['id'] == item['id']);
                                          });
                                            
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
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