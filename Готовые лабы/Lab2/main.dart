abstract interface class IComputerGame {
  void startGame();
  void saveGame();
  void quitGame();
}

abstract class GameEntity {
  int health;
  String name;

  GameEntity(this.health, this.name);
  GameEntity.withoutHealth(this.name) : health = 100;
  void display();
  void attack(Player p, int damage);
  void restoreHealth(int totalDamage);
}

abstract class Enemy extends GameEntity {
  int damage;

  Enemy(int health, String name, this.damage) : super(health, name);

  void makeMove(Player player);
}

class Boss extends Enemy {
  static final List<Boss> _allBosses = [];

  Boss(String name, int health, int damage) : super(health, name, damage) {
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
}

class Player extends GameEntity implements IComputerGame {
  static final List<Player> _allPlayers = [];
  List<String> weapons = [];
  Map<dynamic, dynamic> banList = {};
  Set<String> skills = {};

  static int playerCount = 0;
  int _level;

  Player(super.health, super.name, this._level) {
    playerCount++;
    _allPlayers.add(this);
  }

  Player.beginner(String name) : _level = 1, super.withoutHealth(name) {
    playerCount++;
    _allPlayers.add(this);
    weapons.add("Палка");
    skills.add("Удар палкой");
  }

  Player.master(String name, int level)
    : _level = level,
      super.withoutHealth(name) {
    playerCount++;
    _allPlayers.add(this);
    weapons.add("Меч");
    skills.add("Удар мечом");
  }

  int get level => _level;
  set level(int value) => _level = value > 0
      ? value
      : throw Exception("Level должен быть больше нуля.");

  @override
  void display() {
    print(
      "Игрок: $name | Уровень: $_level | HP: $health | Оружие: $weapons | Список заблокированных: $banList | Способности: $skills",
    );
  }

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

  void move(bool isSuccces, [String direction = "вперёд"]) =>
      print("$name движется $direction. $isSuccces");

  void heal({int points = 10}) {
    health += points;
    print("$name восстановил $points HP. Теперь $health HP");
  }

  void doAction(Function(String) action) => action(name);

  void upgrade([int increase = 1]) {
    _level += increase;
    print("$name повысил уровень до $_level");
  }

  static void showPlayerCount() => print("Всего игроков: $playerCount");
}

void main() {
  Player p1 = Player(120, "p1", 5);
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
  print("----------------------\n");

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

  print("----------- List -----------\n");

  List<Player> players = [p1, p2, p3];
  players.forEach((player) => player.weapons.add("Дубинка"));
  players.forEach(
    (player) => player.weapons.addAll(["Зелье HP", "Зелье маны"]),
  );
  p1.display();
  p1.attack(p3, 100);
  if (p3.weapons.contains("Зелье HP")) {
    p3.heal(points: 30);
    p3.weapons.remove("Зелье HP");
    p3.display();
  }
  p2.weapons.insert(2, 'Арбуз');
  p2.weapons.sort();
  print(players.where((p) => p.weapons.contains("Арбуз")));
  Player p4 = Player.master("p4", 100);
  var playerList = [p4, ...players];
  for (var player in playerList) {
    print("${player.name} - ${player.weapons}");
  }

  print("----------- Map -----------\n");
  p1.banList.addAll({1: p4, "second key": p3});
  p1.display();
  print(
    "Values:${p1.banList.values}\nKeys:${p1.banList.keys}\nLen:${p1.banList.length}\nP2 ban list:${p2.banList.isEmpty}",
  );
  p2.banList.putIfAbsent(1, () => p2.name);
  p2.display();
  for (var player in p1.banList.entries) {
    if (player.key == 1) {
      p3.banList.addAll({player.key: player.value});
      p3.display();
    }
  }
  if (p1.banList.containsKey("second key")) p1.banList.remove("second key");
  p1.display();

  print("----------- Set -----------\n");

  p2.skills.addAll({"Удар палкой", "Пинок", "Hook"});
  p2.display();

  var superSkills = {"Black Hole", "Hook"};

  p3.skills.addAll(p3.skills.union(superSkills));
  p3.display();

  print("Разница master&beginner: ${p2.skills.difference(p3.skills)}");
  print("Схожесть master&beginner: ${p2.skills.intersection(p3.skills)}");
  print("Take(2):${p3.skills.take(2)}");
  print("Skip(2):${p3.skills.skip(2)}");
  p3.skills.remove("Black Hole");
  p3.display();

  print("----------- Continue/break -----------\n");

  for (int i = 1; i <= 5; i++) {
    if (i == 2) continue;
    if (i == 4) break;
    print("Итерация $i");
  }

  print("----------------------\n");
  Player.showPlayerCount();
  print("----------- Quit -----------\n");

  p1.quitGame();
  p2.quitGame();
  p3.quitGame();
}
