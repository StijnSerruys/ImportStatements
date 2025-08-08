class Account {
  int? id;
  String name;
  String? accountNumber;
  String currency;
  bool isPrimary;
  double balance;
  Account({this.id, required this.name, this.accountNumber, this.currency = 'EUR', this.isPrimary = false, this.balance = 0.0});
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'account_number': accountNumber,
    'currency': currency,
    'is_primary': isPrimary ? 1 : 0,
    'balance': balance
  };
}

class Category {
  int? id;
  String name;
  double monthlyBudget;
  int? iconId;
  String? color;
  Category({this.id, required this.name, this.monthlyBudget = 0, this.iconId, this.color});
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'monthly_budget': monthlyBudget,
    'icon_id': iconId,
    'color': color
  };
}

class MappingModel {
  int? id;
  String counterparty;
  String? accountNo;
  int categoryId;
  String createdAt;
  String createdBy;
  String? lastUsedAt;
  MappingModel({this.id, required this.counterparty, this.accountNo, required this.categoryId, required this.createdAt, this.createdBy = 'user', this.lastUsedAt});
  Map<String, dynamic> toMap() => {
    'id': id,
    'counterparty': counterparty,
    'account_no': accountNo,
    'category_id': categoryId,
    'created_at': createdAt,
    'created_by': createdBy,
    'last_used_at': lastUsedAt
  };
}

class TransactionModel {
  int? id;
  int accountId;
  int? importBatchId;
  int? mappingId;
  String date;
  String description;
  double amount;
  String currency;
  String type; // 'expense' | 'income'
  int? categoryId;
  String? tags;
  String? note;
  String? photoPath;
  TransactionModel({
    this.id,
    required this.accountId,
    this.importBatchId,
    this.mappingId,
    required this.date,
    required this.description,
    required this.amount,
    this.currency = 'EUR',
    required this.type,
    this.categoryId,
    this.tags,
    this.note,
    this.photoPath
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'account_id': accountId,
    'import_batch_id': importBatchId,
    'mapping_id': mappingId,
    'date': date,
    'description': description,
    'amount': amount,
    'currency': currency,
    'type': type,
    'category_id': categoryId,
    'tags': tags,
    'note': note,
    'photo_path': photoPath
  };
}
