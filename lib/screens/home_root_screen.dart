import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/data/mock_catalog.dart';
import 'package:flutter_application_1/models/breed_analysis.dart';
import 'package:flutter_application_1/models/care_plan.dart';
import 'package:flutter_application_1/models/dog_profile.dart';
import 'package:flutter_application_1/models/food_inventory.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/services/ai_recommendation_service.dart';
import 'package:flutter_application_1/services/breed_analysis_service.dart';
import 'package:flutter_application_1/models/cart.dart';
import 'package:flutter_application_1/services/cart_service.dart';
import 'package:flutter_application_1/services/cart_storage_service.dart';
import 'package:flutter_application_1/services/inventory_service.dart';
import 'package:flutter_application_1/services/inventory_storage_service.dart';
import 'package:flutter_application_1/services/profile_storage_service.dart';

class HomeRootScreen extends StatefulWidget {
  const HomeRootScreen({super.key});

  @override
  State<HomeRootScreen> createState() => _HomeRootScreenState();
}

class _HomeRootScreenState extends State<HomeRootScreen> {
  final ProfileStorageService _profileStorage = ProfileStorageService();
  DogProfile? _dogProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _restoreProfile();
  }

  Future<void> _restoreProfile() async {
    final DogProfile? storedProfile = await _profileStorage.loadProfile();
    if (!mounted) {
      return;
    }

    setState(() {
      _dogProfile = storedProfile;
      _isLoading = false;
    });
  }

  Future<void> _createProfile(DogProfile profile) async {
    await _profileStorage.saveProfile(profile);
    if (!mounted) {
      return;
    }

    setState(() {
      _dogProfile = profile;
    });
  }

  Future<void> _resetProfile() async {
    await _profileStorage.clearProfile();
    if (!mounted) {
      return;
    }

    setState(() {
      _dogProfile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_dogProfile == null) {
      return OnboardingScreen(
        onCreateProfile: _createProfile,
      );
    }

    return DashboardScreen(
      profile: _dogProfile!,
      catalog: mockCatalog,
      onResetProfile: _resetProfile,
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onCreateProfile});

  final Future<void> Function(DogProfile profile) onCreateProfile;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BreedAnalysisApi _breedAnalysisApi = MockBreedAnalysisApi();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _healthController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  DogGender _gender = DogGender.male;
  ActivityLevel _activity = ActivityLevel.medium;
  BreedAnalysisResult? _analysisResult;
  bool _isAnalyzingBreed = false;
  String? _selectedImageName;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _healthController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final List<String> conditions = _healthController.text
        .split(',')
        .map((String value) => value.trim().toLowerCase())
        .where((String value) => value.isNotEmpty)
        .toList();

    await widget.onCreateProfile(
      DogProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerId: 'owner-demo-1',
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        ageInMonths: int.parse(_ageController.text.trim()),
        weightKg: double.parse(_weightController.text.trim()),
        gender: _gender,
        activityLevel: _activity,
        healthConditions: conditions,
        imagePath: _imageController.text.trim().isEmpty
            ? null
            : _imageController.text.trim(),
      ),
    );
  }

  Future<void> _analyzeBreed() async {
    final String imagePath = _imageController.text.trim();
    if (imagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an image path first to run breed analysis.')),
      );
      return;
    }

    setState(() {
      _isAnalyzingBreed = true;
    });

    final BreedAnalysisResult result = await _breedAnalysisApi.analyzeBreed(
      BreedAnalysisRequest(
        imagePath: imagePath,
        dogName: _nameController.text.trim(),
        ownerNotes: _healthController.text.trim(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _analysisResult = result;
      _isAnalyzingBreed = false;
      if (_breedController.text.trim().isEmpty) {
        _breedController.text = result.primaryBreed;
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      imageQuality: 90,
    );

    if (pickedFile == null || !mounted) {
      return;
    }

    setState(() {
      _imageController.text = pickedFile.path;
      _selectedImageName = pickedFile.name;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected image: ${pickedFile.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Dog Care - Onboarding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Create your dog profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'MVP Phase 1 captures core dog info and generates a personalized plan.',
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.image_search, size: 28),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Dog photo upload',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text('Upload a photo to run breed analysis with the selected image.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Choose Image'),
                          ),
                          FilledButton.icon(
                            onPressed: _isAnalyzingBreed ? null : _analyzeBreed,
                            icon: _isAnalyzingBreed
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(_isAnalyzingBreed ? 'Analyzing...' : 'Analyze Breed'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_selectedImageName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Selected file: $_selectedImageName',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      TextFormField(
                        controller: _imageController,
                        decoration: const InputDecoration(
                          labelText: 'Dog photo path',
                          hintText: 'Filled automatically after choosing an image',
                        ),
                      ),
                      if (_analysisResult != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Breed analysis result',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_analysisResult!.primaryBreed} ${(100 * _analysisResult!.confidence).round()}% confidence',
                              ),
                              Text('Body condition: ${_analysisResult!.bodyCondition}'),
                              const SizedBox(height: 6),
                              ..._analysisResult!.notes.map(
                                (String note) => Text('- $note'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Dog name'),
                validator: (String? value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Breed / Type'),
                validator: (String? value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age (months)'),
                validator: (String? value) {
                  final int? parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter valid age in months';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                validator: (String? value) {
                  final double? parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter valid weight';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<DogGender>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: DogGender.values
                    .map(
                      (DogGender g) => DropdownMenuItem<DogGender>(
                        value: g,
                        child: Text(g.name),
                      ),
                    )
                    .toList(),
                onChanged: (DogGender? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              DropdownButtonFormField<ActivityLevel>(
                initialValue: _activity,
                decoration: const InputDecoration(labelText: 'Activity level'),
                items: ActivityLevel.values
                    .map(
                      (ActivityLevel a) => DropdownMenuItem<ActivityLevel>(
                        value: a,
                        child: Text(a.name),
                      ),
                    )
                    .toList(),
                onChanged: (ActivityLevel? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _activity = value;
                  });
                },
              ),
              TextFormField(
                controller: _healthController,
                decoration: const InputDecoration(
                  labelText: 'Health conditions (comma separated, optional)',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: const Text('Generate AI Care Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.profile,
    required this.catalog,
    required this.onResetProfile,
  });

  final DogProfile profile;
  final List<Product> catalog;
  final VoidCallback onResetProfile;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AiRecommendationService _aiService = AiRecommendationService();
  final InventoryStorageService _inventoryStorage = InventoryStorageService();
  final InventoryService _inventoryService = InventoryService();
  final CartStorageService _cartStorage = CartStorageService();
  final CartService _cartService = CartService();
  int _selectedIndex = 0;
  late CarePlan _plan;
  FoodInventory? _inventory;
  Cart _cart = Cart();

  @override
  void initState() {
    super.initState();
    _plan = _aiService.generatePlan(profile: widget.profile, catalog: widget.catalog);
    _loadInventory();
    _loadCart();
  }

  Future<void> _loadInventory() async {
    final FoodInventory? saved = await _inventoryStorage.loadInventory(widget.profile.id);
    if (!mounted) return;
    setState(() => _inventory = saved);
  }

  Future<void> _saveInventory(FoodInventory inventory) async {
    await _inventoryStorage.saveInventory(inventory);
    if (!mounted) return;
    setState(() => _inventory = inventory);
  }

  Future<void> _loadCart() async {
    final Cart saved = await _cartStorage.loadCart(widget.profile.id);
    if (!mounted) return;
    setState(() => _cart = saved);
  }

  Future<void> _saveCart(Cart cart) async {
    await _cartStorage.saveCart(widget.profile.id, cart);
    if (!mounted) return;
    setState(() => _cart = cart);
  }

  @override
  Widget build(BuildContext context) {
    final int cartBadge = _cart.itemCount;
    final List<Widget> pages = <Widget>[
      _OverviewTab(profile: widget.profile, plan: _plan),
      _StoreTab(
        products: _plan.productSuggestions,
        cart: _cart,
        onAddOneTime: (Product p) async {
          await _saveCart(_cartService.addOneTime(_cart, p));
        },
        onAddSubscription: (Product p, SubscriptionFrequency freq) async {
          await _saveCart(_cartService.addSubscription(_cart, p, freq));
        },
      ),
      _RemindersTab(reminders: _plan.reminders),
      _InventoryTab(
        inventory: _inventory,
        dailyPortionGrams: _inventoryService.dailyPortionGramsFromPlan(_plan),
        onLogPurchase: (String productName, String sku, double bagKg) async {
          final FoodInventory next = _inventory == null
              ? _inventoryService.createInventory(
                  dogProfileId: widget.profile.id,
                  productName: productName,
                  productSku: sku,
                  bagWeightKg: bagKg,
                  dailyPortionGrams:
                      _inventoryService.dailyPortionGramsFromPlan(_plan),
                )
              : _inventoryService.restock(_inventory!, bagKg);
          await _saveInventory(next);
        },
        onConsumeDay: _inventory == null
            ? null
            : () async {
                await _saveInventory(
                    _inventoryService.consumeDay(_inventory!));
              },
      ),
      _CartTab(
        cart: _cart,
        onRemove: (String sku) async {
          await _saveCart(_cartService.remove(_cart, sku));
        },
        onSetQuantity: (String sku, int qty) async {
          await _saveCart(_cartService.setQuantity(_cart, sku, qty));
        },
        onClearCart: () async {
          await _cartStorage.clearCart(widget.profile.id);
          if (!mounted) return;
          setState(() => _cart = Cart());
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Dog Care - ${widget.profile.name}'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reset profile',
            onPressed: widget.onResetProfile,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: <NavigationDestination>[
          const NavigationDestination(icon: Icon(Icons.pets), label: 'Plan'),
          const NavigationDestination(icon: Icon(Icons.store), label: 'Store'),
          const NavigationDestination(icon: Icon(Icons.notifications_active), label: 'Reminders'),
          const NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Inventory'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartBadge > 0,
              label: Text('$cartBadge'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.profile, required this.plan});

  final DogProfile profile;
  final CarePlan plan;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: ListTile(
            title: Text('${profile.name} (${profile.breed})'),
            subtitle: Text('Age: ${profile.ageInMonths} months | Weight: ${profile.weightKg} kg'),
            trailing: const Icon(Icons.account_circle),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Daily calories: ${plan.dailyCalories} kcal', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text('Food type: ${plan.foodType}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Feeding schedule', style: Theme.of(context).textTheme.titleMedium),
        ...plan.feedingSchedule.map(
          (FeedingScheduleEntry entry) => ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(entry.timeLabel),
            subtitle: Text('${entry.portionGrams} g per meal'),
          ),
        ),
        const Divider(),
        Text('Health alerts', style: Theme.of(context).textTheme.titleMedium),
        ...plan.healthAlerts.map(
          (String alert) => ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: Text(alert),
          ),
        ),
      ],
    );
  }
}

class _StoreTab extends StatelessWidget {
  const _StoreTab({
    required this.products,
    required this.cart,
    required this.onAddOneTime,
    required this.onAddSubscription,
  });

  final List<Product> products;
  final Cart cart;
  final Future<void> Function(Product) onAddOneTime;
  final Future<void> Function(Product, SubscriptionFrequency) onAddSubscription;

  void _showSubscribeSheet(BuildContext context, Product product) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => _SubscribeSheet(
        product: product,
        onSubscribe: (SubscriptionFrequency freq) {
          Navigator.pop(ctx);
          onAddSubscription(product, freq);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} added as ${freq.name} subscription (-10%).'),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (BuildContext context, int index) {
        final Product product = products[index];
        final bool inCart =
            cart.items.any((CartItem i) => i.sku == product.sku);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(product.description,
                              style: Theme.of(context).textTheme.bodySmall),
                          Text('SKU: ${product.sku}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () {
                        onAddOneTime(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart.'),
                          ),
                        );
                      },
                      icon: Icon(
                          inCart ? Icons.check : Icons.add_shopping_cart,
                          size: 18),
                      label: Text(inCart ? 'In cart' : 'Add to cart'),
                    ),
                    if (product.isSubscriptionEligible)
                      OutlinedButton.icon(
                        onPressed: () =>
                            _showSubscribeSheet(context, product),
                        icon: const Icon(Icons.autorenew, size: 18),
                        label: const Text('Subscribe (-10%)'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubscribeSheet extends StatefulWidget {
  const _SubscribeSheet({
    required this.product,
    required this.onSubscribe,
  });

  final Product product;
  final void Function(SubscriptionFrequency) onSubscribe;

  @override
  State<_SubscribeSheet> createState() => _SubscribeSheetState();
}

class _SubscribeSheetState extends State<_SubscribeSheet> {
  SubscriptionFrequency _frequency = SubscriptionFrequency.monthly;

  @override
  Widget build(BuildContext context) {
    final double discounted =
        widget.product.price * (1 - CartItem.subscriptionDiscountRate);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Subscribe to ${widget.product.name}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '\$${discounted.toStringAsFixed(2)} / delivery  (10% off retail)',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          ...SubscriptionFrequency.values.map(
            (SubscriptionFrequency f) => RadioListTile<SubscriptionFrequency>(
              title: Text(_frequencyLabel(f)),
              value: f,
              groupValue: _frequency,
              onChanged: (SubscriptionFrequency? v) {
                if (v != null) setState(() => _frequency = v);
              },
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => widget.onSubscribe(_frequency),
            child: const Text('Confirm subscription'),
          ),
        ],
      ),
    );
  }

  String _frequencyLabel(SubscriptionFrequency f) {
    switch (f) {
      case SubscriptionFrequency.weekly:
        return 'Weekly';
      case SubscriptionFrequency.biWeekly:
        return 'Every 2 weeks';
      case SubscriptionFrequency.monthly:
        return 'Monthly';
    }
  }
}

class _RemindersTab extends StatelessWidget {
  const _RemindersTab({required this.reminders});

  final List<ReminderItem> reminders;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: reminders
          .map(
            (ReminderItem item) => Card(
              child: ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(item.title),
                subtitle: Text(item.message),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InventoryTab extends StatefulWidget {
  const _InventoryTab({
    required this.inventory,
    required this.dailyPortionGrams,
    required this.onLogPurchase,
    required this.onConsumeDay,
  });

  final FoodInventory? inventory;
  final int dailyPortionGrams;
  final Future<void> Function(String productName, String sku, double bagKg) onLogPurchase;
  final Future<void> Function()? onConsumeDay;

  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _bagKgController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _productNameController.dispose();
    _skuController.dispose();
    _bagKgController.dispose();
    super.dispose();
  }

  Future<void> _submitPurchase() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    await widget.onLogPurchase(
      _productNameController.text.trim(),
      _skuController.text.trim(),
      double.parse(_bagKgController.text.trim()),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    _productNameController.clear();
    _skuController.clear();
    _bagKgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final FoodInventory? inv = widget.inventory;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (inv != null) ...[
          if (inv.isLowStock)
            Card(
              color: colors.errorContainer,
              child: ListTile(
                leading: Icon(Icons.warning_amber_rounded,
                    color: colors.onErrorContainer),
                title: Text(
                  inv.daysRemaining < 1
                      ? 'Food is empty — reorder now!'
                      : 'Low stock: ~${inv.daysRemaining.ceil()} day(s) left',
                  style: TextStyle(color: colors.onErrorContainer),
                ),
                subtitle: Text(
                  'Estimated depletion: ${_formatDate(inv.estimatedDepletionDate)}',
                  style: TextStyle(color: colors.onErrorContainer),
                ),
              ),
            )
          else if (inv.shouldReorder)
            Card(
              color: colors.tertiaryContainer,
              child: ListTile(
                leading: Icon(Icons.shopping_bag_outlined,
                    color: colors.onTertiaryContainer),
                title: Text(
                  'Reorder soon: ~${inv.daysRemaining.ceil()} day(s) left',
                  style: TextStyle(color: colors.onTertiaryContainer),
                ),
                subtitle: Text(
                  'Estimated depletion: ${_formatDate(inv.estimatedDepletionDate)}',
                  style: TextStyle(color: colors.onTertiaryContainer),
                ),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Current bag', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Text('Product: ${inv.productName}'),
                  Text('SKU: ${inv.productSku}'),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: inv.purchasedGrams > 0
                        ? (inv.remainingGrams / inv.purchasedGrams).clamp(0.0, 1.0)
                        : 0,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${inv.remainingGrams.round()} g remaining of ${inv.purchasedGrams.round()} g',
                  ),
                  Text('Daily portion: ${inv.dailyPortionGrams} g/day'),
                  Text(
                    'Estimated to last until: ${_formatDate(inv.estimatedDepletionDate)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: widget.onConsumeDay,
            icon: const Icon(Icons.restaurant),
            label: const Text('Log today\'s feeding (−${0}g)'),
          ).withDailyLabel(inv.dailyPortionGrams),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
        ],
        Text(
          inv == null ? 'Log your first food purchase' : 'Restock / new bag',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _productNameController,
                decoration:
                    const InputDecoration(labelText: 'Product name'),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _skuController,
                decoration:
                    const InputDecoration(labelText: 'SKU (optional)'),
              ),
              TextFormField(
                controller: _bagKgController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Bag size (kg)'),
                validator: (String? v) {
                  final double? parsed = double.tryParse(v ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid bag weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSaving ? null : _submitPurchase,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_shopping_cart),
                label: Text(_isSaving ? 'Saving...' : 'Log purchase'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

extension on FilledButton {
  Widget withDailyLabel(int dailyGrams) {
    return FilledButton.icon(
      onPressed: (this as FilledButton).onPressed,
      icon: const Icon(Icons.restaurant),
      label: Text('Log today\'s feeding (−${dailyGrams}g)'),
    );
  }
}

class _CartTab extends StatelessWidget {
  const _CartTab({
    required this.cart,
    required this.onRemove,
    required this.onSetQuantity,
    required this.onClearCart,
  });

  final Cart cart;
  final Future<void> Function(String sku) onRemove;
  final Future<void> Function(String sku, int qty) onSetQuantity;
  final Future<void> Function() onClearCart;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.shopping_cart_outlined, size: 64, color: colors.outlineVariant),
            const SizedBox(height: 16),
            Text('Your smart cart is empty',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Add products from the Store tab.'),
          ],
        ),
      );
    }

    final List<CartItem> oneTime = cart.items
        .where((CartItem i) => i.type == CartItemType.oneTime)
        .toList();
    final List<CartItem> subscriptions = cart.items
        .where((CartItem i) => i.type == CartItemType.subscription)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (cart.hasSubscriptions)
          Card(
            color: colors.primaryContainer,
            child: ListTile(
              leading: Icon(Icons.autorenew, color: colors.onPrimaryContainer),
              title: Text('Subscription items get 10% off',
                  style: TextStyle(color: colors.onPrimaryContainer)),
            ),
          ),
        if (subscriptions.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text('Subscriptions', style: Theme.of(context).textTheme.titleMedium),
          ..._buildItemList(context, subscriptions, isSubscription: true),
        ],
        if (oneTime.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text('One-time items', style: Theme.of(context).textTheme.titleMedium),
          ..._buildItemList(context, oneTime, isSubscription: false),
        ],
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Subtotal', style: Theme.of(context).textTheme.titleMedium),
            Text(
              '\$${cart.subtotal.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Checkout stub — connect payment backend here.'),
              ),
            );
          },
          icon: const Icon(Icons.payment),
          label: Text(
            cart.hasSubscriptions ? 'Confirm & Subscribe' : 'Proceed to Checkout',
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () async {
            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (BuildContext ctx) => AlertDialog(
                title: const Text('Clear cart?'),
                content: const Text('All items will be removed.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await onClearCart();
            }
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear cart'),
        ),
      ],
    );
  }

  List<Widget> _buildItemList(
    BuildContext context,
    List<CartItem> items, {
    required bool isSubscription,
  }) {
    return items.map((CartItem item) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.productName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (isSubscription)
                      Text(
                        '${_frequencyLabel(item.frequency)}  •  '
                        '\$${item.unitPrice.toStringAsFixed(2)} each',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Text(
                        '\$${item.unitPrice.toStringAsFixed(2)} each',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    Text(
                      'Line total: \$${item.lineTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => onSetQuantity(item.sku, item.quantity - 1),
                  ),
                  Text('${item.quantity}',
                      style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => onSetQuantity(item.sku, item.quantity + 1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onRemove(item.sku),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _frequencyLabel(SubscriptionFrequency f) {
    switch (f) {
      case SubscriptionFrequency.weekly:
        return 'Weekly';
      case SubscriptionFrequency.biWeekly:
        return 'Every 2 weeks';
      case SubscriptionFrequency.monthly:
        return 'Monthly';
    }
  }
}
