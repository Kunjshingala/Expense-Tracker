class TransactionModal {
  final String id;
  final int amount;
  final int transactionType;
  final int transactionMode;
  final String date;
  final int time;
  final int category;
  final String? description;
  final String? location;
  final String? imageUrl;

  TransactionModal({
    required this.id,
    required this.amount,
    required this.transactionType,
    required this.transactionMode,
    required this.category,
    required this.date,
    required this.time,
    required this.description,
    required this.location,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'transactionType': transactionType,
      'transactionMode': transactionMode,
      'category': category,
      'date': date,
      'time': time,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
    };
  }

  factory TransactionModal.fromMap(Map<String, dynamic> map) {
    return TransactionModal(
      id: map['id'],
      amount: map['amount'],
      transactionType: map['transactionType'],
      transactionMode: map['transactionMode'],
      date: map['date'],
      time: map['time'],
      category: map['category'],
      description: map['description'],
      location: map['location'],
      imageUrl: map['imageUrl'],
    );
  }
}
