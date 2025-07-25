import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/category_providers.dart';
import 'dart:convert';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late CategoryProvider _categoryProvider;
  List<Category> _categories = [];
  List<Category> _allCategories = [];
  String _filter = 'All';
  List<bool> _selectedFilters = [true, false, false];
  final TextEditingController _newCategoryController = TextEditingController();
  bool _isAddingCategory = false;

  int get activeCount => _allCategories.where((c) => c.isActive ?? false).length;
  int get inactiveCount => _allCategories.where((c) => !(c.isActive ?? false)).length;

  @override
  void initState() {
    super.initState();
    _categoryProvider = context.read<CategoryProvider>();
    _fetchCategories();
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      var allResult = await _categoryProvider.get();
      var filteredResult = await _categoryProvider.get(
        filter: {
          if (_filter == 'Active') 'IsActive': 'true',
          if (_filter == 'Inactive') 'IsActive': 'false',
        },
      );
      
      setState(() {
        _allCategories = allResult.result;
        _categories = filteredResult.result;
      });
    } catch (e) {
      _showSnackBar("Failed to fetch categories: $e", Colors.red);
    }
  }

  Future<void> _addNewCategory() async {
    if (_newCategoryController.text.isEmpty) {
      _showSnackBar("Category name cannot be empty", Colors.red);
      return;
    }

    setState(() => _isAddingCategory = true);

    try {
      var response = await _categoryProvider.insert({
        'categoryName': _newCategoryController.text,
      });

      _showSnackBar("Category added successfully", Colors.green);
      _newCategoryController.clear();
      _fetchCategories();
    } catch (e) {
      String errorMessage = "Failed to add category";

      if (e is Map<String, dynamic>) {
        final errors = e['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.containsKey('userError')) {
          errorMessage = errors['userError'].first.toString();
        }
      } else {
        try {
          final decoded = jsonDecode(e.toString().replaceFirst('Exception: ', ''));
          final errors = decoded['errors'] as Map<String, dynamic>?;
          if (errors != null && errors.containsKey('userError')) {
            errorMessage = errors['userError'].first.toString();
          }
        } catch (_) {
          if (e.toString().contains("already exists")) {
            errorMessage = "Category '\${_newCategoryController.text}' already exists!";
          }
        }
      }

      _showSnackBar(errorMessage, Colors.red);
    } finally {
      setState(() => _isAddingCategory = false);
    }
  }

  Future<void> _toggleActive(Category category) async {
    try {
      if (category.isActive ?? false) {
        await _categoryProvider.deactivate(category.categoryID!);
        _showSnackBar("Category deactivated", Colors.orange);
      } else {
        await _categoryProvider.activate(category.categoryID!);
        _showSnackBar("Category activated", Colors.green);
      }
      _fetchCategories();
    } catch (e) {
      _showSnackBar("Failed to toggle status: $e", Colors.red);
    }
  }

  Future<void> _editCategoryName(Category category) async {
    final controller = TextEditingController(text: category.categoryName);
    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Category"),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (shouldUpdate == true) {
      try {
        await _categoryProvider.update(category.categoryID!, {
          'categoryName': controller.text,
        });
        _showSnackBar("Category updated", Colors.green);
        _fetchCategories();
      } catch (e) {
        _showSnackBar("Failed to update: $e", Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  Widget _buildFilterButton(String label, int count, int index) {
    final isSelected = _selectedFilters[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.black : Colors.white,
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onPressed: () {
          setState(() {
            for (int i = 0; i < _selectedFilters.length; i++) {
              _selectedFilters[i] = i == index;
            }
            _filter = label;
          });
          _fetchCategories();
        },
        child: Text(
          "$label ($count)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            tooltip: 'Add Category',
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton("All", _allCategories.length, 0),
                _buildFilterButton("Active", activeCount, 1),
                _buildFilterButton("Inactive", inactiveCount, 2),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 60,
                        horizontalMargin: 20,
                        headingRowHeight: 48,
                        dataRowHeight: 56,
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        columns: const [
                          DataColumn(label: Expanded(child: Text('Category Name'))),
                          DataColumn(label: Expanded(child: Text('Status'))),
                          DataColumn(label: Expanded(child: Text('Actions'))),
                        ],
                        rows: _categories.map((category) => DataRow(
                          cells: [
                            DataCell(Text(category.categoryName ?? '')),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (category.isActive ?? false)
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (category.isActive ?? false) ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: (category.isActive ?? false)
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )),
                            DataCell(Row(
                            children: [
                              Tooltip(
                                message: 'Edit category name',
                                child: IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  color: Colors.grey,
                                  onPressed: () => _editCategoryName(category),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Tooltip(
                                message: category.isActive ?? false
                                    ? 'Deactivate category'
                                    : 'Activate category',
                                child: IconButton(
                                  icon: Icon(
                                    (category.isActive ?? false)
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                  ),
                                  color: Colors.grey,
                                  onPressed: () => _toggleActive(category),
                                ),
                              ),
                            ],
                          )),

                          ],
                        )).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: _newCategoryController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter category name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                _addNewCategory();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
