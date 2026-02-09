import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
/// A generic searchable dropdown dialog that can be used with any data type.
///
/// Example usage:
/// ```dart
/// final selected = await showDialog<ContactDetail>(
///   context: context,
///   builder: (context) => SearchableDropdownDialog<ContactDetail>(
///     items: contacts,
///     currentSelection: selectedContact,
///     title: 'Select Person',
///     icon: Icons.person,
///     searchHint: 'Search by name or email...',
///     itemBuilder: (contact, isSelected) => ListTile(
///       title: Text(contact.name),
///       subtitle: Text(contact.email),
///     ),
///     searchMatcher: (contact, query) =>
///       contact.name.toLowerCase().contains(query) ||
///       contact.email.toLowerCase().contains(query),
///     itemId: (contact) => contact.id,
///   ),
/// );
/// ```
class SearchableDropdownDialog<T> extends StatefulWidget {
  /// The list of items to display
  final List<T> items;

  /// The currently selected item (optional)
  final T? currentSelection;

  /// Dialog title
  final String title;

  /// Icon to show in the header
  final IconData icon;

  /// Hint text for the search field
  final String searchHint;

  /// Label text for the search field
  final String searchLabel;

  /// Empty state message when no items match the search
  final String emptyMessage;

  /// Empty state hint when no items match the search
  final String emptyHint;

  /// Function to determine if an item matches the search query
  /// The query is already lowercased
  final bool Function(T item, String query) searchMatcher;

  /// Function to get a unique ID for each item (used to compare with currentSelection)
  final String Function(T item) itemId;

  /// Function to get the display name for an item (used in the avatar)
  final String Function(T item) itemName;

  /// Function to get the subtitle for an item (optional)
  final String? Function(T item)? itemSubtitle;

  /// Custom item builder (optional) - if provided, overrides default ListTile
  final Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder;

  /// Whether to autofocus the search field on non-small screens
  final bool autofocusSearch;

  const SearchableDropdownDialog({
    super.key,
    required this.items,
    required this.title,
    required this.searchMatcher,
    required this.itemId,
    required this.itemName,
    this.currentSelection,
    this.icon = Icons.list,
    this.searchHint = 'Search...',
    this.searchLabel = 'Search',
    this.emptyMessage = 'No items found',
    this.emptyHint = 'Try adjusting your search',
    this.itemSubtitle,
    this.itemBuilder,
    this.autofocusSearch = true,
  });

  @override
  State<SearchableDropdownDialog<T>> createState() =>
      _SearchableDropdownDialogState<T>();
}

class _SearchableDropdownDialogState<T>
    extends State<SearchableDropdownDialog<T>> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      if (_searchQuery.isEmpty) return true;
      return widget.searchMatcher(item, _searchQuery.toLowerCase());
    }).toList();

    // Get screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = AppBreakpoints.isSmallScreen(screenWidth);
    final dialogMaxWidth = AppBreakpoints.getDialogMaxWidth(screenWidth);
    final dialogHeight = AppBreakpoints.getDialogHeight(screenHeight);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: dialogHeight,
          maxWidth: dialogMaxWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(isSmallScreen),

            // Search field
            _buildSearchField(isSmallScreen),

            // Results count
            _buildResultsCount(filteredItems.length),

            const SizedBox(height: 12),

            // Item list
            Flexible(
              child: filteredItems.isEmpty
                  ? _buildEmptyState(isSmallScreen, dialogHeight)
                  : _buildItemList(filteredItems, isSmallScreen),
            ),

            // Footer with cancel button
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.icon,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate900,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: TextField(
        controller: _searchCtrl,
        autofocus: widget.autofocusSearch && !isSmallScreen,
        decoration: InputDecoration(
          labelText: widget.searchLabel,
          hintText: widget.searchHint,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchCtrl.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildResultsCount(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$count item${count == 1 ? '' : 's'} found',
          style: TextStyle(
            color: AppTheme.slate600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen, double dialogHeight) {
    return Container(
      constraints: BoxConstraints(
        minHeight: isSmallScreen ? 150 : 200,
        maxHeight: dialogHeight * 0.5,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: isSmallScreen ? 48 : 64,
                color: AppTheme.slate400,
              ),
              const SizedBox(height: 16),
              Text(
                widget.emptyMessage,
                style: TextStyle(
                  color: AppTheme.slate700,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.emptyHint,
                style: TextStyle(
                  color: AppTheme.slate600,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemList(List<T> items, bool isSmallScreen) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = widget.currentSelection != null &&
            widget.itemId(widget.currentSelection as T) == widget.itemId(item);

        // Use custom builder if provided
        if (widget.itemBuilder != null) {
          return GestureDetector(
            onTap: () => Navigator.pop(context, item),
            child: widget.itemBuilder!(context, item, isSelected),
          );
        }

        // Default ListTile implementation
        return _buildDefaultListTile(item, isSelected, isSmallScreen);
      },
    );
  }

  Widget _buildDefaultListTile(T item, bool isSelected, bool isSmallScreen) {
    final name = widget.itemName(item);
    final subtitle = widget.itemSubtitle?.call(item);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? AppTheme.primaryBlue.withValues(alpha: 0.1)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.slate200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 4 : 8,
        ),
        leading: CircleAvatar(
          backgroundColor:
              isSelected ? AppTheme.primaryBlue : AppTheme.slate400,
          radius: isSmallScreen ? 20 : 24,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        subtitle: subtitle != null && subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 12,
                ),
              )
            : null,
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: isSmallScreen ? 20 : 24,
              )
            : Icon(
                Icons.arrow_forward_ios,
                size: isSmallScreen ? 14 : 16,
                color: AppTheme.slate400,
              ),
        onTap: () => Navigator.pop(context, item),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.slate50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
      ),
    );
  }
}

