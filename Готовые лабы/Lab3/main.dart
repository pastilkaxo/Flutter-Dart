import "dart:async";
import "dart:convert";
import "dart:io";

abstract interface class IComputerGame {
  void startGame();
  void saveGame();
  void quitGame();
}

// ================= Mixin =================

mixin Moveable on GameEntity {
  void move(bool isSuccess, [String direction = "вперёд"]) =>
      print("$name движется $direction. $isSuccess");
}

mixin class PlayerCounter {
  static int playerCount = 0;
  String playerName = "Игрок";
  int playerHealth = 100;
  int playerDamage = 10;
  void increment() => playerCount++;
  void showCount() => print("Всего игроков: $playerCount");
  void display() {
    print("Игрок: $playerName | HP: $playerHealth | Урон: $playerDamage");
  }
}

// ============ Iterable & Iterator ==============
class PlayerIterator implements Iterator<Player> {
  final List<Player> _players;
  int _index = -1;

  PlayerIterator(this._players);

  @override
  Player get current => _players[_index];

  @override
  bool moveNext() {
    if (_index + 1 < _players.length) {
      _index++;
      return true;
    }
    return false;
  }
}

class PlayerCollection extends Iterable<Player> {
  @override
  Iterator<Player> get iterator => PlayerIterator(Player._allPlayers);
}

// ================= GameEntity =================

abstract class GameEntity with PlayerCounter {
  int health;
  String name;
  int damage = 10;

  GameEntity(this.health, this.name, this.damage) {
    playerHealth = health;
    playerName = name;
    playerDamage = damage;
  }
  GameEntity.withoutHealth(this.name, this.damage) : health = 100 {
    playerHealth = health;
    playerName = name;
    playerDamage = damage;
  }
  void attack(Player p, int damage);
  void restoreHealth(int totalDamage);
}

// ================= Enemy =================

abstract class Enemy extends GameEntity {
  Enemy(int health, String name, int damage) : super(health, name, damage);

  void makeMove(Player player);
}

class Boss extends Enemy with PlayerCounter {
  static final List<Boss> _allBosses = [];

  Boss(String name, int health, int damage) : super(health, name, damage) {
    playerName = name;
    playerHealth = health;
    playerDamage = damage;
    _allBosses.add(this);
  }

  @override
  void attack(Player p, int damage) {
    print("Босс $name бьет игрока ${p.name} на $damage урона");
    p.restoreHealth(damage);
  }

  @override
  void restoreHealth(int totalDamage) {
    health -= totalDamage ~/ 2;
    print("$name потерял $totalDamage HP. Осталось: $health HP");
  }

  @override
  void makeMove(Player player) {
    print("Босс $name поймал ${player.name}");
    attack(player, damage);
  }

  @override
  void display() {
    print("Босс: $name | HP: $health | Урон: $damage");
  }

  static void displayAll() {
    print("=== Все боссы ===");
    for (var boss in _allBosses) {
      boss.display();
    }
    print("==================");
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'health': health,
    'damage': damage,
  };
}

// ================= Player =================

