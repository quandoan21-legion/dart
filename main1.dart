import 'dart:convert';
import 'dart:io';

class Order {
  final String item;
  final String itemName;
  final double price;
  final String currency;
  final int quantity;

  Order({
    required this.item,
    required this.itemName,
    required this.price,
    required this.currency,
    required this.quantity,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final num rawPrice = (json['Price'] as num?) ?? 0;
    return Order(
      item: (json['Item'] ?? '').toString(),
      itemName: (json['ItemName'] ?? '').toString(),
      price: rawPrice.toDouble(),
      currency: (json['Currency'] ?? '').toString(),
      quantity: (json['Quantity'] as num?)?.toInt() ?? 0,
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

  final orders = parseOrders(jsonString);

  print('\n=== DANH SÁCH ĐƠN HÀNG BAN ĐẦU ===');
  printOrdersTable(orders);

  while (true) {
    print('\n=== MENU ===');
    print('1. In danh sách đơn hàng');
    print('2. Thêm đơn hàng mới (Insert)');
    print('3. Tìm kiếm theo ItemName (Search)');
    print('4. Thoát');
    stdout.write('Chọn (1-4): ');
    final choice = (stdin.readLineSync() ?? '').trim();

    if (choice == '1') {
      printOrdersTable(orders);
    } else if (choice == '2') {
      final newOrder = inputOrderFromStdin();
      orders.add(newOrder);

      print('\nDa them don hang.');
      printOrdersTable(orders);

      await saveOrdersToFile(orders, 'order.json');
      print('Da luu danh sach vao file: order.json');
    } else if (choice == '3') {
      stdout.write('Nhap tu khoa ItemName can tim: ');
      final keyword = (stdin.readLineSync() ?? '').trim();

      final results = searchByItemName(orders, keyword);
      print('\n=== KET QUA TIM KIEM: "$keyword" ===');
      if (results.isEmpty) {
        print('Khong tim thay don hang nao.');
      } else {
        printOrdersTable(results);
      }
    } else if (choice == '4') {
      print('Bye!');
      break;
    } else {
      print('Lua chon khong hop le. Vui long chon 1-4.');
    }
  }
}

List<Order> parseOrders(String jsonString) {
  final dynamic decoded = jsonDecode(jsonString);
  if (decoded is! List) return [];
  return decoded
      .whereType<Map<String, dynamic>>()
      .map((e) => Order.fromJson(e))
      .toList();
}

Order inputOrderFromStdin() {
  String readNonEmpty(String label) {
    while (true) {
      stdout.write(label);
      final s = (stdin.readLineSync() ?? '').trim();
      if (s.isNotEmpty) return s;
      print('Khong duoc de trong.');
    }
  }

  int readInt(String label) {
    while (true) {
      stdout.write(label);
      final s = (stdin.readLineSync() ?? '').trim();
      final v = int.tryParse(s);
      if (v != null) return v;
      print('Vui long nhap so nguyen hop le.');
    }
  }

  double readDouble(String label) {
    while (true) {
      stdout.write(label);
      final s = (stdin.readLineSync() ?? '').trim();
      final v = double.tryParse(s);
      if (v != null) return v;
      print('Vui long nhap so hop le (vi du: 1200 hoac 1200.5).');
    }
  }

  final item = readNonEmpty('Item (vi du A1002): ');
  final itemName = readNonEmpty('ItemName (ten san pham): ');
  final price = readDouble('Price: ');
  final currency = readNonEmpty('Currency (vi du USD): ');
  final quantity = readInt('Quantity: ');

  return Order(
    item: item,
    itemName: itemName,
    price: price,
    currency: currency,
    quantity: quantity,
  );
}

List<Order> searchByItemName(List<Order> orders, String keyword) {
  final key = keyword.trim().toLowerCase();
  if (key.isEmpty) return [];
  return orders.where((o) => o.itemName.toLowerCase().contains(key)).toList();
}

Future<void> saveOrdersToFile(List<Order> orders, String fileName) async {
  final listJson = orders.map((o) => o.toJson()).toList();
  final pretty = const JsonEncoder.withIndent('  ').convert(listJson);
  final file = File(fileName);
  await file.writeAsString(pretty, flush: true);
}

void printOrdersTable(List<Order> orders) {
  if (orders.isEmpty) {
    print('(Danh sach rong)');
    return;
  }

  const headers = ['Item', 'ItemName', 'Price', 'Currency', 'Qty'];
  final rows = orders.map((o) {
    final priceStr = o.price.toStringAsFixed(o.price % 1 == 0 ? 0 : 2);
    return [o.item, o.itemName, priceStr, o.currency, o.quantity.toString()];
  }).toList();

  final colCount = headers.length;
  final widths = List<int>.generate(colCount, (i) => headers[i].length);

  for (final r in rows) {
    for (int i = 0; i < colCount; i++) {
      if (r[i].length > widths[i]) widths[i] = r[i].length;
    }
  }

  String pad(String s, int w) => s.padRight(w);

  final sep = widths.map((w) => '-' * (w + 2)).join('+');
  print('\n$sep');
  print(widths
      .asMap()
      .entries
      .map((e) => ' ${pad(headers[e.key], e.value)} ')
      .join('|'));
  print(sep);

  for (final r in rows) {
    print(widths
        .asMap()
        .entries
        .map((e) => ' ${pad(r[e.key], e.value)} ')
        .join('|'));
  }
  print(sep);
}
