import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:untitled2_ecom/utils/constants/colors.dart';
import 'package:untitled2_ecom/utils/constants/sizes.dart';
import 'package:untitled2_ecom/wallet/controller/WalletController.dart';
import 'package:untitled2_ecom/wallet/model/TransactionModel.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استدعاء الكنترولر الذي أنشأناه سابقاً
    final controller = Get.put(WalletController());

    return Scaffold(
      // backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // 1. AppBar مع عرض الرصيد الإجمالي للمستخدم
          SliverAppBar(
            expandedHeight: 250.0,
            backgroundColor: TColors.primary,
            pinned: true,
            leading: IconButton(
              icon: const Icon(
                Iconsax.arrow_right_3,
                color: TColors.textPrimary,
              ),
              onPressed: () => Get.back(),
            ),
            // --- السر هنا: العنوان الذي يظهر عند التمرير ---
            title: Obx(
              () => Text(
                "الرصيد: ₪ ${controller.balance.value}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.0,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TColors.primary,
                      TColors.secondary,
                    ], // درجات الأزرق الاحترافية
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "رصيدك الحالي",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => Text(
                        "₪ ${controller.balance.value}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(
                  0.08,
                ), // خلفية ناعمة محيطة بالشريط بالكامل
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  // 1. خيار: الكل (يقوم بإرسال null لإلغاء الفلتر)
                  _buildModernFilterBtn(
                    context: context,
                    title: "الكل",
                    icon: Icons.refresh_rounded,
                    color: TColors.primary,
                    isSelectedTarget: (controller) =>
                        controller.selectedFilter.value == null,
                    onTap: () => controller.applyFilter(null),
                  ),
                  const SizedBox(width: 4),

                  // 2. خيار: الأرباح / المشتريات
                  _buildModernFilterBtn(
                    context: context,
                    title: "مشتريات",
                    icon: Icons.shopping_bag_outlined,
                    color: Colors.orange,
                    isSelectedTarget: (controller) =>
                        controller.selectedFilter.value ==
                        TransactionType.purchase,
                    onTap: () =>
                        controller.applyFilter(TransactionType.purchase),
                  ),
                  const SizedBox(width: 4),

                  // 3. خيار: المرتجعات
                  _buildModernFilterBtn(
                    context: context,
                    title: "مرجعات",
                    icon: Icons.call_received,
                    color: Colors.red,
                    isSelectedTarget: (controller) =>
                        controller.selectedFilter.value ==
                        TransactionType.refund,
                    onTap: () => controller.applyFilter(TransactionType.refund),
                  ),
                  const SizedBox(width: 4),

                  // 4. خيار: المستردات / السحوبات
                  _buildModernFilterBtn(
                    context: context,
                    title: "مستردات",
                    icon: Iconsax.wallet, // تأكد من استيراد حزمة iconsax
                    color: Colors.green,
                    isSelectedTarget: (controller) =>
                        controller.selectedFilter.value ==
                        TransactionType.bank_withdrawal,
                    onTap: () =>
                        controller.applyFilter(TransactionType.bank_withdrawal),
                  ),
                ],
              ),
            ),
          ),

          // 2. إحصائيات سريعة (العمليات المكتملة مقابل المعلقة)
          // 2. أزرار الفلترة المحدثة
          /*
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => Row(
                  children: [
                    _buildFilterBtn(
                      "مرجعات",
                      Icons.call_received,
                      Colors.red,
                      controller.selectedFilter.value == TransactionType.refund,
                      () => controller.applyFilter(TransactionType.refund),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterBtn(
                      "مشتريات",
                      Icons.shopping_bag_outlined,
                      Colors.orange,
                      controller.selectedFilter.value ==
                          TransactionType.purchase,
                      () => controller.applyFilter(TransactionType.purchase),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterBtn(
                      "مستردات",
                      Iconsax.wallet,
                      Colors.green,
                      controller.selectedFilter.value ==
                          TransactionType.bank_withdrawal,
                      () => controller.applyFilter(
                        TransactionType.bank_withdrawal,
                      ),
                    ),
                    // زر لإلغاء الفلتر
                    IconButton(
                      onPressed: () => controller.applyFilter(null),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
         */
          /*SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildStatCard(
                    "مبالغ مستردة",
                    Icons.call_received,
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    "مشتريات",
                    Icons.shopping_bag_outlined,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),*/

          // 3. عنوان قائمة العمليات
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "سجل العمليات",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ),
          ),

          // 4. قائمة العمليات المالية الحقيقية
          // 4. القائمة
          Obx(() {
            if (controller.transactions.isEmpty &&
                !controller.isLoadingMore.value) {
              return const SliverToBoxAdapter(
                child: Center(child: Text("لا توجد عمليات")),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                // إذا وصلنا لنهاية القائمة نعرض مؤشر تحميل
                if (index == controller.transactions.length) {
                  return controller.hasMoreData.value
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const SizedBox.shrink();
                }
                return _buildTransactionItem(controller.transactions[index]);
              }, childCount: controller.transactions.length + 1),
            );
          }),
        ],
      ),
    );
  }

  // بطاقة إحصائية
  Widget _buildStatCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // عنصر العملية المالية المطور ليدعم الحالة (Status)
  Widget _buildTransactionItem(TransactionModel transaction) {
    // تحديد الشكل بناءً على نوع العملية (Refund أو Purchase)
    final bool isRefund = transaction.type == TransactionType.refund;
    //final Color color = isRefund ? Colors.green : Colors.red;
    //final IconData icon = isRefund ? Icons.add_rounded : Icons.remove_rounded;
    final TransactionType type = transaction.type;
    IconData icon;
    Color color;
    String title;

    if (type == TransactionType.purchase) {
      icon = Icons.add_shopping_cart;
      color = Colors.orange;
      //title = "أرباح طلب #${data['orderId']?.toString().substring(0, 5)}...";
    } else if (type == TransactionType.refund) {
      icon = Icons.call_received;
      color = Colors.red;
      //title = "مرتجع طلب";
    } else if (type == TransactionType.bank_withdrawal) {
      icon = Icons.wallet;
      color = Colors.green;
      //title = "تحرير رصيد";
    } else if (type == TransactionType.deposit) {
      icon = Icons.account_balance_wallet;
      color = Colors.blue;
      //title = "سحب رصيد";
    } else {
      icon = Icons.account_balance_wallet;
      color = Colors.purple;
      //title = "معاملة مجهولة";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(transaction.date),
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 4),
            _buildStatusChip(
              transaction.status,
            ), // إضافة الـ Chip الخاص بالحالة
          ],
        ),
        trailing: Text(
          "${isRefund ? '+' : '-'} ₪ ${transaction.amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildModernFilterBtn({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required bool Function(WalletController) isSelectedTarget,
    required VoidCallback onTap,
  }) {
    final controller =
        Get.find<
          WalletController
        >(); // أو Get.find<WalletController>() حسب إعداداتك

    return Expanded(
      child: Obx(() {
        final isSelected = isSelectedTarget(controller);

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              // تأثير الانتقال اللوني العصري عند التحديد
              color: isSelected ? TColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: TColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: FittedBox(
              fit:
                  BoxFit.scaleDown, // يحمي المحاذاة من الكسر على الشاشات الضيقة
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : color,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ويدجت حالة العملية
  Widget _buildStatusChip(TransactionStatus status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case TransactionStatus.pending:
        statusColor = Colors.orange;
        statusText = "معلق";
        break;
      case TransactionStatus.completed:
        statusColor = Colors.green;
        statusText = "مكتمل";
        break;
      case TransactionStatus.failed:
        statusColor = Colors.red;
        statusText = "فاشل";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFilterBtn(
    String title,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? TColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? TColors.primary : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