class Player extends GameEntity
    with Moveable, PlayerCounter
    implements IComputerGame, Comparable<Player> {
  static final List<Player> _allPlayers = [];
  List<String> weapons = [];
  Map<dynamic, dynamic> banList = {};
  Set<String> skills = {};

  int _level;

  Player(super.health, super.name, this._level, super.damage) {
    increment();
    _allPlayers.add(this);
  }

  Player.beginner(String name) : _level = 1, super.withoutHealth(name, 10) {
    increment();
    _allPlayers.add(this);
    weapons.add("Палка");
    skills.add("Удар палкой");
  }

  Player.master(String name, int level)
    : _level = level,
      super.withoutHealth(name, 30) {
    increment();

    _allPlayers.add(this);
    weapons.add("Меч");
    skills.add("Удар мечом");
  }

  Player.fromJson(Map<String, dynamic> jsonMap)
    : _level = jsonMap['level'] as int,
      super(
        jsonMap['health'] as int,
        jsonMap['name'] as String,
        jsonMap['damage'] != null ? jsonMap['damage'] as int : 10,
      ) {
    weapons = (jsonMap['weapons'] as List<dynamic>?)?.cast<String>() ?? [];
    skills =
        (jsonMap['skills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toSet() ??
        {};
    banList =
        (jsonMap['banList'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v),
        ) ??
        {};
    increment();
    _allPlayers.add(this);
  }

  int get level => _level;
  set level(int value) => _level = value > 0
      ? value
      : throw Exception("Level должен быть больше нуля.");

  // @override
  // void display() {
  //   print(
  //     "Игрок: $name | Уровень: $_level | HP: $health | Оружие: $weapons | Список заблокированных: $banList | Способности: $skills",
  //   );
  // }

  @override
  void restoreHealth(int totalDamage) {
    health -= totalDamage;
    print("$name получил $totalDamage урона. Осталось $health HP");
  }

  static void displayAll() {
    print("=== Все игроки ===");
    for (var player in _allPlayers) {
      player.display();
    }
    print("==================");
  }

  @override
  void startGame() => print("Игрок $name начинает игру");

  @override
  void saveGame() => print("Игра сохранена для $name");

  @override
  void quitGame() => print("$name вышел из игры");

  @override
  void attack(Player player, int damage) {
    print("$name атакует ${player.name}");
    player.restoreHealth(damage);
  }

  void heal({int points = 10}) {
    health += points;
    print("$name восстановил $points HP. Теперь $health HP");
  }

  void doAction(Function(String) action) => action(name);

  void upgrade([int increase = 1]) {
    _level += increase;
    print("$name повысил уровень до $_level");
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'health': health,
    'level': _level,
    'weapons': weapons,
    'skills': skills.toList(),
    'banList': banList.map((k, v) => MapEntry(k.toString(), v.toString())),
  };

  @override
  int compareTo(Player other) {
    if (level > other.level) {
      return 1;
    } else if (level < other.level) {
      return -1;
    } else
      return 0;
  }
}

// Stream
void FileWriter(Player player) async {
  final File file = File("./test.txt");
  var sink = file.openWrite();
  sink.write(player.name);
  await sink.close();
  print("File has been written");
}

// SSS BSS
Future<void> SingleSubstrictionStream() async {
  print("------ Простой Stream ------");

  Stream<int> numberStream = Stream.fromIterable(
    PlayerCollection().map((p) => p.level),
  );
  // await numberStream.listen(
  //   (data) {
  //     print("Получено значение из Stream: $data");
  //   },
  //   onDone: () {
  //     print("Stream завершён");
  //   },
  // );

  await for (var value in numberStream) {
    print("Получено значение из Stream: $value");
  }

  print("Stream завершён");
}

Future<void> BroadcastStream() async {
  print("------ Broadcast StreamController ------");

  final controller = StreamController<String>.broadcast(
    onListen: () => print("Broadcast: появился слушатель"),
    onCancel: () => print("Broadcast: слушатель ушёл"),
  );

  controller.stream.listen((event) {
    print("Listener 1 получил: $event");
  }, onDone: () => print("Listener1 done"));

  controller.stream.listen((event) {
    print("Listener 2 получил: $event");
  }, onDone: () => print("Listener2 done"));

  controller.add("Событие 1");
  controller.add("Событие 2");

  controller.addError("Это пример ошибки");

  controller.add("Событие 3");

  controller.close();
}

// async

Future<String> getData(File file) {
  return Future.delayed(Duration(seconds: 10), () => file.readAsString());
}

dynamic deserializePlayer(String fileName) async {
  try {
    var file = File(fileName);
    var content = await getData(file);
    var decoded = jsonDecode(content) as Map<String, dynamic>;
    return Player.fromJson(decoded);
  } catch (e) {
    throw Exception("Ошибка при десериализации файла $fileName: $e");
  }
}

Future<void> demoFutureConstructors() async {
  var f1 = Future<int>(() {
    print("Вычисляем в Future(...)");
    return 52;
  });
  f1.then((value) => print("Future(...) результат: $value"));

  var f2 = Future.delayed(Duration(seconds: 1), () {
    print("Сработал Future.delayed через 1 секунду");
    PlayerCollection()
        .where((p) => p.name == "p2")
        .forEach((p) => p.restoreHealth(50));
    return "Player 2 died";
  });
  f2.then((value) => print("Future.delayed результат: $value"));

  var f3 = Future.error("Ошибка в Future.error");
  f3.catchError((err) => print("Future.error ошибка: $err"));

  var f4 = Future.microtask(() {
    print("Future.microtask выполнен");
    return "microtask result";
  });
  f4.then((value) => print("Future.microtask результат: $value"));

  var f5 = Future.sync(() {
    print("Future.sync выполнен сразу");
    return 100;
  });
  f5.then((value) => print("Future.sync результат: $value"));

  var f6 = Future.value("Заранее известное значение");
  f6.then((value) => print("Future.value результат: $value"));
}

void main() async {
  Player p1 = Player(120, "p1", 5, 15);
  Player p2 = Player.beginner("p2");
  Player p3 = Player.master("p3", 10);
  Player.displayAll();
  print("----------------------\n");
  Boss boss = Boss("Дракон", 500, 50);
  boss.makeMove(p1);
  boss.attack(p3, 70);
  Boss.displayAll();
  print("----------------------\n");
  p1.startGame();
  p2.startGame();
  p3.startGame();
  print("----------------------\n");

  p1.attack(p2, 10);
  p2.display();
  print("----------- Mixin Moveable -----------\n");

  p2.move(true);
  p3.move(false, "назад");
  print("----------------------\n");

  p1.heal(points: 20);
  p1.display();
  print("----------------------\n");
  p2.upgrade();
  p2.display();
  p3.upgrade(3);
  p3.display;

  print("----------- Exception -----------\n");
  try {
    p1.level = -2;
    print("p1 level:${p1.level}");
    // } on Exception {
    //   print("Exception");
    //
  } catch (e) {
    print("Ошибка: $e");
  } finally {
    print("Исключение обработано");
  }

  print("----------- Func param -----------\n");

  void ult(name) => print("Игрок $name ультанул");

  p3.doAction(ult);

  print("----------------------\n");
  PlayerCounter counter = PlayerCounter();
  counter.showCount();
  print("------------ JSON serialize----------\n");
  for (var player in Player._allPlayers) {
    var jsonPlayer = json.encode(player.toJson());
    File file = File("${player.name}_player.json");
    file.writeAsString(jsonPlayer);
    print("Игрок ${player.name} сохранён в файл ${file.path}");
  }
  print("------------ JSON deserialize----------\n");
  try {
    var restoredPlayer = await deserializePlayer("p1_player.json");
    print(
      "Игрок восстановлен: ${restoredPlayer.name}, уровень: ${restoredPlayer.level}, HP: ${restoredPlayer.health} \n",
    );
  } catch (e) {
    print("Ошибка: $e");
  }

  print("----------------------\n");
  FileWriter(p1);
  await SingleSubstrictionStream();
  await BroadcastStream();
  print("------------ Future constructors----------\n");
  await demoFutureConstructors();
  print("----------------------\n");

  print("------ Итерация игроков (Iterable/Iterator) ------");
  PlayerIterator iterator = PlayerIterator(Player._allPlayers);
  print("=== Все игроки (через Iterator) ===");
  while (iterator.moveNext()) {
    var player = iterator.current;
    player.display();
  }
  print("=== Все игроки (через Iterable) ===");
  for (var player in PlayerCollection()) {
    player.display();
  }
  print(
    ".where() + .map(): Игроки с уровнем > 3: ${PlayerCollection().where((p) => p.level > 3).map((p) => p.name).toList()}",
  );
  print(
    ".reduce(): Суммарный уровень всех игроков: ${PlayerCollection().map((p) => p.level).reduce((total, element) => total + element)}",
  );
  print(
    ".fold(): Максимальный уровень игрока: ${PlayerCollection().map((p) => p.level).fold(0, (max, element) => element > max ? element : max)}",
  );
  print(
    ".any() & .every(): Все игроки с уровнем > 0: ${PlayerCollection().every((p) => p.level > 0)}",
  );
  print(
    ".any(): Есть ли игрок с уровнем > 5: ${PlayerCollection().any((p) => p.level > 5)}",
  );
  print("------ Comparable ------");
  int i = p1.compareTo(p2);
  if (i == 1)
    print("p1 level:${p1.level} > p2 level ${p2.level}");
  else
    print("p1 level:${p1.level} < p2 level ${p2.level}");
  print("----------- Quit -----------\n");

  p1.quitGame();
  p2.quitGame();
  p3.quitGame();
}





/*Future.sync(() { print("Future.sync выполнен сразу"); return 100; })

Функция вызывается немедленно, поэтому "Future.sync выполнен сразу" выводится первым.

Но .then((value) => ...) ставится в микрозадачу, поэтому результат 100 появится позже.

Future.error("Ошибка в Future.error")

Асинхронно ставится в обычную очередь Future (или микрозадачу? у Future.error немного особый механизм).

Поэтому "Future.error поймана ошибка: ..." выводится после sync function.

Future.microtask(() { print("Future.microtask выполнен"); return ... })

Сразу ставится в очередь микрозадач, поэтому выполняется до .then() от sync и value.

"Future.microtask выполнен" выводится перед результатом sync.

Future.sync.result (.then)

Выполняется как микрозадача после всех предыдущих microtasks, поэтому "Future.sync результат: 100".

Future.value("...")

Планируется как микрозадача, выполняется в конце. */

