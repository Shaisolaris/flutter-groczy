/// Bottom navigation tab indices, shared between the root shell and any
/// screen that needs to programmatically switch tabs (e.g. checkout
/// confirmation jumping to Orders, or a snackbar's "View cart" action
/// jumping to Cart).
abstract final class NavTab {
  static const int shop = 0;
  static const int cart = 1;
  static const int orders = 2;
  static const int lists = 3;
}
