import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Singleton pattern
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database if not created
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the database path
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'foodAppDB.db');

    // Open or create the database
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE food (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      itemName TEXT NOT NULL,
      cost REAL NOT NULL
    )
  ''');

  // Insert initial data into the `food` table
  final batch = db.batch();
  batch.insert('food', {'itemName': 'Chicken Leg', 'cost': 2.99});
  batch.insert('food', {'itemName': 'Turkey Leg', 'cost': 3.99});
  batch.insert('food', {'itemName': 'Rib Eye', 'cost': 5.99});
  batch.insert('food', {'itemName': 'Avocado', 'cost': 0.99});
  batch.insert('food', {'itemName': 'Vegetable Oil', 'cost': 1.99});
  batch.insert('food', {'itemName': 'Salt', 'cost': 1.99});
  batch.insert('food', {'itemName': 'Sugar', 'cost': 1.49});
  batch.insert('food', {'itemName': 'Potato', 'cost': 0.49});
  batch.insert('food', {'itemName': 'Tomato', 'cost': 0.49});
  batch.insert('food', {'itemName': 'Pork', 'cost': 3.99});
  batch.insert('food', {'itemName': 'Venison', 'cost': 7.99});
  batch.insert('food', {'itemName': 'Roe', 'cost': 14.99});
  batch.insert('food', {'itemName': 'Black Truffle', 'cost': 99.99});
  batch.insert('food', {'itemName': 'Mushroom', 'cost': 2.99});
  batch.insert('food', {'itemName': 'Salmon', 'cost': 4.99});
  batch.insert('food', {'itemName': 'Lobster', 'cost': 6.99});
  batch.insert('food', {'itemName': 'Crab', 'cost': 9.99});
  batch.insert('food', {'itemName': 'Abalone', 'cost': 14.99});
  batch.insert('food', {'itemName': 'Beer', 'cost': 16.99});
  batch.insert('food', {'itemName': 'Wine', 'cost': 99.99});

  await batch.commit();

  // Create orderPlan table
  await db.execute('''
    CREATE TABLE orderPlan (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      targetCost INTEGER NOT NULL,
      date TEXT,
      foodID INTEGER,
      FOREIGN KEY (foodID) REFERENCES food(id)
    )
  ''');
  }

  // operations on the food Table ----------------------------

  // getting all of the items stored within the food table
  Future<List<Map<String, dynamic>>> getAllFoodItems() async {
    final db = await database;
    return db.query('food');
  } 
  // operations on orderPlan table ----------------------------

  // insertions on the orderplan table
  Future<void> insertOrder(double targetCost, String date, int foodID) async {
  final db = await database;

  await db.insert(
    'orderPlan',
    {
      'targetCost': targetCost,
      'date': date,
      'foodID': foodID, 
    },
  );
}

  // getting all of the items stored within the food table
  Future<List<Map<String, dynamic>>> getAllOrderPlans() async {
    final db = await database;

    // joining the tables
    return db.rawQuery('''
    SELECT orderPlan.id, food.itemName, food.cost, orderPlan.targetCost, orderPlan.date
    FROM orderPlan
    INNER JOIN food ON orderPlan.foodID = food.id
    ''');  
  } 

  // deleting an element within the database 
  Future<int> deleteOrderPlan(int id) async {
    final db = await database;

    return await db.delete(
      'orderPlan',  
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Updating an element within the database 
  Future<int> updateOrderPlan(int id, double quantity, String date) async {
    final db = await database;

    // mapping the new values
    Map<String, dynamic> newOrderPlan = {
      'quantity': quantity,  
      'date': date,
    };

    // updating the entry in the database
    return await db.update(
      'orderPlan', 
      newOrderPlan, 
      where: 'id = ?',  
      whereArgs: [id],
    );
  }

  // searching for an item in the database
  Future<List<Map<String, dynamic>>> getSearchedOrderList(String query) async {
  final db = await database;

  // querying the joined table with the search input 
  return db.rawQuery('''
    SELECT orderPlan.id, food.itemName, food.cost, orderPlan.targetCost, orderPlan.date
    FROM orderPlan
    INNER JOIN food ON orderPlan.foodID = food.id
    WHERE food.itemName LIKE ?
  ''', ['%$query%']);
}

}
