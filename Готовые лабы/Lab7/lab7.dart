  // lab2_flutter_app_main.dart
  // Complete single-file Flutter app demonstrating requirements from the task.
  // Dependencies to add in pubspec.yaml:
  //   sqflite: ^2.2.8
  //   path_provider: ^2.0.15
  //   path: ^1.8.3
  //   uuid: ^3.0.7

  import 'dart:convert';
  import 'dart:io';
import 'dart:isolate';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:path/path.dart' as p;
  import 'package:path_provider/path_provider.dart';
  import 'package:sqflite/sqflite.dart';
  import 'package:uuid/uuid.dart';

  //CharacterListPage - список персонажей
  //
  // EditCharacterPage - редактирование/добавление
  //
  // StoragePage - демонстрация работы с файлами


  // ---------- Entities ----------
  class GameCharacter {
    String id; // uuid
    String name;
    String role;
    int health;
    int level;

    GameCharacter({
      required this.id,
      required this.name,
      required this.role,
      required this.health,
      required this.level,
    });

    GameCharacter.copy(GameCharacter other)
        : id = other.id,
          name = other.name,
          role = other.role,
          health = other.health,
          level = other.level;

    factory GameCharacter.fromJson(Map<String, dynamic> j) => GameCharacter(
      id: j['id'] as String,
      name: j['name'] as String,
      role: j['role'] as String,
      health: j['health'] as int,
      level: j['level'] as int,
    );

    Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'role': role,
      'health': health,
      'level': level,
    };
  }

  // ---------- SQLite helper (CRUD) ----------
  class DbHelper {
    static const _dbName = 'lab2_chars.db';
    static const _table = 'characters';
    static Database? _db;

    static Future<Database> _open() async {
      if (_db != null) return _db!;
      final databasesPath = await getDatabasesPath();
      final path = p.join(databasesPath, _dbName);
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, v) async {
          await db.execute('''
            CREATE TABLE $_table(
              id TEXT PRIMARY KEY,
              name TEXT,
              role TEXT,
              health INTEGER,
              level INTEGER
            )
          ''');
        },
      );
      return _db!;
    }

    static Future<void> insert(GameCharacter c) async {
      final db = await _open();
      await db.insert(_table, c.toJson());
    }

    static Future<void> update(GameCharacter c) async {
      final db = await _open();
      await db.update(_table, c.toJson(), where: 'id = ?', whereArgs: [c.id]);
    }

    static Future<void> delete(String id) async {
      final db = await _open();
      await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    }

    static Future<List<GameCharacter>> getAll({String? query, String? sortBy, bool asc = true}) async {
      final db = await _open();
      String where = '';
      List<dynamic> whereArgs = [];
      if (query != null && query.trim().isNotEmpty) {
        where = "WHERE name LIKE ? OR role LIKE ?";
        whereArgs = ['%$query%', '%$query%'];
      }
      String order = '';
      if (sortBy != null) {
        order = 'ORDER BY $sortBy ${asc ? 'ASC' : 'DESC'}';
      }
      final sql = 'SELECT * FROM $_table $where $order';
      final results = await db.rawQuery(sql, whereArgs);
      return results.map((r) => GameCharacter.fromJson(r)).toList();
    }
  }

  // ---------- File I/O helpers ----------
  class FileIoResult {
    final String path;
    final String data;
    FileIoResult(this.path, this.data);
  }

  // heavy work for isolate
  Future<String> _writeFileIsolate(Map<String, dynamic> payload) async {
    print('[ISOLATE] Started in isolate: ${Isolate.current.hashCode}');
    final path = payload['path'] as String;
    final text = payload['text'] as String;
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(text);
    print('[ISOLATE] Finished writing: $path');
    return path;
  }

  Future<String> _readFileIsolate(String path) async {
    debugPrint('[ISOLATE] Reading file in isolate ${Isolate.current.hashCode}');
    final file = File(path);
    if (!await file.exists()) throw Exception('File not found: $path');
    debugPrint('[ISOLATE] Finished writing: $path');
    return await file.readAsString();
  }

  class StorageService {
    // write JSON representation of entity into several directories
    static Future<FileIoResult> writeToDirectory(Directory dir, GameCharacter c) async {
      final filename = '${c.id}.json';
      final path = p.join(dir.path, filename);
      final jsonText = jsonEncode(c.toJson());
      // use compute to write in isolate
      final writtenPath = await compute(_writeFileIsolate, {'path': path, 'text': jsonText});
      return FileIoResult(writtenPath, jsonText);
    }

    static Future<String> readFromPath(String path) async {
      final content = await compute(_readFileIsolate, path);
      return content;
    }


    static Future<List<File>> listFilesInDir(Directory dir) async {
      if (!await dir.exists()) return [];
      try {
        final entities = await dir.list().toList();
        return entities.whereType<File>().where((f) => f.path.endsWith('.json')).toList();
      } catch (e) {
        return [];
      }
    }
  }

  // ---------- UI ----------
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const Lab2App());
  }

  class Lab2App extends StatelessWidget {
    const Lab2App({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Lab2 - Characters',
        theme: ThemeData(useMaterial3: true),
        home: const CharacterListPage(),
      );
    }
  }

  class CharacterListPage extends StatefulWidget {
    const CharacterListPage({super.key});

    @override
    State<CharacterListPage> createState() => _CharacterListPageState();
  }

  class _CharacterListPageState extends State<CharacterListPage> {
    List<GameCharacter> _items = [];
    String _query = '';
    String? _sortBy;
    bool _asc = true;
    final TextEditingController _searchController = TextEditingController();
    final uuid = const Uuid();

    @override
    void initState() {
      super.initState();
      _refresh();
    }

    Future<void> _refresh() async {
      final items = await DbHelper.getAll(query: _query, sortBy: _sortBy, asc: _asc);
      setState(() => _items = items);
    }

    void _onSearchChanged() {
      setState(() => _query = _searchController.text);
      _refresh();
    }

    Future<void> _addNew() async {
      final newChar = GameCharacter(
        id: uuid.v4(),
        name: 'New character',
        role: 'Adventurer',
        health: 100,
        level: 1,
      );
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => EditCharacterPage(character: newChar, isNew: true),
      ));
      await _refresh();
    }

    Future<void> _edit(GameCharacter c) async {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => EditCharacterPage(character: GameCharacter.copy(c), isNew: false),
      ));
      await _refresh();
    }

    Future<void> _delete(String id) async {
      await DbHelper.delete(id);
      await _refresh();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Players'),
          actions: [
            IconButton(
              icon: const Icon(Icons.storage),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StoragePage())),
              tooltip: 'Storage & files',
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                setState(() {
                  if (v == 'name' || v == 'level' || v == 'health' || v == 'role') _sortBy = v;
                  if (v == 'asc') _asc = true;
                  if (v == 'desc') _asc = false;
                });
                _refresh();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'level', child: Text('Sort by level')),
                const PopupMenuItem(value: 'health', child: Text('Sort by health')),
                const PopupMenuItem(value: 'role', child: Text('Sort by role')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'asc', child: Text('Ascending')),
                const PopupMenuItem(value: 'desc', child: Text('Descending')),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNew,
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search name or role'),
                onChanged: (_) => _onSearchChanged(),
              ),
            ),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No characters yet'))
                  : ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = _items[i];
                  return ListTile(
                    title: Text('${c.name} (Lv ${c.level})'),
                    subtitle: Text('${c.role} — HP ${c.health}'),
                    onTap: () => _edit(c),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete?'),
                            content: Text('Delete ${c.name}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                            ],
                          ),
                        );
                        if (ok == true) _delete(c.id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  // ---------- Edit/Add Page (single page) ----------
  class EditCharacterPage extends StatefulWidget {
    final GameCharacter character;
    final bool isNew;
    const EditCharacterPage({required this.character, required this.isNew, super.key});

    @override
    State<EditCharacterPage> createState() => _EditCharacterPageState();
  }

  class _EditCharacterPageState extends State<EditCharacterPage> {
    late TextEditingController _name;
    late TextEditingController _role;
    late TextEditingController _health;
    late TextEditingController _level;

    @override
    void initState() {
      super.initState();
      _name = TextEditingController(text: widget.character.name);
      _role = TextEditingController(text: widget.character.role);
      _health = TextEditingController(text: widget.character.health.toString());
      _level = TextEditingController(text: widget.character.level.toString());
    }

    Future<void> _save() async {
      final name = _name.text.trim();
      final role = _role.text.trim();
      final health = int.tryParse(_health.text) ?? 100;
      final level = int.tryParse(_level.text) ?? 1;
      final updated = GameCharacter(
        id: widget.character.id,
        name: name.isEmpty ? 'Unnamed' : name,
        role: role.isEmpty ? 'Unknown' : role,
        health: health,
        level: level,
      );
      if (widget.isNew) {
        await DbHelper.insert(updated);
      } else {
        await DbHelper.update(updated);
      }
      if (mounted) Navigator.of(context).pop();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isNew ? 'Add character' : 'Edit character'),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _save),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: _role, decoration: const InputDecoration(labelText: 'Role')),
              TextField(controller: _health, decoration: const InputDecoration(labelText: 'Health'), keyboardType: TextInputType.number),
              TextField(controller: _level, decoration: const InputDecoration(labelText: 'Level'), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      );
    }
  }

  // ---------- Storage / Files page (demonstrates directories, reading/writing, isolates) ----------
  class StoragePage extends StatefulWidget {
    const StoragePage({super.key});

    @override
    State<StoragePage> createState() => _StoragePageState();
  }

  class _StoragePageState extends State<StoragePage> {
    final List<String> _logs = [];
    final uuid = const Uuid();

    // --- Логирование ---
    void _log(String s) {
      setState(() => _logs.insert(0, '${DateTime.now().toIso8601String()}  ➜  $s'));
    }

    // --- Пример нескольких разных персонажей ---
    List<GameCharacter> _generateCharacters() => [
      GameCharacter(id: uuid.v4(), name: 'Knight', role: 'Tank', health: 120, level: 5),
      GameCharacter(id: uuid.v4(), name: 'Archer', role: 'DPS', health: 85, level: 3),
      GameCharacter(id: uuid.v4(), name: 'Mage', role: 'Support', health: 60, level: 4),
      GameCharacter(id: uuid.v4(), name: 'Rogue', role: 'Stealth', health: 90, level: 2),
      GameCharacter(id: uuid.v4(), name: 'Healer', role: 'Cleric', health: 70, level: 3),
    ];

    // --- Запись файлов в разные директории ---
    Future<void> _performAllWrites() async {
      final chars = _generateCharacters();

      final Map<String, Future<Directory?>> attempts = {
        'Temporary': getTemporaryDirectory().then((d) => d),
        'App Support': getApplicationSupportDirectory().then((d) => d),
        'App Documents': getApplicationDocumentsDirectory().then((d) => d),
        'App Cache': getApplicationCacheDirectory().then((d) => d),
      };

      if (Platform.isAndroid) {
        attempts['External Storage'] = getExternalStorageDirectory().catchError((e) => null);
        attempts['External Cache Dir'] = getExternalCacheDirectories()
            .catchError((e) => <Directory>[]).then((list) => (list != null && list.isNotEmpty) ? list.first : null);
        attempts['External Storage Dir'] = getExternalStorageDirectories()
            .then((dirs) => dirs != null && dirs.isNotEmpty ? dirs.first : null)
            .catchError((_) => null);
      } else if (Platform.isIOS) {
        attempts['App Library'] = getLibraryDirectory().then((d) => d);
      }

      try {
        attempts['Downloads'] = getDownloadsDirectory().catchError((e) => null);
      } catch (e) {
        _log(' getDownloadsDirectory not supported: ${e.toString()}');
      }

      final results = <String, Directory>{};
      for (final entry in attempts.entries) {
        try {
          final d = await entry.value;
          if (d != null) results[entry.key] = d;
          _log(' ${entry.key} → ${d?.path ?? 'null'}');
        } catch (e) {
          _log(' Error resolving ${entry.key}: $e');
        }
      }

      // Пишем по персонажу на каждую директорию
      final dirs = results.entries.toList();
      for (int i = 0; i < dirs.length; i++) {
        final dirName = dirs[i].key;
        final dir = dirs[i].value;
        final character = chars[i % chars.length];
        try {
          final res = await StorageService.writeToDirectory(dir, character);
          _log(' Saved ${character.name} (${character.role}) to [$dirName]');
        } catch (ex) {
          _log(' Failed to write in [$dirName]: ${ex.toString()}');
        }
      }
    }

    // --- Список файлов ---
    Future<void> _listFiles() async {
      final dirs = <String, Directory>{};
      try {
        dirs['Temporary'] = await getTemporaryDirectory();
        dirs['App Support'] = await getApplicationSupportDirectory();
        dirs['App Documents'] = await getApplicationDocumentsDirectory();
        dirs['App Cache'] = await getApplicationCacheDirectory();

        if (Platform.isAndroid) {
          final ext = await getExternalStorageDirectory();
          if (ext != null) dirs['External Storage'] = ext;

          // Добавляем специфичные для Android пути
          try {
            final externalDirs = await getExternalStorageDirectories();
            if (externalDirs != null && externalDirs.isNotEmpty) {
              dirs['External Storage Dirs'] = externalDirs.first;
            }
          } catch (e) {
            _log('External Storage Dirs not available: $e');
          }
        }
      } catch (e) {
        _log('Error getting directories: $e');
      }

      for (final e in dirs.entries) {
        _log('Files in ${e.key} (${e.value.path})');
        try {
          final files = await StorageService.listFilesInDir(e.value);
          final jsonFiles = files.whereType<File>().where((f) => f.path.endsWith('.json')).toList();

          if (jsonFiles.isEmpty) {
            _log('   — No JSON files found');
          } else {
            for (final f in jsonFiles) {
              try {
                final stat = await f.stat();
                final sizeKB = (stat.size / 1024).toStringAsFixed(1);
                final fileName = p.basename(f.path);
                _log('   $fileName ($sizeKB KB)');
              } catch (ex) {
                _log('   Error stating ${p.basename(f.path)}: $ex');
              }
            }
          }
        } catch (ex) {
          _log('   Error listing files: $ex');
        }
      }
    }

    // --- Чтение первого файла ---
    Future<void> _readSampleFile() async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final entries = await dir.list().toList();
        final jsonFiles = entries.whereType<File>().where((f) => f.path.endsWith('.json')).toList();
        if (jsonFiles.isEmpty) {
          _log(' No JSON files in App Documents');
          return;
        }
        final content = await StorageService.readFromPath(jsonFiles.first.path);
        final preview = content.length > 180 ? content.substring(0, 180) + '...' : content;
        _log(' Read from ${p.basename(jsonFiles.first.path)} → $preview');
      } catch (e) {
        _log(' Error reading: ${e.toString()}');
      }
    }

    // --- Очистка файлов ---
    Future<void> _clearAllFiles() async {
      final dirs = <Directory>[
        await getTemporaryDirectory(),
        await getApplicationSupportDirectory(),
        await getApplicationDocumentsDirectory(),
        await getApplicationCacheDirectory(),
      ];

      if (Platform.isAndroid) {
        try {
          final ext = await getExternalStorageDirectory();
          if (ext != null) dirs.add(ext);
        } catch (_) {}
      }

      int deleted = 0;
      for (final d in dirs) {
        final files = await StorageService.listFilesInDir(d);
        for (final f in files.whereType<File>()) {
          try {
            await f.delete();
            deleted++;
          } catch (_) {}
        }
      }
      _log('Cleared $deleted files from all known dirs');
    }

    // read all

    Future<void> _readAllFiles() async {
      final logs = <String>[];

      Future<void> tryRead(String name, Future<Directory?> getter) async {
        try {
          final dir = await getter;
          if (dir == null) {
            logs.add("$name → not available");
            return;
          }

          final files = await StorageService.listFilesInDir(dir);

          if (files.isEmpty) {
            logs.add("$name → no JSON files");
            return;
          }

          for (final file in files) {
            try {
              final content = await StorageService.readFromPath(file.path);
              final data = jsonDecode(content);
              final character = GameCharacter.fromJson(data);
              logs.add("$name → ${character.name} (Lv${character.level} ${character.role})");
            } catch (e) {
              logs.add("$name → Error reading ${p.basename(file.path)}: ${e.toString()}");
            }
          }
        } catch (e) {
          logs.add("$name → ${e.toString()}");
        }
      }

      // Читаем из всех директорий
      await tryRead("Temporary", getTemporaryDirectory());
      await tryRead("App Support", getApplicationSupportDirectory());
      await tryRead("App Documents", getApplicationDocumentsDirectory());
      await tryRead("App Cache", getApplicationCacheDirectory());

      if (Platform.isAndroid) {
        await tryRead("External Storage", getExternalStorageDirectory());
      }

      if (Platform.isIOS) {
        await tryRead("App Library", getLibraryDirectory());
      }

      setState(() {
        _logs.clear();
        _logs.addAll(logs);
      });
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Storage & Files')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  ElevatedButton(onPressed: _performAllWrites, child: const Text('Write to dirs')),
                  ElevatedButton(onPressed: _listFiles, child: const Text('List files')),
                  ElevatedButton(onPressed: _readSampleFile, child: const Text('Read file')),
                  ElevatedButton(onPressed: _readAllFiles, child: const Text('Read all files')),
                  ElevatedButton(onPressed: _clearAllFiles, child: const Text('Clear all')),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                  child: Text(
                    _logs[i],
                    style: TextStyle(
                      fontSize: 12,
                      color: _logs[i].contains('Error') ? Colors.red :
                      _logs[i].contains('➜') ? Colors.blue :
                      Colors.black,
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


  // ---------- End of file ----------
