// Customer model
class Customer {
  final Address address;
  final String name;
  final String email;
  final int phone;

  Customer({
    required this.address,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      address: Address.fromJson(json['address']),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

// Address model
class Address {
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      country: json['country'],
    );
  }
}
