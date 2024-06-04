import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Logger extends ProviderObserver{
  @override
  void didUpdateProvider(ProviderBase<Object?> provider, Object? previousValue, Object? newValue, ProviderContainer container) {
    super.didUpdateProvider(provider, previousValue, newValue, container);
    log('''Previous Value : $previousValue
    Provider : $provider
    New Value : $newValue''');
  }
}