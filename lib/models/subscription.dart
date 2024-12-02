
class Subscription {
  final int id;
  final String matriculationNumber;
  final String trainingCode;
  final String subscriptionDate;
  final String status;

  Subscription({
    required this.id,
    required this.matriculationNumber,
    required this.trainingCode,
    required this.subscriptionDate,
    required this.status,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as int,
      matriculationNumber: map['matriculation_number'] as String,
      trainingCode: map['training_code'] as String,
      subscriptionDate: map['subscription_date'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matriculation_number': matriculationNumber,
      'training_code': trainingCode,
      'subscription_date': subscriptionDate,
      'status': status,
    };
  }
}
