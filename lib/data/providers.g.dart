// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'e5a1fa0e8ff9aa131f847f28519ec2098e6d0f76';

/// See also [database].
@ProviderFor(database)
final databaseProvider = Provider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DatabaseRef = ProviderRef<AppDatabase>;
String _$expensesHash() => r'891882357732ed1bf52bc438978bae940888d706';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [expenses].
@ProviderFor(expenses)
const expensesProvider = ExpensesFamily();

/// See also [expenses].
class ExpensesFamily extends Family<AsyncValue<List<ExpenseWithCategory>>> {
  /// See also [expenses].
  const ExpensesFamily();

  /// See also [expenses].
  ExpensesProvider call({
    required DateTimeRange dateRange,
  }) {
    return ExpensesProvider(
      dateRange: dateRange,
    );
  }

  @override
  ExpensesProvider getProviderOverride(
    covariant ExpensesProvider provider,
  ) {
    return call(
      dateRange: provider.dateRange,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'expensesProvider';
}

/// See also [expenses].
class ExpensesProvider
    extends AutoDisposeStreamProvider<List<ExpenseWithCategory>> {
  /// See also [expenses].
  ExpensesProvider({
    required DateTimeRange dateRange,
  }) : this._internal(
          (ref) => expenses(
            ref as ExpensesRef,
            dateRange: dateRange,
          ),
          from: expensesProvider,
          name: r'expensesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$expensesHash,
          dependencies: ExpensesFamily._dependencies,
          allTransitiveDependencies: ExpensesFamily._allTransitiveDependencies,
          dateRange: dateRange,
        );

  ExpensesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dateRange,
  }) : super.internal();

  final DateTimeRange dateRange;

  @override
  Override overrideWith(
    Stream<List<ExpenseWithCategory>> Function(ExpensesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExpensesProvider._internal(
        (ref) => create(ref as ExpensesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dateRange: dateRange,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ExpenseWithCategory>> createElement() {
    return _ExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpensesProvider && other.dateRange == dateRange;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dateRange.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ExpensesRef on AutoDisposeStreamProviderRef<List<ExpenseWithCategory>> {
  /// The parameter `dateRange` of this provider.
  DateTimeRange get dateRange;
}

class _ExpensesProviderElement
    extends AutoDisposeStreamProviderElement<List<ExpenseWithCategory>>
    with ExpensesRef {
  _ExpensesProviderElement(super.provider);

  @override
  DateTimeRange get dateRange => (origin as ExpensesProvider).dateRange;
}

String _$categoriesHash() => r'ab68f9f3f69a9e19c9ff8d4b842cdbb7b110de5d';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider = AutoDisposeStreamProvider<List<Category>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoriesRef = AutoDisposeStreamProviderRef<List<Category>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
