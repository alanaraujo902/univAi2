import 'package:flutter/material.dart';
import 'package:study_app/constants/app_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool showFilter;
  final VoidCallback? onFilterTap;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.showFilter = false,
    this.onFilterTap,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _showClearButton = _controller.text.isNotEmpty;
    
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Pesquisar...',
                hintStyle: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                ),
                suffixIcon: _showClearButton
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.clear,
                          color: AppTheme.textSecondary,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),
          if (widget.showFilter) ...[
            Container(
              width: 1,
              height: 24,
              color: Colors.grey[300],
            ),
            IconButton(
              onPressed: widget.onFilterTap,
              icon: const Icon(
                Icons.tune,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }
}

class SearchBarWithSuggestions extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final List<String> suggestions;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function(String)? onSuggestionSelected;

  const SearchBarWithSuggestions({
    super.key,
    this.controller,
    this.hintText,
    required this.suggestions,
    this.onChanged,
    this.onSubmitted,
    this.onSuggestionSelected,
  });

  @override
  State<SearchBarWithSuggestions> createState() => _SearchBarWithSuggestionsState();
}

class _SearchBarWithSuggestionsState extends State<SearchBarWithSuggestions> {
  late TextEditingController _controller;
  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    _controller.addListener(() {
      _filterSuggestions(_controller.text);
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _filterSuggestions(String query) {
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    _filteredSuggestions = widget.suggestions
        .where((suggestion) => 
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();

    if (_filteredSuggestions.isNotEmpty) {
      _showSuggestionsOverlay();
    } else {
      _removeOverlay();
    }

    widget.onChanged?.call(query);
  }

  void _showSuggestionsOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.search,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    title: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      _controller.text = suggestion;
                      _removeOverlay();
                      widget.onSuggestionSelected?.call(suggestion);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomSearchBar(
        controller: _controller,
        hintText: widget.hintText,
        onSubmitted: (value) {
          _removeOverlay();
          widget.onSubmitted?.call(value);
        },
        onClear: _removeOverlay,
      ),
    );
  }
}

class SearchFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const SearchFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor 
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? Colors.white 
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? Colors.white 
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchFilters extends StatelessWidget {
  final List<SearchFilter> filters;
  final Function(String, bool) onFilterChanged;

  const SearchFilters({
    super.key,
    required this.filters,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return SearchFilterChip(
            label: filter.label,
            isSelected: filter.isSelected,
            icon: filter.icon,
            onTap: () => onFilterChanged(filter.key, !filter.isSelected),
          );
        },
      ),
    );
  }
}

class SearchFilter {
  final String key;
  final String label;
  final bool isSelected;
  final IconData? icon;

  SearchFilter({
    required this.key,
    required this.label,
    required this.isSelected,
    this.icon,
  });
}

class SearchHistory extends StatelessWidget {
  final List<String> history;
  final Function(String) onHistoryItemTap;
  final Function(String) onHistoryItemDelete;

  const SearchHistory({
    super.key,
    required this.history,
    required this.onHistoryItemTap,
    required this.onHistoryItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Pesquisas recentes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ...history.take(5).map((item) => _buildHistoryItem(item)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String item) {
    return ListTile(
      dense: true,
      leading: const Icon(
        Icons.history,
        size: 20,
        color: AppTheme.textSecondary,
      ),
      title: Text(
        item,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: IconButton(
        onPressed: () => onHistoryItemDelete(item),
        icon: const Icon(
          Icons.close,
          size: 16,
          color: AppTheme.textSecondary,
        ),
      ),
      onTap: () => onHistoryItemTap(item),
    );
  }
}

