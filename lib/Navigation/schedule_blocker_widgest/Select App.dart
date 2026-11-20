import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:focus_guard/utils/Utils.dart';

import 'app_icons.dart';
class SelectApp extends StatefulWidget {
  const SelectApp({
    super.key,
    this.initiallySelected = const [],
  });

  final List<String> initiallySelected;

  @override
  State<SelectApp> createState() => _SelectAppState();
}

class _SelectAppState extends State<SelectApp> {
  bool _isFetching = true;
  List<AppInfo> _apps = [];
  late final Set<String> _selectedApps;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedApps = widget.initiallySelected.toSet();
    _loadApps();
  }

  Future<void> _loadApps() async {
    // Refresh চাপলেও স্পিনার দেখাবে
    setState(() => _isFetching = true);

    try {
      final List<AppInfo> apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        excludeNonLaunchableApps: true,
        withIcon: true,
      );

      // A-Z সাজানো
      apps.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      if (!mounted) return;

      setState(() {
        _apps = apps;
        _isFetching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isFetching = false);
      debugPrint('Error loading apps: $e');
      Utels.failToset('Failed to load apps: $e');

    }
  }

  List<AppInfo> _filterApps() {
    if (_searchQuery.isEmpty) return _apps;

    return _apps.where((app) {
      return app.name.toLowerCase().contains(_searchQuery) ||
          app.packageName.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _toggleApp(AppInfo app) {
    setState(() {
      if (!_selectedApps.remove(app.packageName)) {
        _selectedApps.add(app.packageName);
      }
    });
  }

  void _saveSelectedApps() {
    Navigator.pop(context, _selectedApps.toList());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // build-এ একবারই ফিল্টার হবে
    final filteredApps = _filterApps();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Apps to Block'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isFetching ? null : _loadApps,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : _apps.isEmpty
          ? const Center(child: Text('No apps found!'))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Installed Applications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_selectedApps.length} Selected',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(Icons.close),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredApps.isEmpty
                ? const Center(child: Text('No matching apps found'))
                : ListView.builder(
              itemCount: filteredApps.length,
              itemBuilder: (context, index) {
                final app = filteredApps[index];
                final isSelected =
                _selectedApps.contains(app.packageName);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => _toggleApp(app),
                    activeColor: colorScheme.primary,
                    secondary: AppIcon(icon: app.icon),
                    title: Text(
                      app.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      app.packageName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedApps.isEmpty
                      ? null
                      : _saveSelectedApps,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Selected Apps (${_selectedApps.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

