import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_customer/model/VendorModel.dart';
import 'package:foodie_customer/services/FirebaseHelper.dart';
import 'package:foodie_customer/services/helper.dart';
import 'package:foodie_customer/ui/fullScreenImageViewer/FullScreenImageViewer.dart';

import '../../AppGlobal.dart';
import '../../constants.dart';

class RestaurantPhotos extends StatefulWidget {
  final VendorModel vendorModel;

  RestaurantPhotos({Key? key, required this.vendorModel}) : super(key: key);

  @override
  _RestaurantPhotosState createState() => _RestaurantPhotosState();
}

class _RestaurantPhotosState extends State<RestaurantPhotos> {
  late Future<VendorModel> photofuture;
  final FireStoreUtils fireStoreUtils = FireStoreUtils();

  @override
  void initState() {
    super.initState();
    photofuture = fireStoreUtils.getVendorByVendorID(widget.vendorModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppGlobal.buildSimpleAppBar(context, "Photos".tr()),
          body: SingleChildScrollView(
            child: Container(
                // first tab bar view widget
                padding: EdgeInsets.only(top: 0),
                child: FutureBuilder<VendorModel>(
                  future: photofuture,
                  // initialData: [],
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.waiting && snapshot.data!.photos.isEmpty) {
                      if (snapshot.data!.photo.isNotEmpty) {
                        snapshot.data!.photos.add(snapshot.data!.photo);
                      }
                    }

                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                        ),
                      );
                    else if (snapshot.data!.photos.isEmpty) return Center(child: showEmptyState("NoImages".tr(), context));
                    return GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 5 / 4,
                        padding: EdgeInsets.all(10.0),
                        children: List.generate(snapshot.data!.photos.length, (index) {
                          if (snapshot.data!.hidephotos == false) {
                            return Container(
                              child: InkWell(
                                onTap: () {
                                  push(context, FullScreenImageViewer(imageUrl: snapshot.data!.photos[index]));
                                },
                                child: Card(
                                    color: Color(0xffE7EAED),
                                    elevation: 0.5,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0), side: BorderSide(color: Color(0xffDEE3ED))),
                                    child: CachedNetworkImage(
                                        height: 70,
                                        width: 100,
                                        imageUrl: getImageVAlidUrl(snapshot.data!.photos[index]),
                                        imageBuilder: (context, imageProvider) => Container(
                                              width: 70,
                                              height: 100,
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                            ),
                                        errorWidget: (context, url, error) => ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: Image.network(
                                              AppGlobal.placeHolderImage!,
                                              fit: BoxFit.cover,
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.height,
                                            )))),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }));
                  },
                )),
          )),
    );
  }
}

class RestaurantMenuPhoto extends StatefulWidget {
  final List<dynamic> restaurantMenuPhotos;

  const RestaurantMenuPhoto({Key? key, required this.restaurantMenuPhotos}) : super(key: key);

  @override
  State<RestaurantMenuPhoto> createState() => _RestaurantMenuPhotoState();
}

class _RestaurantMenuPhotoState extends State<RestaurantMenuPhoto> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppGlobal.buildSimpleAppBar(context, "Menus".tr()),
          body: SingleChildScrollView(
              child: Container(
                  // first tab bar view widget
                  padding: EdgeInsets.only(top: 0),
                  child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 5 / 4,
                      padding: EdgeInsets.all(10.0),
                      children: List.generate(widget.restaurantMenuPhotos.length, (index) {
                        return Container(
                          child: InkWell(
                            onTap: () {
                              push(context, FullScreenImageViewer(imageUrl: widget.restaurantMenuPhotos[index]));
                            },
                            child: Card(
                                color: Color(0xffE7EAED),
                                elevation: 0.5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0), side: BorderSide(color: Color(0xffDEE3ED))),
                                child: CachedNetworkImage(
                                    height: 70,
                                    width: 100,
                                    imageUrl: getImageVAlidUrl(widget.restaurantMenuPhotos[index]),
                                    imageBuilder: (context, imageProvider) => Container(
                                          width: 70,
                                          height: 100,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                                        ),
                                    errorWidget: (context, url, error) => ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          AppGlobal.placeHolderImage!,
                                          fit: BoxFit.cover,
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height,
                                        )))),
                          ),
                        );
                      }))))),
    );
  }
}
