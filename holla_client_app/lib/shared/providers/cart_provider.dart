import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/order_model.dart' as order;
import '../../core/models/product_model.dart' as product;

class CartNotifier extends StateNotifier<List<order.CartItem>> {
  CartNotifier() : super([]);

  void add(product.ProductModel item) {
    final index = state.indexWhere((i) => i.product.id == item.id);
    if (index != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            order.CartItem(product: state[i].product, quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, order.CartItem(product: item)];
    }
  }

  void remove(product.ProductModel item) {
    final index = state.indexWhere((i) => i.product.id == item.id);
    if (index == -1) return;
    if (state[index].quantity == 1) {
      state = state.where((i) => i.product.id != item.id).toList();
    } else {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            order.CartItem(product: state[i].product, quantity: state[i].quantity - 1)
          else
            state[i],
      ];
    }
  }

  void clear() => state = [];

  int getQuantity(String productId) =>
      state.where((i) => i.product.id == productId).fold(0, (s, i) => s + i.quantity);

  int get totalItems   => state.fold(0, (s, i) => s + i.quantity);
  int get subtotal     => state.fold(0, (s, i) => s + i.subtotal);
  int get deliveryFee  => 500;
  int get total        => subtotal + deliveryFee;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<order.CartItem>>(
  (ref) => CartNotifier(),
);

final cartTotalProvider = Provider<int>((ref) {
  return ref.watch(cartProvider.notifier).total;
});