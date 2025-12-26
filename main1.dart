import 'dart:convert';
import 'dart:io';

class Order {
  Order({
    required this.item,
    required this.itemName,
    required this.price,
    required this.currency,
    required this.quantity,
  });

  final String item;
  final String itemName;
  final double price;
  final String currency;
  final int quantity;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      item: json['Item'] as String,
      itemName: json['ItemName'] as String,
      price: (json['Price'] as num).toDouble(),
      currency: json['Currency'] as String,
      quantity: (json['Quantity'] as num).toInt(),
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

void main() {
  final jsonText = File('initial_orders.json').readAsStringSync();
  final rawList = jsonDecode(jsonText) as List<dynamic>;
  final orders = rawList
      .map((item) => Order.fromJson(item as Map<String, dynamic>))
      .toList();

  print('Danh sách đơn hàng ban đầu:');
  printOrders(orders);

  print('\nNhập đơn hàng mới:');
  final newOrder = readOrderFromInput();
  orders.add(newOrder);

  print('\nDanh sách sau khi thêm:');
  printOrders(orders);

  stdout.write('\nNhập từ khóa ItemName để tìm: ');
  final keyword = stdin.readLineSync()?.trim().toLowerCase() ?? '';
  final found = orders.where(
    (order) => order.itemName.toLowerCase().contains(keyword),
  );
  print('\nKết quả tìm kiếm:');
  if (found.isEmpty) {
    print('Không tìm thấy đơn hàng nào.');
  } else {
    printOrders(found.toList());
  }

  final file = File('order.json');
  final output = jsonEncode(orders.map((o) => o.toJson()).toList());
  file.writeAsStringSync(output);
  print('\nĐã lưu vào file order.json');
}

void printOrders(List<Order> orders) {
  for (final order in orders) {
    print('Item: ${order.item}, '
        'Tên: ${order.itemName}, '
        'Giá: ${order.price}, '
        'Tiền tệ: ${order.currency}, '
        'Số lượng: ${order.quantity}');
  }
}

Order readOrderFromInput() {
  stdout.write('Item: ');
  final item = stdin.readLineSync() ?? '';

  stdout.write('ItemName: ');
  final itemName = stdin.readLineSync() ?? '';

  stdout.write('Price: ');
  final price = double.parse(stdin.readLineSync() ?? '0');

  stdout.write('Currency: ');
  final currency = stdin.readLineSync() ?? '';

  stdout.write('Quantity: ');
  final quantity = int.parse(stdin.readLineSync() ?? '0');

  return Order(
    item: item,
    itemName: itemName,
    price: price,
    currency: currency,
    quantity: quantity,
  );
}
