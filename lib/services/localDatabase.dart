import 'dart:convert';

import 'package:foodie_customer/model/ProductModel.dart';
import 'package:foodie_customer/model/variant_info.dart';
import 'package:foodie_customer/ui/productDetailsScreen/ProductDetailsScreen.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'localDatabase.g.dart';

class CartProducts extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(max: 50)();

  TextColumn get photo => text()();

  TextColumn get price => text()();

  TextColumn get discountPrice => text().nullable()();

  TextColumn get vendorID => text()();

  IntColumn get quantity => integer()();

  // ignore: non_constant_identifier_names
  TextColumn get extras_price => text().nullable()();

  TextColumn get extras => text().nullable()();


  @override
  Set<Column> get primaryKey => {id};
}

@UseMoor(tables: [CartProducts])
class CartDatabase extends _$CartDatabase {
  CartDatabase() : super(FlutterQueryExecutor.inDatabaseFolder(path: 'db.sqlite', logStatements: true));

  addProduct(ProductModel model, CartDatabase cartDatabase, bool isIncerementQuantity) async {
    var joinTitleString = "";
    String mainPrice = "";
    List<AddAddonsDemo> lstAddOns = [];
    List<String> lstAddOnsTemp = [];
    double extrasPrice = 0.0;

    SharedPreferences sp = await SharedPreferences.getInstance();
    String addOns = sp.getString("musics_key") != null ? sp.getString('musics_key')! : "";

    bool isAddSame = false;

    if (!isAddSame) {
      if (model.disPrice != null && model.disPrice!.isNotEmpty && double.parse(model.disPrice!) != 0) {
        mainPrice = model.disPrice!;
      } else {
        mainPrice = model.price;
      }
    }

    if (addOns.isNotEmpty) {
      lstAddOns = AddAddonsDemo.decode(addOns);
      for (int a = 0; a < lstAddOns.length; a++) {
        AddAddonsDemo newAddonsObject = lstAddOns[a];
        if (newAddonsObject.categoryID == model.id) {
          if (newAddonsObject.isCheck == true) {
            lstAddOnsTemp.add(newAddonsObject.name!);
            extrasPrice += (double.parse(newAddonsObject.price!));
          }
        }
      }

      joinTitleString = lstAddOnsTemp.isEmpty ? "" : lstAddOnsTemp.join(",");
    }

    allCartProducts.then((products) async {
      final bool _productIsInList = products.any((product) => product.id == (model.id + "~" + (model.variantInfo != null ? model.variantInfo!.variantId.toString() : "")));
      if (_productIsInList) {
        CartProduct element = products.firstWhere((product) => product.id == (model.id + "~" + (model.variantInfo != null ? model.variantInfo!.variantId.toString() : "")));
        await cartDatabase.updateProduct(CartProduct(
            id: element.id,
            name: element.name,
            photo: element.photo,
            price: element.price,
            vendorID: element.vendorID,
            quantity: isIncerementQuantity ? element.quantity + 1 : element.quantity,
            category_id: element.category_id,
            extras_price: extrasPrice.toString(),
            extras: joinTitleString,
            discountPrice: element.discountPrice!));
      } else {
        CartProduct entity = CartProduct(
            id: model.id + "~" + (model.variantInfo != null ? model.variantInfo!.variantId.toString() : ""),
            name: model.name,
            photo: model.photo,
            price: mainPrice,
            discountPrice: model.disPrice,
            vendorID: model.vendorID,
            quantity: isIncerementQuantity ? 1 : 0,
            extras_price: extrasPrice.toString(),
            extras: joinTitleString,
            category_id: model.categoryID,
            variant_info: model.variantInfo);
        if (products.where((element) => element.id == model.id).isEmpty) {
          into(cartProducts).insert(entity);
        } else {
          updateProduct(entity);
        }
      }
    });
  }

  reAddProduct(CartProduct cartProduct) => into(cartProducts).insert(cartProduct);

  removeProduct(String productID) => (delete(cartProducts)..where((product) => product.id.equals(productID))).go();

  deleteAllProducts() => (delete(cartProducts)).go();

  updateProduct(CartProduct entity) => (update(cartProducts)..where((product) => product.id.equals(entity.id))).write(entity);

  @override
  int get schemaVersion => 1;

  Future<List<CartProduct>> get allCartProducts => select(cartProducts).get();

  Stream<List<CartProduct>> get watchProducts => select(cartProducts).watch();
}
