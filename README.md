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
| <img src="https://github.com/user-attachments/assets/6eedd011-07ad-4b9f-869c-051c1b1f3d7d" width="220" /> | <img src="https://github.com/user-attachments/assets/6e70098c-73c7-40a9-b011-367475046e73" width="220" /> | <img src="https://github.com/user-attachments/assets/683a82b0-9829-4ecf-ba61-69a3e5e89291" width="220" /> |

### 🏪 تصفح المتجر والمنتجات (Store Exploration)
| الرئيسة والتصنيفات | استكشاف المتاجر | صفحة المتجر | المفضلة |
|:---:|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/a6d909e4-5ff4-411e-b909-2b702985d873" width="200" /> | <img src="https://github.com/user-attachments/assets/7404f072-9706-42a1-8a0a-81f667bd8ea6" width="200" /> | <img src="https://github.com/user-attachments/assets/60625c25-85f2-4622-9564-725dfbbc8b08" width="200" /> | <img src="https://github.com/user-attachments/assets/2c627f84-f985-4c32-b2c0-906e4e8dbb86" width="200" /> |

### 🛒 مراجعة الطلب وبوابات الدفع (Checkout & Payments)
| مراجعة السلة والمنطقة | اختيار بوابة الدفع | تتبع حالة الطلب اللحظية |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/b685e9d9-9927-444b-ae57-90125cef9e36" width="220" /> | <img src="https://github.com/user-attachments/assets/44f577be-ae92-44c0-897a-7ddb433aa4f0" width="220" /> | <img src="https://github.com/user-attachments/assets/95680cff-670f-4899-9135-fabd9541e585" width="220" /> |

### 👤 الحساب الشخصي والعمليات المالية (Profile & FinTech)
| معلومات الملف الشخصي | إدارة العناوين | مركز الإشعارات | المحفظة وسجل العمليات |
|:---:|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/bfcf02c3-6be8-42f5-b340-b3c684ab34ca" width="200" /> | <img src="https://github.com/user-attachments/assets/20346375-3d4d-4d31-a5b8-4da3daa118f9" width="200" /> | <img src="https://github.com/user-attachments/assets/176820aa-4db4-4ffc-85bb-46c83f1a42ed" width="200" /> | <img src="https://github.com/user-attachments/assets/3d14cf4d-e134-4de7-bae7-c747a1cc4e1c" width="200" /> |

### 🛠️ إدارة الطلبات والدعم الفني (Order Management & Support)
| تفاصيل المشتريات | تتبع تقدم الشحن الفعلي | خيارات الدعم وإدارة الطلب |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/af0ee0bb-dab5-4ee4-9f30-d1183269bf85" width="220" /> | <img src="https://github.com/user-attachments/assets/a476c40b-4174-42ac-a29f-e58ba019628d" width="220" /> | <img src="https://github.com/user-attachments/assets/f910c391-d061-47f4-a2c3-dfb9fef340b5" width="220" /> |

---

## 🚀 التشغيل المحلي | Installation & Setup

1. **تحميل المشروع (Clone the repository):**
   ```bash
   git clone [https://github.com/abosharekhosama-afk/store_app.git](https://github.com/abosharekhosama-afk/store_app.git)
