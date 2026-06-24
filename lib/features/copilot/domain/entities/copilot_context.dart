/// Grounding context handed to the [AiProvider] so answers can reference the
/// user's actual motorcycle and maintenance state. Built from the garage +
/// maintenance providers; provider-agnostic.
class CopilotContext {
  const CopilotContext({
    this.bikeName,
    this.productionYear,
    this.mileage,
    this.nextServiceLabel,
    this.nextServiceMessage,
  });

  final String? bikeName;
  final int? productionYear;
  final int? mileage;
  final String? nextServiceLabel;
  final String? nextServiceMessage;

  bool get hasBike => bikeName != null;

  /// A Persian system preamble describing MotoVerse + the rider's bike. A real
  /// provider would send this as the system prompt.
  String toSystemPreamble() {
    final buffer = StringBuffer()
      ..writeln('تو دستیار هوشمند «موتو‌کوپایلت» در اپ MotoVerse هستی؛ '
          'همراه موتورسواران ایران. پاسخ‌ها کوتاه، دقیق، عملی و به زبان '
          'فارسی محاوره‌ای مودبانه باشد. در نگهداری، عیب‌یابی، بیمه، خرید و '
          'قطعات کمک کن و در موارد ایمنی‌محور توصیه به مراجعه به متخصص کن.');
    if (hasBike) {
      buffer.write('موتور کاربر: $bikeName');
      if (productionYear != null) buffer.write(' مدل $productionYear');
      if (mileage != null) buffer.write('، کیلومتر $mileage');
      buffer.writeln('.');
      if (nextServiceMessage != null) {
        buffer.writeln('وضعیت سرویس بعدی: $nextServiceLabel — $nextServiceMessage.');
      }
    }
    return buffer.toString();
  }
}
