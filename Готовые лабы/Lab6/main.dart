import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() => runApp(const GroceryApp()); // прикрепляет определенный виджет к экрану

class GroceryApp extends StatefulWidget { // виджет с состояниями которое может меняться
  const GroceryApp({super.key});

  @override
  State<GroceryApp> createState() => _GroceryAppState(); // обьект состояния который управляет изменяемыми данными
  // _GroceryAppState - приватный класс который хранит состояние
}

class _GroceryAppState extends State<GroceryApp> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) { // главный метод Flutter, который создаёт интерфейс виджета.
    // Он вызывается каждый раз, когда Flutter должен перерисовать экран (setState)
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: { // стэк роутов для управления навигацией  между экранов
        "/":(context) => HomeScreen(),
        "/details":(context){
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProductDetailsScreen(
            name: args["name"],
            weight: args["weight"],
            price: args["price"],
            image: args["image"],
          );
        }
        },
    );
  }
}

/// --------------------
/// Главная страница
/// --------------------
class HomeScreen extends StatefulWidget{
  @override
  State<HomeScreen> createState()  => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  // контроллер PageView
  final PageController _pageController = PageController(); // для управления текущей страницей
  //текущая страница
  int _selectedIndex = 0;
  // переключение вкладок
  void _onItemTapped(int index){
    setState(() {
      _selectedIndex=index;
      _pageController.jumpToPage(index); // мгновенно переходит на другую страницу
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold( // класс Flutter , предоставляющий множество виджетов, или ,
      // можно сказать, API .
      // Scaffold разворачивается или занимает
      // всё доступное пространство на экране устройства.
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() { // колбэк при смене страницы
              _selectedIndex=index;
            }),
            children: [ // статический список страниц
              HomePage(),
              FavoritesPage(),
              CartPage(),
              ProfilePage(),
              SystemPage()
            ],
          ),
      Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            width: 240,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(Icons.home, 0),
                _buildNavIcon(Icons.favorite_border, 1),
                _buildNavIcon(Icons.shopping_cart_outlined, 2),
                _buildNavIcon(Icons.person_outline, 3),
                _buildNavIcon(Icons.smartphone, 4),
              ],
            ),
          ),
        ),
      ),
        ],
      )
    );
  }
  Widget _buildNavIcon(IconData icon, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Icon(
        icon,
        color: isActive ? Colors.green : Colors.grey,
        size: isActive ? 28 : 24,
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // добавляем Scaffold
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: const [
                _Header(),
                SizedBox(height: 12),
                _CategoryRow(),
                _SectionTitle(),
                _ProductList(),
                SizedBox(height: 16),
                _CategoryCardRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// --------------------
/// Хэдер
/// --------------------
class _Header extends StatelessWidget { // Виджет, не требующий изменяемого состояния
  const _Header();

  @override
  Widget build(BuildContext context) { // Описывает часть пользовательского интерфейса, представленную этим виджетом.
    return Container( // Создает виджет, объединяющий общие виджеты рисования, позиционирования и изменения размера.
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0A5C45),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column( // vert arr
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search for "Grocery"',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar( // circle of a user or button
                backgroundColor: Colors.white,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart, color: Color(0xFF0A5C45)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: const [
              Text("Current Location", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Row( // horiz arr
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("California, USA", style: TextStyle(color: Colors.white)),
                  SizedBox(width: 4),
                  Icon(Icons.location_on, color: Colors.white, size: 18),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// --------------------
/// Категории
/// --------------------
class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Meats', 'icon': Icons.set_meal},
      {'title': 'Vege', 'icon': Icons.eco},
      {'title': 'Fruits', 'icon': Icons.apple},
      {'title': 'Breads', 'icon': Icons.bakery_dining},
    ];

    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories
            .map((c) => CategoryIcon(title: c['title'] as String, icon: c['icon'] as IconData))
            .toList(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("You might need",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text("See more", style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
}

/// --------------------
/// Список продуктов
/// --------------------
class _ProductList extends StatelessWidget {
  const _ProductList();
  @override
  Widget build(BuildContext context) {
    final products = [
      {'name': 'Beetroot', 'weight': '500 gm', 'price': 17.29,'image':"images/beatroot.png"},
      {'name': 'Italian Avocado', 'weight': '450 gm', 'price': 14.29,'image':'images/avocado.png'},
      {'name': 'Carrot', 'weight': '1000 gm', 'price': 27.29,'image':"images/carrot.png"},
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder( // Создает прокручиваемый линейный массив виджетов, создаваемых по требованию.
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16,top: 10,bottom: 10),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return ProductCard(
            index: i,
            name: p['name'] as String,
            weight: p['weight'] as String,
            price: p['price'] as double,
            image: p['image'] as String,
          );
        },
      ),
    );
  }
}

/// --------------------
/// Карточки
/// --------------------
class _CategoryCardRow extends StatelessWidget {
  const _CategoryCardRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Grocery',
        'time': 'By 12:15pm',
        'bgColor': const Color(0xFFFFF4D6),
        'image': 'images/tomato.png'
      },
      {
        'title': 'Wholesale',
        'time': 'By 1:30pm',
        'bgColor': const Color(0xFFFFD6D6),
        'image': 'images/banana.png'
      }
    ];

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return CategoryCard(
            title: item['title'] as String,
            time: item['time'] as String,
            bgColor: item['bgColor'] as Color,
            image: item['image'] as String,
          );
        },
      ),
    );
  }
}
/// --------------------
/// навигация
/// --------------------
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.home, color: Colors.green),
              Icon(Icons.favorite_border, color: Colors.grey),
              Icon(Icons.shopping_cart_outlined, color: Colors.grey),
              Icon(Icons.person_outline, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// --------------------
/// Детали продукта
/// --------------------
class ProductDetailsScreen extends StatelessWidget {
  // Принимаем данные через конструктор
  final String name;
  final String weight;
  final double price;
  final String image;

  const ProductDetailsScreen({
    super.key,
    required this.name,
    required this.weight,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold( // добавляем Scaffold, чтобы экран выглядел нормально
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Верхняя панель
            Container(
              color: const Color(0xFF0A5C45),
              padding: const EdgeInsets.only(top: 40, left: 8, right: 8, bottom: 7),
              child: Row(
                children: [
                  IconButton(
                    // Возврат на предыдущий экран
                    onPressed: () => Navigator.pop(context), // извлекает из навигатора самый верхний маршрут закрывает текущий экран и возвращается на предыдущий.
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  const Text(
                    "Product Details",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_cart, color: Color(0xFF0A5C45)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Используем переданные данные:
            // Изображение продукта
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(image, height: 200, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            // Название, вес, цена, рейтинг, доставка
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название, вес и избранное
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weight,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Icon(Icons.favorite_border, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Цена и доставка
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${price.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.delivery_dining, color: Colors.green),
                          SizedBox(width: 6),
                          Text("Available on fast delivery"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Иконки и рейтинг
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset("images/meatIcon.png", width: 25, height: 25),
                          const SizedBox(width: 3),
                          Image.asset("images/belok.png", width: 25, height: 25),
                          const SizedBox(width: 3),
                          Image.asset("images/wheat.png", width: 25, height: 25),
                        ],
                      ),
                      Row(
                        children: const [
                          Icon(Icons.star_half, color: Colors.amber),
                          SizedBox(width: 4),
                          Text("4.5 Rating"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _AddToCartSection(),
            const SizedBox(height: 20),
            // Гарантия удовлетворения
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.verified, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "100% satisfaction guarantee. If you experience any of the following issues — missing items, poor quality, late arrival, or unprofessional service — we’ll make it right.",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}


class _AddToCartSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
                const Text("1", style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              label: const Text("Add to cart", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

/// --------------------
/// Вспомогательные виджеты
/// --------------------
class CategoryIcon extends StatelessWidget {
  final String title;
  final IconData icon;
  const CategoryIcon({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 28, backgroundColor: Colors.green[100], child: Icon(icon, color: Colors.green)),
        const SizedBox(height: 4),
        Text(title),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String weight;
  final double price;
  final String image;
  final int index;
  const



  ProductCard({super.key, required this.name, required this.weight, required this.price, required this.image,required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Создает виджет, распознающий жесты.
      onTap: (){
        if(index ==0){
          Navigator.push( // открывает новый экран
              context,
              MaterialPageRoute(builder: //  это класс в Flutter, который управляет переходом между страницами (routes)
                  (context) => ProductDetailsScreen(name: name, weight: weight, price: price, image: image)
              )
          );
        }
        else{
          Navigator.pushNamed(context, "/details",arguments: {
            "name":name,
            "weight":weight,
            "price":price,
            "image":image
          },);
        }
      }
      ,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(image,height: 65,fit: BoxFit.contain),
            Column(
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(weight, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Column(
              children: [
                Text("\$${price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                if(index == 1)
                  Container(
                    width: 110,
                    height: 27,
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const Text("1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 95,
                    height: 27,
                    decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String time;
  final Color bgColor;
  final String image;

  const CategoryCard({super.key, required this.title, required this.time, required this.bgColor, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )),
          Image.asset(image,width: 40,height: 40,fit: BoxFit.contain,)
        ],
      ),
    );
  }
}


///
///
/// Страницы
///
///

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Favorites Page", style: TextStyle(fontSize: 22)));
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Cart Page", style: TextStyle(fontSize: 22)));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Profile Page", style: TextStyle(fontSize: 22)));
  }
}


/// производитель

class SystemPage extends StatefulWidget {
  const SystemPage({super.key});



  @override
  State<SystemPage> createState() => _SystemPageState();
}

class _SystemPageState extends State<SystemPage> {
  static const platform = MethodChannel("com.example.system/info");
  String _manufacturer = "Нажми кнопку";
  String _batteryLevel = "Неизвестно";
  double? _cpuUsage;
  String _cpuInfo = '';
  final TextEditingController _subjectController = TextEditingController(text: "Тестовая тема письма");

  Future<void> _getCpuUsage() async {
    try {
      final dynamic result = await platform.invokeMethod("getCpuUsage");
      if (result == null) {
        setState(() {
          _cpuUsage = null;
        });
        return;
      }
      if (result is double) {
        setState(() {
          _cpuUsage = result;
        });
      } else if (result is int) {
        setState(() {
          _cpuUsage = result.toDouble();
        });
      } else if (result is String) {
        setState(() {
          _cpuUsage = double.tryParse(result);
        });
      } else {
        setState(() {
          _cpuUsage = null;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _cpuUsage = null;
      });
      print("Ошибка: ${e.message}");
    }
  }

  Future<void>  _getDeviceManufacturer() async{
      try{
        final manufacturer = await platform.invokeMethod("getDeviceManufacturer");
        setState(() {
          _manufacturer = manufacturer ?? "Unknown";
        });
      }
      on PlatformException catch (e) {
        setState(() {
          _manufacturer = "Ошибка: ${e.message}";
        });
      }
  }

  Future<void> _openEmailApp() async {
    try {
      final subject = _subjectController.text;
      await platform.invokeMethod("openEmailApp", {"subject": subject});
    } on PlatformException catch (e) {
      print("Ошибка при открытии почты: ${e.message}");
    }
  }

  Future<void> _getBatteryLevel() async {
    try {
      final int level = await platform.invokeMethod('getBatteryLevel');
      setState(() {
        _batteryLevel = '$level%';
      });
    } on PlatformException catch (e) {
      setState(() {
        _batteryLevel = "Ошибка: ${e.message}";
      });
    }
  }

  File? _image; // для хранения выбранного фото
  final ImagePicker _picker = ImagePicker();

// метод для съемки фото с камеры
  Future<void> _getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("System Page"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Производитель:${_manufacturer}", style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getDeviceManufacturer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              child: const Text("Refresh"),
            ),
            const SizedBox(height: 40),
            Text("CPU: ${_cpuUsage?.toStringAsFixed(2) ?? 'Неизвестно'}%",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCpuUsage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              child: const Text("Получить CPU"),
            ),
            const SizedBox(height: 40),
            const SizedBox(height: 40),
            Text("Батарея:${_batteryLevel}", style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getBatteryLevel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              child: const Text("Получить заряд"),
            ),
            const SizedBox(height: 40),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.file(_image!, height: 200),
              ),
            ElevatedButton(
              onPressed: _getImageFromCamera,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Сделать фото"),
            ),
            const SizedBox(height: 40),
        TextField(
          controller: _subjectController,
          decoration: const InputDecoration(
            labelText: "Тема письма",
            border: OutlineInputBorder(),
          ),
        ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openEmailApp,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Открыть почту"),
            ),
          ],
        ),
      ),
    );
  }
}
