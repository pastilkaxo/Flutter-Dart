import 'package:flutter/material.dart';


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
      home: Scaffold( //  предоставляет структуру "каркаса" для страницы приложения и автоматически управляет многими элементами интерфейса
        backgroundColor: Colors.white,
        body: SafeArea( // защищает содержимое от системных перекрытий
          child: showDetails
              ? ProductDetailsScreen(onBack: () => setState(() => showDetails = false))
              : HomeScreen(onOpenDetails: () => setState(() => showDetails = true)),
        ),
      ),
    );
  }
}

/// --------------------
/// Главная страница
/// --------------------
class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenDetails;
  const HomeScreen({super.key, required this.onOpenDetails});

  @override
  Widget build(BuildContext context) {
    return Stack( // виджет который накладывает детей друг на друга
      children: [
        SingleChildScrollView( // создает box в котором каждый виджет может быть проскроллен
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              const _Header(),
              const SizedBox(height: 12),
              const _CategoryRow(),
              const _SectionTitle(),
              _ProductList(onOpenDetails: onOpenDetails),
              const SizedBox(height: 16),
              const _CategoryCardRow(),
            ],
          ),
        ),
        const _BottomNav(),
      ],
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
  final VoidCallback onOpenDetails;
  const _ProductList({required this.onOpenDetails});

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
            onTap: onOpenDetails,
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
  final VoidCallback onBack;
  const ProductDetailsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(  // header
            color: const Color(0xFF0A5C45),
            padding: const EdgeInsets.only(top: 12, left: 8, right: 8,bottom: 7),
            child: Row(
              children: [
                IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back, color: Colors.white)),
                const Spacer(),
                const Text("Product Details",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
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
          Image.asset("images/beaf.png", height: 200),
          const SizedBox(height: 12),
          Row(   // product info
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      "Beef Mixed Cut Bone",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child:
                    Text("1000 gm", style: TextStyle(color: Colors.grey)),
                  ),
              ],)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Container(
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
              )

            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text("\$23.46", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),),
              SizedBox(width: 10),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child:
              Row(children: [
                Icon(Icons.delivery_dining, color: Colors.green),
                SizedBox(width: 6),
                Text("Available on fast delivery"),
              ],)
                ,)
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child:
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset("images/meatIcon.png",width: 25,height: 25,),
                  SizedBox(width: 3,),
                  Image.asset("images/belok.png",width: 25,height: 25,),
                  SizedBox(width: 3,),
                  Image.asset("images/wheat.png",width: 25,height: 25,)
                ],),)
              ,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child:
                Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 4),
                  Text("4.5 Rating"),
                ],),)
            ],
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: RichText( // выводить текст с разным стилевым оформлением
              textAlign: TextAlign.justify,
              text: TextSpan(
              children: [
                TextSpan( text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras lacinia sed lectus nec blandit...",
                  style: const TextStyle(fontSize: 14,color: Colors.grey),
                ),
                TextSpan( text: "Read more",
                  style: const TextStyle(fontSize: 14,color: Colors.green, fontWeight:FontWeight.bold ),
                ),
              ],
            ),
            )
          ),
          const SizedBox(height: 5),
          _AddToCartSection(),
        ],
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
  final VoidCallback onTap;
  final String image;
  final int index;
  const ProductCard({super.key, required this.name, required this.weight, required this.price, required this.onTap, required this.image,required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Создает виджет, распознающий жесты.
      onTap: onTap,
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