/// A dropdown field widget that opens a searchable dialog when tapped.
/// This is the button/field component that you place in your form.
///
/// Example usage:
/// ```dart
/// SearchableDropdownField<ContactDetail>(
///   value: selectedContact,
///   items: contacts,
///   onChanged: (contact) => setState(() => selectedContact = contact),
///   dialogTitle: 'Select Person',
///   dialogIcon: Icons.person,
///   placeholder: 'Select person',
///   icon: Icons.person,
///   itemName: (c) => c.name,
///   itemSubtitle: (c) => c.email,
///   itemId: (c) => c.id,
///   searchMatcher: (c, q) => c.name.toLowerCase().contains(q),
/// )
/// ```
class SearchableDropdownField<T> extends StatelessWidget {
  /// Current selected value
  final T? value;

  /// List of items to select from
  final List<T> items;

  /// Callback when selection changes
  final ValueChanged<T?> onChanged;

  /// Dialog title
  final String dialogTitle;

  /// Dialog header icon
  final IconData dialogIcon;

  /// Placeholder text when nothing is selected
  final String placeholder;

  /// Icon to show in the field
  final IconData icon;

  /// Function to get display name
  final String Function(T item) itemName;

  /// Function to get subtitle (optional)
  final String? Function(T item)? itemSubtitle;

  /// Function to get unique ID
  final String Function(T item) itemId;

  /// Search matcher function
  final bool Function(T item, String query) searchMatcher;

  /// Search hint in dialog
  final String searchHint;

  /// Empty state message
  final String emptyMessage;

  /// Empty state hint
  final String emptyHint;

  /// Whether to show clear button when value is selected
  final bool showClearButton;

  /// Custom item builder for dialog list
  final Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder;

  const SearchableDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.dialogTitle,
    required this.itemName,
    required this.itemId,
    required this.searchMatcher,
    this.dialogIcon = Icons.list,
    this.placeholder = 'Select...',
    this.icon = Icons.list,
    this.itemSubtitle,
    this.searchHint = 'Search...',
    this.emptyMessage = 'No items found',
    this.emptyHint = 'Try adjusting your search',
    this.showClearButton = true,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dropdown button
        InkWell(
          onTap: () async {
            final selected = await showSearchableDropdown<T>(
              context: context,
              items: items,
              currentSelection: value,
              title: dialogTitle,
              icon: dialogIcon,
              searchHint: searchHint,
              emptyMessage: emptyMessage,
              emptyHint: emptyHint,
              searchMatcher: searchMatcher,
              itemId: itemId,
              itemName: itemName,
              itemSubtitle: itemSubtitle,
              itemBuilder: itemBuilder,
            );
            if (selected != null) {
              onChanged(selected);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.slate300,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.slate600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: value != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemName(value as T),
                              style: TextStyle(
                                color: AppTheme.slate900,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (itemSubtitle != null &&
                                (itemSubtitle!(value as T)?.isNotEmpty ?? false))
                              Text(
                                itemSubtitle!(value as T)!,
                                style: TextStyle(
                                  color: AppTheme.slate600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        )
                      : Text(
                          placeholder,
                          style: TextStyle(
                            color: AppTheme.slate500,
                            fontSize: 16,
                          ),
                        ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.slate600,
                ),
              ],
            ),
          ),
        ),

        // Success indicator and clear button
        if (value != null && showClearButton) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Selected',
                style: TextStyle(
                  color: AppTheme.successColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.slate600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A helper function to show the SearchableDropdownDialog
/// Returns the selected item or null if cancelled
Future<T?> showSearchableDropdown<T>({
  required BuildContext context,
  required List<T> items,
  required String title,
  required bool Function(T item, String query) searchMatcher,
  required String Function(T item) itemId,
  required String Function(T item) itemName,
  T? currentSelection,
  IconData icon = Icons.list,
  String searchHint = 'Search...',
  String searchLabel = 'Search',
  String emptyMessage = 'No items found',
  String emptyHint = 'Try adjusting your search',
  String? Function(T item)? itemSubtitle,
  Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder,
  bool autofocusSearch = true,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => SearchableDropdownDialog<T>(
      items: items,
      currentSelection: currentSelection,
      title: title,
      icon: icon,
      searchHint: searchHint,
      searchLabel: searchLabel,
      emptyMessage: emptyMessage,
      emptyHint: emptyHint,
      searchMatcher: searchMatcher,
      itemId: itemId,
      itemName: itemName,
      itemSubtitle: itemSubtitle,
      itemBuilder: itemBuilder,
      autofocusSearch: autofocusSearch,
    ),
  );
}
