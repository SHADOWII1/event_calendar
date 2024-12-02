import 'package:flutter/material.dart';
import '../models/subscription.dart';

class SubscriptionProvider extends ChangeNotifier {
  List<Subscription> _subscriptions = [];

  List<Subscription> get subscriptions => _subscriptions;

  void addSubscription(Subscription subscription) {
    _subscriptions.add(subscription);
    notifyListeners();
  }

  void setSubscriptions(List<Subscription> subscriptions) {
    _subscriptions = subscriptions;
    notifyListeners();
  }
}
