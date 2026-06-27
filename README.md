# 🛒 متجر غزة الإلكتروني - تطبيق المستخدم | Gaza E-Commerce - User App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![GetX](https://img.shields.io/badge/State_Management-GetX-purple?style=for-the-badge)](https://pub.dev/packages/get)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)

تطبيق هاتف محمول متكامل ومطور بلغة **Flutter**، يمثل حلقة الوصل الذكية بين المتاجر والمستخدمين في قطاع غزة. يتيح التطبيق للمستخدمين تصفح المتاجر المحلية وطلب المنتجات بكل سهولة مع تتبع لحظي لحالة الشحنات، وإدارة مالية آمنة عبر محفظة رقمية مدمجة.

An advanced **Flutter** mobile application that acts as a smart bridge connecting local stores and users across the Gaza Strip. It enables seamless ordering, real-time order tracking, and secure financial management through an integrated digital wallet.

---

## 🌍 رؤية المشروع | Project Vision

في ظل التحديات الجغرافية وصعوبة التنقل في قطاع غزة، يأتي هذا التطبيق ليوحد المتاجر في منصة واحدة، تمكن الزبون من التسوق والشراء دون الحاجة لمراسلة أو مراجعة المتاجر يدوياً، مع توفير نظام دعم وتوصيل ذكي وموثوق.

Given the geographic challenges and mobility restrictions in Gaza, this app centralizes local commerce into a single hub. It empowers users to order seamlessly without manual vendor coordination, supported by a smart delivery and support ecosystem.

---

## ✨ الميزات الرئيسية | Key Features

### 👤 تجربة المستخدم والطلب (User Experience & Ordering)
* **دليل متاجر قطاع غزة:** استعراض المتاجر وتصنيفاتها بناءً على الموقع الجغرافي والتوفر.
* **تتبع الطلبات اللحظي:** شريط تتبع ديناميكي يوضح تقدم الطلب (*بانتظار الدفع ⬅️ مراجعة الدفع ⬅️ قيد الانتظار ⬅️ قيد التجهيز ⬅️ في الطريق ⬅️ تم التسليم*).
* **إدارة العناوين المتعددة:** حفظ مواقع توصيل متعددة بدقة لضمان وصول المندوب بشكل صحيح.

### 💳 النظام المالي والمحفظة الرقمية (FinTech & Digital Wallet)
* **المحفظة الداخلية:** إمكانية الدفع المباشر من رصيد المحفظة أو عبر وسائل الدفع المدعومة (مثل PayPal والدفع البنكي).
* **الاسترداد التلقائي الآمن (Refund System):** في حال رفض المتجر للطلب، يتم استرداد الأموال فوراً إلى محفظة الزبون الداخلية.
* **إثبات الدفع اليدوي:** إمكانية رفع صورة لإيصال التحويل البنكي يدوياً ليقوم المسؤول بتفعيل الطلب بعد مراجعته.

### 🛠️ خيارات الدعم المتقدمة (Advanced Support Options)
* **إدارة خيارات الطلب المستلم:** واجهة دعم مرنة تتيح (تقديم طلب إلغاء قبل التجهيز، الإبلاغ عن عدم استلام الشحنة، أو حل مشاكل الدفع).

---

## 🏗️ البنية البرمجية والتقنيات | Tech Stack & Architecture

تم بناء التطبيق باتباع أفضل الممارسات البرمجية لضمان الأمان والسرعة:

* **إدارة الحالة (State Management):** الاعتماد بالكامل على **GetX** لضمان أداء عالي وسلس واستجابة فورية للواجهات.
* **المصادقة (Authentication):** نظام آمن لتسجيل الدخول وإنشاء الحسابات واستعادة كلمات المرور عبر **Firebase Auth**.
* **قاعدة البيانات (Database):** استخدام **Cloud Firestore** لتخزين البيانات وجلبها بشكل فوري (Real-time).
* **التخزين السحابي (Storage):** رفع وحفظ صور المنتجات، ملفات الحساب الشخصي، وإيصالات الدفع عبر **Firebase Storage**.
* **أمان العمليات (Cloud Functions):** نقل جميع العمليات المالية والحيوية (مثل الخصم، الاسترداد، وتغيير حالات الطلب الحساسة) لتتم في السحابة عبر **Firebase Cloud Functions** لضمان أعلى مستويات الأمان والسرعة ومنع التلاعب من جهة العميل (Client-side Security).
* **هيكلية ملفات منظمة:** تقسيم برمجى نظيف ومدروس يسهل صيانته وتطويره مستقبلاً.

---

## 📱 منظومة التطبيقات المتكاملة | Multi-App Ecosystem

هذا التطبيق مخصص **للمستخدمين النهائيين فقط**، وهو جزء من منظومة متكاملة تشمل:
1. **تطبيق المستخدم (User App):** (هذا المستودع) لتصفح المنتجات والشراء والتتبع.
2. **تطبيق المتاجر والمناديب (Vendor & Courier App):** لادارة الطلبات، تجهيز الشحنات، وتوجيه مناديب التوصيل.
3. **لوحة تحكم الإدارة (Admin Dashboard):** لتفتيش العمليات، إدارة الحسابات، ومراجعة المحافظ المالية وإثباتات الدفع.

---

## 📸 واجهات التطبيق | App Screenshots

### 🔑 التوثيق والمصادقة (Authentication)
| تسجيل الدخول | إنشاء حساب جديد | استعادة كلمة المرور |
|:---:|:---:|:---:|
| <img src="1000077739.jpg" width="220" /> | <img src="1000077741.jpg" width="220" /> | <img src="1000077743.jpg" width="220" /> |

### 🏪 تصفح المتجر والمنتجات (Store Exploration)
| الرئيسة والتصنيفات | استكشاف المتاجر | صفحة المتجر | المفضلة |
|:---:|:---:|:---:|:---:|
| <img src="1000077675.jpg" width="200" /> | <img src="1000077677.jpg" width="200" /> | <img src="1000077679.jpg" width="200" /> | <img src="1000077681.jpg" width="200" /> |

### 🛒 مراجعة الطلب وبوابات الدفع (Checkout & Payments)
| مراجعة السلة والمنطقة | اختيار بوابة الدفع | تتبع حالة الطلب اللحظية |
|:---:|:---:|:---:|
| <img src="1000077735.jpg" width="220" /> | <img src="1000077737.jpg" width="220" /> | <img src="100007701.jpg" width="220" /> |

### 👤 الحساب الشخصي والعمليات المالية (Profile & FinTech)
| معلومات الملف الشخصي | إدارة العناوين | مركز الإشعارات | المحفظة وسجل العمليات |
|:---:|:---:|:---:|:---:|
| <img src="100007783.jpg" width="200" /> | <img src="100007785.jpg" width="200" /> | <img src="100007787.jpg" width="200" /> | <img src="100007789.jpg" width="200" /> |

### 🛠️ إدارة الطلبات والدعم الفني (Order Management & Support)
| تفاصيل المشتريات | تتبع تقدم الشحن الفعلي | خيارات الدعم وإدارة الطلب |
|:---:|:---:|:---:|
| <img src="1000077691.jpg" width="220" /> | <img src="1000077693.jpg" width="220" /> | <img src="1000077745.jpg" width="220" /> |

---

## 🚀 التشغيل المحلي | Installation & Setup

1. **تحميل المشروع (Clone the repository):**
   ```bash
   git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
