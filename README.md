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
| <img src="https://github.com/user-attachments/assets/15d909bc-4981-4a72-b229-4611c411ea40" width="220" /> | <img src="https://github.com/user-attachments/assets/6b54b79d-f3a2-4247-bd0e-a09254589422" width="220" /> | <img src="https://github.com/user-attachments/assets/76c05f5d-029d-490d-bd51-7e0207f9e93a" width="220" /> |

### 🏪 تصفح المتجر والمنتجات (Store Exploration)
| الرئيسة والتصنيفات | استكشاف المتاجر | صفحة المتجر | المفضلة | واجهة إضافية |
|:---:|:---:|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/ab7ad790-d7d5-45bc-909d-69d5ddb99b6b" width="160" /> | <img src="https://github.com/user-attachments/assets/da35c0de-1e07-4875-ba59-d45bf3d76853" width="160" /> | <img src="https://github.com/user-attachments/assets/ae93930c-368b-4101-8d4e-14078649ed47" width="160" /> | <img src="https://github.com/user-attachments/assets/1651ec01-8fc2-4ca6-8e01-61b33b6a696c" width="160" /> | <img src="https://github.com/user-attachments/assets/329613b4-b22a-4432-aad5-68accb4de50e" width="160" /> |

### 🛒 مراجعة الطلب وبوابات الدفع (Checkout & Payments)
| مراجعة السلة والمنطقة | اختيار بوابة الدفع | تتبع حالة الطلب اللحظية | واجهات تفصيلية للطلب |
|:---:|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/35dccca4-bc67-4ca4-a323-9b8c5df6888a" width="160" /> | <img src="https://github.com/user-attachments/assets/7a10bfa0-33d8-4369-96aa-f2cd9ebbab9e" width="160" /> | <img src="https://github.com/user-attachments/assets/6ba1c7df-5a86-44f3-a6fb-f4554dad48cf" width="160" /> | <img src="https://github.com/user-attachments/assets/7f66f40b-79e1-4fa7-96ef-0ce7b8e02623" width="160" /> |
| <img src="https://github.com/user-attachments/assets/bf74e94d-3b98-49cf-8088-5414826a0877" width="160" /> | <img src="https://github.com/user-attachments/assets/7b954d2a-ebf4-4658-a3da-506d948d559c" width="160" /> | <img src="https://github.com/user-attachments/assets/74a015a8-b625-4156-a001-6f679f25fcbc" width="160" /> | <img src="https://github.com/user-attachments/assets/67be52c6-dea1-4dea-aa98-3d65d930dbd8" width="160" /> |

### 👤 الحساب الشخصي والعمليات المالية (Profile & FinTech)
| معلومات الملف الشخصي | إدارة العناوين | مركز الإشعارات | المحفظة وسجل العمليات | واجهة إضافية |
|:---:|:---:|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/596b253b-54f5-42fc-8ce3-012b7ae4a0d9" width="160" /> | <img src="https://github.com/user-attachments/assets/3246e223-72f2-4e4e-9564-4cb1a9d3590f" width="160" /> | <img src="https://github.com/user-attachments/assets/ab75a270-6354-437d-bc47-927f8fe5fb2c" width="160" /> | <img src="https://github.com/user-attachments/assets/ceb6c3cb-efdb-403b-861c-e78db7c0b598" width="160" /> | <img src="https://github.com/user-attachments/assets/3e6e9314-76de-439b-b4c2-5330d6a4569c" width="160" /> |

### 🛠️ إدارة الطلبات والدعم الفني (Order Management & Support)
| تفاصيل المشتريات | تتبع تقدم الشحن الفعلي | خيارات الدعم وإدارة الطلب |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/110fe29a-912a-45b5-b1dd-d40df540283f" width="220" /> | <img src="https://github.com/user-attachments/assets/9a5bd89b-2e6e-4491-8204-175f950096e8" width="220" /> | <img src="https://github.com/user-attachments/assets/f55c4e85-b4b7-480c-b6de-fe934e4d4814" width="220" /> |

---

## 🚀 التشغيل المحلي | Installation & Setup

1. **تحميل المشروع (Clone the repository):**
   ```bash
   git clone [https://github.com/abosharekhosama-afk/store_app.git](https://github.com/abosharekhosama-afk/store_app.git)
