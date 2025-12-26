import 'dart:convert';
import 'dart:io';

class Order {
  String item;
  String itemName;
  double price;
  String currency;
  int quantity;

  Order(this.item, this.itemName, this.price, this.currency, this.quantity);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      json['Item'].toString(),
      json['ItemName'].toString(),
      (json['Price'] as num).toDouble(),
      json['Currency'].toString(),
      (json['Quantity'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'Item': item,
        'ItemName': itemName,
        'Price': price,
        'Currency': currency,
        'Quantity': quantity,
      };
}

void main() async {
  const jsonString =
      '[{"Item":"A1000","ItemName":"Iphone 15","Price":1200,"Currency":"USD","Quantity":1},'
      '{"Item":"A1001","ItemName":"Iphone 16","Price":1500,"Currency":"USD","Quantity":1}]';

  final List<dynamic> data = jsonDecode(jsonString);
  final List<Order> orders = data.map((e) => Order.fromJson(e)).toList();

  while (true) {
    print('\n1) Show orders');
    print('2) Add order');
    print('3) Search by ItemName');
    print('4) Exit');
    stdout.write('Choose: ');
    final choice = stdin.readLineSync();

    if (choice == '1') {
      showOrders(orders);
    } else if (choice == '2') {
      final newOrder = readOrderFromStdin();
      orders.add(newOrder);
      await saveToFile(orders);
      print('Added and saved to order.json');
    } else if (choice == '3') {
      stdout.write('Keyword: ');
      final keyword = (stdin.readLineSync() ?? '').toLowerCase();
      final results = orders
          .where((o) => o.itemName.toLowerCase().contains(keyword))
          .toList();
      showOrders(results);
    } else if (choice == '4') {
      break;
    } else {
      print('Invalid choice');
    }
  }
}

void showOrders(List<Order> orders) {
  if (orders.isEmpty) {
    print('No orders');
    return;
  }
  for (int i = 0; i < orders.length; i++) {
    final o = orders[i];
    print(
        '${i + 1}. Item=${o.item}, Name=${o.itemName}, Price=${o.price} ${o.currency}, Qty=${o.quantity}');
  }
}

Order readOrderFromStdin() {
  stdout.write('Item: ');
  final item = stdin.readLineSync() ?? '';

  stdout.write('ItemName: ');
  final itemName = stdin.readLineSync() ?? '';

  stdout.write('Price: ');
  final price = double.tryParse(stdin.readLineSync() ?? '') ?? 0;

  stdout.write('Currency: ');
  final currency = stdin.readLineSync() ?? '';

  stdout.write('Quantity: ');
  final quantity = int.tryParse(stdin.readLineSync() ?? '') ?? 0;

  return Order(item, itemName, price, currency, quantity);
}

Future<void> saveToFile(List<Order> orders) async {
  final jsonList = orders.map((o) => o.toJson()).toList();
  final jsonText = const JsonEncoder.withIndent('  ').convert(jsonList);
  await File('order.json').writeAsString(jsonText);
}
