import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/common/widgets/appbar/appbar.dart';
import 'package:untitled2_ecom/data/services/notification_controller.dart';
import 'package:untitled2_ecom/features/personalization/screens/Notification/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  final controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppbar(title: Text("الإشعارات")),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.getNotifications(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var docs = snapshot.data.docs;

          if (docs.isEmpty) {
            return Center(child: Text("لا توجد إشعارات حالياً"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data();
              String docId = docs[index].id;
              bool isOpened = data['isOpened'] ?? false;

              return NotificationCard(
                data: data,
                onTap: () {
                  controller.markAsOpened(docId);
                  // هنا أضف كود التوجيه للصفحة المناسبة حسب الـ type
                },
              );

              /*
              Dismissible(
                key: Key(docId),
                direction: DismissDirection.startToEnd,
                confirmDismiss: (direction) async {
                  if (!isOpened) {
                    TLoaders.warningSnackBar(
                      title: "عذراً",
                      message: "يجب فتح الإشعار أولاً لتتمكن من حذفه",
                    );
                    return false;
                  }
                  return true;
                },
                onDismissed: (_) =>
                    controller.deleteNotification(docId, isOpened),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: NotificationCard(
                  data: data,
                  onTap: () {
                    controller.markAsOpened(docId);
                    // هنا أضف كود التوجيه للصفحة المناسبة حسب الـ type
                  },
                ),
              );
            */
            },
          );
        },
      ),
    );
  }
}
