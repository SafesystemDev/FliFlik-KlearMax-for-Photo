import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/AppGlobal.dart';
import 'package:foodie_customer/main.dart';
import 'package:foodie_customer/model/User.dart';
import 'package:foodie_customer/model/inbox_model.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/chat_screen/chat_screen.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class InboxDriverScreen extends StatefulWidget {
  const InboxDriverScreen({Key? key}) : super(key: key);

  @override
  State<InboxDriverScreen> createState() => _InboxDriverScreenState();
}

class _InboxDriverScreenState extends State<InboxDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaginateFirestore(
        //item builder type is compulsory.
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, documentSnapshots, index) {
          final data = documentSnapshots[index].data() as Map<String, dynamic>?;
          InboxModel inboxModel = InboxModel.fromJson(data!);
          return InkWell(
            onTap: () async {
              await showProgress(context, "Please wait".tr(), false);

              User? customer = await FireStoreUtils.getCurrentUser(inboxModel.customerId.toString());
              User? restaurantUser = await FireStoreUtils.getCurrentUser(inboxModel.restaurantId.toString());
              hideProgress();
              push(
                  context,
                  ChatScreens(
                    customerName: '${customer!.firstName + " " + customer.lastName}',
                    restaurantName: '${restaurantUser!.firstName + " " + restaurantUser.lastName}',
                    orderId: inboxModel.orderId,
                    restaurantId: restaurantUser.userID,
                    customerId: customer.userID,
                    customerProfileImage: customer.profilePictureURL,
                    restaurantProfileImage: restaurantUser.profilePictureURL,
                    token: restaurantUser.fcmToken,
                    chatType: inboxModel.chatType,
                  ));
            },
            child: ListTile(
              leading: ClipOval(
                child: CachedNetworkImage(
                    width: 50,
                    height: 50,
                    imageUrl: inboxModel.restaurantProfileImage.toString(),
                    imageBuilder: (context, imageProvider) => Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )),
                        ),
                    errorWidget: (context, url, error) => ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          AppGlobal.placeHolderImage!,
                          fit: BoxFit.cover,
                        ))),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(inboxModel.restaurantName.toString())),
                  Text(DateFormat('MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(inboxModel.createdAt!.millisecondsSinceEpoch)), style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              subtitle: Text("Order Id : #" + inboxModel.orderId.toString()),
            ),
          );
        },
        shrinkWrap: true,
        onEmpty: Center(child: Text("No Conversion found")),
        // orderBy is compulsory to enable pagination
        query: FirebaseFirestore.instance.collection('chat_driver').where("customerId", isEqualTo: MyAppState.currentUser!.userID).orderBy('createdAt', descending: true),
        //Change types customerId
        itemBuilderType: PaginateBuilderType.listView,
        initialLoader: CircularProgressIndicator(),
        // to fetch real-time data
        isLive: true,
      ),
    );
  }
}
