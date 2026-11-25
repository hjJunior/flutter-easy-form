import '../validation/validation_error.dart';
import '../validation/validator.dart';
import 'form_node.dart';

/// An ordered, dynamic collection of nodes of the same shape.
///
/// [T] is the value produced per item; [C] is the concrete node type held,
/// which can be a plain [FormControl] (array of simple values) or a
/// [FormGroup] subclass (array of objects).
///
/// ```dart
/// final contacts = FormArray<Contact, ContactForm>(create: ContactForm.new);
/// contacts.add();
/// contacts[0].name.value = 'Maria';
/// ```
class FormArray<T, C extends FormNode<T>> extends FormNode<List<T>> {
  FormArray({
    required this.create,
    int initialLength = 0,
    this.validators = const [],
  }) {
    for (var i = 0; i < initialLength; i++) {
      _insertItem(_items.length, create());
    }
  }

  /// Factory used to create a new item, e.g. for [add] or [insert].
  final C Function() create;

  final List<Validator<List<T>>> validators;

  final List<C> _items = [];

  int get length => _items.length;

  C operator [](int index) => _items[index];

  @override
  Iterable<FormNode<Object?>> get children => _items;

  @override
  List<T> get value => _items.map((item) => item.value).toList(growable: false);

  /// Appends a new item created with default values.
  void add() => _insertItem(_items.length, create());

  /// Inserts a new item created with default values at [index].
  void insert(int index) => _insertItem(index, create());

  /// Removes the item at [index] and disposes it.
  void removeAt(int index) {
    final item = _items.removeAt(index);
    abandon(item);
    notifyListeners();
  }

  /// Moves the item at [oldIndex] to [newIndex], keeping it alive.
  void move(int oldIndex, int newIndex) {
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    notifyListeners();
  }

  /// Replaces the item at [index] with [item], disposing the one that was
  /// there. Unlike setting a field on the existing item, this swaps in a
  /// different node outright — e.g. one already built elsewhere with its
  /// own values, rather than [create]'s defaults.
  void setAt(int index, C item) {
    final old = _items[index];
    abandon(old);
    adopt(item);
    _items[index] = item;
    notifyListeners();
  }

  void _insertItem(int index, C item) {
    adopt(item);
    _items.insert(index, item);
    notifyListeners();
  }

  @override
  List<ValidationError> get errors {
    if (disabled) return const [];
    return [
      ...childrenErrors,
      for (final validator in validators)
        if (validator(value) case final error?) error,
    ];
  }
}
