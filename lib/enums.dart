enum ProductType { single, variable }

enum TextSizes { small, medium, large }

/// 1. الحالة العامة للطلب (من وجهة نظر المستخدم والنظام ككل)
enum OrderStatus {
  pendingPayment,
  pendingPaymentApproval,
  timeExpired, // تم إلغاء الطلب تلقائياً لعدم إتمام الدفع خلال الوقت المحدد
  pending, // الطلب بانتظار المراجعة أو الدفع
  processing, // الطلب قيد التجهيز (تم قبول بعض أو كل العناصر)
  accepted,
  readyForPickup, // الطلب جاهز الآن ليستلمه المندوب أو العميل
  shipped, // الطلب بالكامل مع المندوب وفي الطريق للعميل
  delivered, // تم التسليم بنجاح
  cancelled, // تم إلغاء الطلب بالكامل
  refunded, // تم استرداد مبالغ العناصر المرفوضة للعميل
}

/// 2. حالة كل عنصر داخل الطلب (خاص بالتعامل بين المتجر والمندوب)
enum ItemStatus {
  pending, // العنصر جديد وبانتظار موافقة صاحب المتجر
  accepted, // تم قبول العنصر من قبل المتجر
  rejected, // تم رفض العنصر (غير متوفر مثلاً) - سيتم تفعيل استرداد المبلغ هنا
  readyForPickup, // المتجر قام بتغليف العنصر وهو جاهز الآن ليستلمه المندوب
  shipped, // العنصر تم استلامه من قبل المندوب وهو في الطريق
  delivered, // تم تسليم هذا العنصر تحديداً للعميل
  cancelled, // تم إلغاء هذا العنصر من قبل العميل قبل البدء بتجهيزه
  cancellationRequested, // العميل طلب إلغاء هذا العنصر بعد قبوله من المتجر - يحتاج موافقة المتجر
  returnRequested, // العميل طلب إرجاع هذا العنصر بعد تسليمه - يحتاج موافقة المتجر
  returned, // تم إرجاع هذا العنصر من قبل العميل بعد تسليمه - يحتاج موافقة المتجر
}

enum DeliveryStatus { pickedUp, onTheWay, delivered }

enum PaymentMethods {
  paypal,
  googlepay,
  appepay,
  visa,
  materCard,
  creditCard,
  paystack,
  razorpay,
  paytm,
}
