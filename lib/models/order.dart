// OrderItem model
import 'package:flutter_shop/models/customer.dart';
import 'package:flutter_shop/models/product.dart';

class OrderItem {
  final Product product;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItem({
    required this.product,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product.fromJson(json['productId']),
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      subtotal: json['subtotal'].toDouble(),
    );
  }
}

// OrderDetail model
class OrderDetail {
  final String id;
  final String orderId;
  final List<OrderItem> items;

  OrderDetail({required this.id, required this.orderId, required this.items});

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['_id'],
      orderId: json['orderId'],
      items:
          (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(),
    );
  }
}

// Order model
class Order {
  final String id;
  final String customerId;
  final Customer customer;
  final String paymentMethod;
  final double vat;
  final String status;
  final OrderDetail orderDetail;

  Order({
    required this.id,
    required this.customerId,
    required this.customer,
    required this.paymentMethod,
    required this.vat,
    required this.status,
    required this.orderDetail,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['order']['_id'],
      customerId: json['order']['customerId'],
      customer: Customer.fromJson(json['order']['customer']),
      paymentMethod: json['order']['paymentMethod'],
      vat: json['order']['vat'].toDouble(),
      status: json['order']['status'],
      orderDetail: OrderDetail.fromJson(json['orderDetail']),
    );
  }
}
