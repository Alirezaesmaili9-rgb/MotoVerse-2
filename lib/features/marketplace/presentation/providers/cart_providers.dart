import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../wallet/presentation/providers/wallet_providers.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import 'marketplace_providers.dart';

/// The user's server-backed cart.
final cartProvider =
    AsyncNotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() async {
    ref.watch(authStateChangesProvider);
    final res = await ref.read(marketplaceRepositoryProvider).getCart();
    return res.fold((f) => throw Exception(f.message), (items) => items);
  }

  Future<void> add(Product product, {int quantity = 1}) async {
    final items = state.valueOrNull ?? const [];
    var currentQty = 0;
    for (final e in items) {
      if (e.product.id == product.id) {
        currentQty = e.quantity;
        break;
      }
    }
    await _set(product.id, currentQty + quantity);
  }

  Future<void> setQuantity(CartItem item, int quantity) async {
    if (quantity <= 0) {
      await remove(item);
      return;
    }
    await _set(item.product.id, quantity);
  }

  Future<void> _set(String productId, int quantity) async {
    await ref
        .read(marketplaceRepositoryProvider)
        .setCartItem(productId, quantity);
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(CartItem item) async {
    await ref
        .read(marketplaceRepositoryProvider)
        .removeCartItem(item.product.id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> clear() async {
    await ref.read(marketplaceRepositoryProvider).clearCart();
    ref.invalidateSelf();
    await future;
  }

  /// Returns null on success, or an error message.
  Future<String?> checkout() async {
    final items = state.valueOrNull ?? const [];
    if (items.isEmpty) return 'سبد خرید خالی است';
    final res = await ref.read(marketplaceRepositoryProvider).checkout(items);
    return res.fold((f) => f.message, (_) {
      ref.invalidateSelf();
      // Wallet balance + transactions + orders changed server-side.
      ref.invalidate(walletBalanceProvider);
      ref.invalidate(walletTransactionsProvider);
      ref.invalidate(ordersProvider);
      return null;
    });
  }
}

/// Total item count (sum of quantities) — for the cart badge.
final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider).valueOrNull ?? const [];
  return items.fold(0, (sum, e) => sum + e.quantity);
});

/// Cart subtotal in Toman.
final cartTotalProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider).valueOrNull ?? const [];
  return items.fold(0, (sum, e) => sum + e.lineTotal);
});

/// Orders list (also invalidated after checkout).
final ordersProvider = FutureProvider.autoDispose((ref) async {
  final res = await ref.watch(marketplaceRepositoryProvider).getOrders();
  return res.fold((f) => throw Exception(f.message), (o) => o);
});
