import 'package:flutter_application_1/models/cart.dart';
import 'package:flutter_application_1/models/product.dart';

class CartService {
  /// Add a product as a one-time purchase. Increments quantity if already in cart.
  Cart addOneTime(Cart cart, Product product) {
    return _upsert(cart, product, CartItemType.oneTime);
  }

  /// Add a product as a subscription item. Replaces type if same SKU exists.
  Cart addSubscription(Cart cart, Product product, SubscriptionFrequency frequency) {
    final List<CartItem> updated = <CartItem>[...cart.items];
    final int idx = updated.indexWhere((CartItem i) => i.sku == product.sku);

    if (idx >= 0) {
      updated[idx] = CartItem(
        sku: product.sku,
        productName: product.name,
        pricePerUnit: product.price,
        type: CartItemType.subscription,
        quantity: updated[idx].quantity,
        frequency: frequency,
      );
    } else {
      updated.add(CartItem(
        sku: product.sku,
        productName: product.name,
        pricePerUnit: product.price,
        type: CartItemType.subscription,
        frequency: frequency,
      ));
    }

    return Cart(items: updated);
  }

  /// Remove a product from the cart entirely.
  Cart remove(Cart cart, String sku) {
    return Cart(
      items: cart.items.where((CartItem i) => i.sku != sku).toList(),
    );
  }

  /// Change the quantity of a cart item (removes if qty reaches 0).
  Cart setQuantity(Cart cart, String sku, int quantity) {
    if (quantity <= 0) {
      return remove(cart, sku);
    }
    final List<CartItem> updated = cart.items.map((CartItem item) {
      if (item.sku == sku) {
        item.quantity = quantity;
      }
      return item;
    }).toList();
    return Cart(items: updated);
  }

  Cart _upsert(Cart cart, Product product, CartItemType type) {
    final List<CartItem> updated = <CartItem>[...cart.items];
    final int idx = updated.indexWhere((CartItem i) => i.sku == product.sku);

    if (idx >= 0) {
      updated[idx].quantity += 1;
    } else {
      updated.add(CartItem(
        sku: product.sku,
        productName: product.name,
        pricePerUnit: product.price,
        type: type,
      ));
    }

    return Cart(items: updated);
  }
}
