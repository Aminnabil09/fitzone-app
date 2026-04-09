import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String description;
  final List<String> colors;
  final List<String> sizes;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.colors,
    required this.sizes,
    required this.stock,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('missing data for product ${doc.id}');
    }

    return Product(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown Product',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] as String? ?? '',
      category: data['category'] as String? ?? 'Miscellaneous',
      description: data['description'] as String? ?? 'No description available.',
      colors: (data['colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sizes: (data['sizes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      stock: (data['stock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'colors': colors,
      'sizes': sizes,
      'stock': stock,
    };
  }

  static List<Product> getSampleProducts() {
    return [
      // Football Products
      Product(
        id: '1',
        name: 'Liverpool Kit 25/26',
        price: 15.00,
        imageUrl:
            'https://images.unsplash.com/photo-1543326132-ec2da8929e71?w=800&q=80',
        category: 'Football',
        description: 'Official Liverpool FC home kit for 2025/26 season',
        colors: ['Red', 'Teal', 'Cream'],
        sizes: ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'],
        stock: 50,
      ),
      Product(
        id: '2',
        name: 'Man City Kit 25/26',
        price: 15.00,
        imageUrl:
            'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800&q=80',
        category: 'Football',
        description: 'Official Manchester City FC kit for 2025/26 season',
        colors: ['Blue', 'White'],
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        stock: 30,
      ),
      Product(
        id: '3',
        name: 'Real Madrid Kit 25/26',
        price: 18.00,
        imageUrl:
            'https://images.unsplash.com/photo-1517927033932-b3d18e61fb3a?w=800&q=80',
        category: 'Football',
        description: 'Official Real Madrid CF home kit for 2025/26 season',
        colors: ['White', 'Gold'],
        sizes: ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'],
        stock: 45,
      ),
      Product(
        id: '4',
        name: 'Barcelona Kit 25/26',
        price: 18.00,
        imageUrl:
            'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjN6Ih1zyKLjKUTFCE96ggyx1UbE8FgYMtHCoHVHFcDI49nP2h7sXyOTevNlpD0fskoPRJvQs9IEy_XLSJqtA-mA_kxPXtIwQ5YS4-YBr5ZmAjPD8Pj9WFeTSI_vfhyphenhyphenvS1ZMkEgWSYGOUE7RecnUuqPG5IjND29L25CoeaJD4m2KZrGV9eJ-eENgw23lTel/s1600/barca-25-26-home-kit%20%2813%29.jpg',
        category: 'Football',
        description: 'Official FC Barcelona home kit for 2025/26 season',
        colors: ['Blue', 'Red'],
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        stock: 40,
      ),
      Product(
        id: '5',
        name: 'Chelsea Kit 25/26',
        price: 16.00,
        imageUrl:
            'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj0vC8_aWr9aYFolzxfHZqAPOnuvkuK9OPZKJJPHv_qxRRhRWsvPMqLORAzfuPn2ZPlCnbMdP2FnBUUNzty6MnPwx1eYs5SyKfHQ8eV84ww0-SJ6rluAy7gIK9V_B-6CyCl0TlIX8rz5BnOXfZsKxZ5wayyCZWzTV76nvRe5TMLy05RfEfTlgYwz2MY8IsQ/s1600/cfc-25-26-home-kit%20%2817%29.jpg',
        category: 'Football',
        description: 'Official Chelsea FC home kit for 2025/26 season',
        colors: ['Blue', 'White'],
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        stock: 35,
      ),
      Product(
        id: '6',
        name: 'Arsenal Kit 25/26',
        price: 16.00,
        imageUrl:
            'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgz4XfJzz8wU2LcgUFAcbq99ofRqK6-fKkNs8_vFew3ixR8wo2bF_lU8BACdK55TNVJEf7rP2dYL_C7dNEP3gplz8twWz34pX9XoN0zJkwOnZIr6wfbw79DY8U-0ZpJqwDuDWM2z8UluDBVSBhDhsR0357-b9XnNOWVTNKmmBKCLrvnIrU4YaGxYXwNHdV1/s1600/arsenal-25-26-home-kit%20%2812%29.jpg',
        category: 'Football',
        description: 'Official Arsenal FC home kit for 2025/26 season',
        colors: ['Red', 'White'],
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        stock: 38,
      ),
      Product(
        id: '7',
        name: 'Manchester United Kit 25/26',
        price: 17.00,
        imageUrl:
            'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhWVSIO6uKQ37flfuWnVuwjc6XffB7rLTFOMCy7Uer5ABBEsAUTaWruk6iwl-41x80OkUUG_wkxBzMaYGk5tZj_HCt23kK7RW3ElKLLsHiWNEr7t0aHrNi9mFW4TI7uPTB8YdaWxm7io5dWu7GVM3YqnfKlWfxrBW1jCSlQP9rWP8qauDQcGM8m5rCIca0G/s1600/man-utd-25-26-home-kit%20%2823%29.jpg',
        category: 'Football',
        description:
            'Official Manchester United FC home kit for 2025/26 season',
        colors: ['Red', 'White'],
        sizes: ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'],
        stock: 42,
      ),
      Product(
        id: '8',
        name: 'Bayern Munich Kit 25/26',
        price: 17.00,
        imageUrl:
            'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiqngecxdwQEtfypP_LzMHT8JMBYcYTPUBdBvi2UDbqZerjpx_ps-ix0sPyzkLPihdONnM787Zn7bcXOOeUEvvXJ9qx8lQqIyTPB1JeEyDEr_YvtM4Bo08aN8EsuRBEz1PWKgB8wnBe8sKOYsgeep5Y76dOUDLpZ439j6yx2cvACLmaTD9v-kFPVN86ZXwd/s1600/bayern-25-26-home-kit%20%289%29.jpg',
        category: 'Football',
        description: 'Official Bayern Munich home kit for 2025/26 season',
        colors: ['Red', 'White'],
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        stock: 33,
      ),
      Product(
        id: '9',
        name: 'Football Boots',
        price: 120.00,
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80',
        category: 'Football',
        description:
            'Professional football boots with advanced grip technology',
        colors: ['Black', 'White', 'Blue'],
        sizes: ['40', '41', '42', '43', '44', '45'],
        stock: 35,
      ),

      // Basketball Products
      Product(
        id: '10',
        name: 'Basketball Jersey',
        price: 25.00,
        imageUrl:
            'https://images.unsplash.com/photo-1544691371-d076f87f0b9f?w=800&q=80',
        category: 'Basketball',
        description: 'Professional basketball jersey',
        colors: ['Red', 'Blue', 'Black'],
        sizes: ['S', 'M', 'L', 'XL'],
        stock: 40,
      ),
      Product(
        id: '11',
        name: 'Basketball Shoes',
        price: 130.00,
        imageUrl:
            'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800&q=80',
        category: 'Basketball',
        description:
            'High-performance basketball shoes with superior ankle support',
        colors: ['Black', 'White', 'Red'],
        sizes: ['40', '41', '42', '43', '44', '45'],
        stock: 28,
      ),
      Product(
        id: '12',
        name: 'Basketball',
        price: 45.00,
        imageUrl:
            'https://images.unsplash.com/photo-1519861531473-9200262188bf?w=800&q=80',
        category: 'Basketball',
        description: 'Official size basketball for professional play',
        colors: ['Orange'],
        sizes: ['Size 7'],
        stock: 50,
      ),

      // Running Products
      Product(
        id: '13',
        name: 'Running Shoes',
        price: 80.00,
        imageUrl:
            'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=800&q=80',
        category: 'Running',
        description: 'High-performance running shoes with cushioned sole',
        colors: ['Black', 'White', 'Blue'],
        sizes: ['40', '41', '42', '43', '44', '45'],
        stock: 25,
      ),
      Product(
        id: '14',
        name: 'Running Shorts',
        price: 30.00,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpM4OOOCfWOf_bQqEGDqFO-m-RWUw0WZkA0w&s',
        category: 'Running',
        description: 'Lightweight running shorts with moisture-wicking fabric',
        colors: ['Black', 'Grey', 'Blue'],
        sizes: ['S', 'M', 'L', 'XL'],
        stock: 45,
      ),
      Product(
        id: '15',
        name: 'Running Watch',
        price: 150.00,
        imageUrl:
            'https://cdn.thewirecutter.com/wp-content/media/2024/07/gps-running-watch-2048px-1986-2x1-1.jpg?width=2048&quality=75&crop=2:1&auto=webp',
        category: 'Running',
        description: 'GPS running watch with heart rate monitor',
        colors: ['Black', 'White'],
        sizes: ['One Size'],
        stock: 20,
      ),

      // Gym & Fitness Products
      Product(
        id: '16',
        name: 'Gym Shorts',
        price: 20.00,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR0fZ6qd2aJMGeq2AoRr3A3eAZRo2X2fY9ghA&s',
        category: 'Gym & Fitness',
        description: 'Comfortable gym shorts',
        colors: ['Black', 'Grey', 'Blue'],
        sizes: ['S', 'M', 'L', 'XL'],
        stock: 60,
      ),
      Product(
        id: '17',
        name: 'Dumbbells Set',
        price: 180.00,
        imageUrl:
            'https://images.unsplash.com/photo-1638536532686-d610adfc8e5c?w=800&q=80',
        category: 'Gym & Fitness',
        description: 'Adjustable dumbbells set 5-25kg',
        colors: ['Black'],
        sizes: ['5kg', '10kg', '15kg', '20kg', '25kg'],
        stock: 15,
      ),
      Product(
        id: '18',
        name: 'Resistance Bands',
        price: 25.00,
        imageUrl:
            'https://cdn.thewirecutter.com/wp-content/media/2025/01/resistancebands-2048px-00137.jpg?auto=webp&quality=75&width=1024',
        category: 'Gym & Fitness',
        description:
            'Set of 5 resistance bands with different resistance levels',
        colors: ['Multi'],
        sizes: ['Set of 5'],
        stock: 40,
      ),

      // Clothing Products
      Product(
        id: '35',
        name: 'Athletic T-Shirt',
        price: 22.00,
        imageUrl:
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&q=80',
        category: 'Clothing',
        description: 'Moisture-wicking athletic t-shirt',
        colors: ['Black', 'White', 'Grey', 'Blue'],
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        stock: 55,
      ),
      Product(
        id: '36',
        name: 'Sports Jacket',
        price: 65.00,
        imageUrl:
            'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500&h=500&fit=crop',
        category: 'Clothing',
        description: 'Lightweight sports jacket for outdoor activities',
        colors: ['Black', 'Navy', 'Grey'],
        sizes: ['S', 'M', 'L', 'XL'],
        stock: 30,
      ),

      // Shoes Products
      Product(
        id: '37',
        name: 'Training Shoes',
        price: 95.00,
        imageUrl:
            'https://images.contentstack.io/v3/assets/bltbb5996c454cd1f4d/blt5730c4153b198e82/657849d78edb1f989ac40749/asics_blog_hero_desktop_runningvstraining_022521.jpg?format=webp&quality=80',
        category: 'Shoes',
        description: 'Versatile training shoes for cross-training',
        colors: ['Black', 'White', 'Grey'],
        sizes: ['40', '41', '42', '43', '44', '45'],
        stock: 32,
      ),
      Product(
        id: '38',
        name: 'Walking Shoes',
        price: 75.00,
        imageUrl:
            'https://www.legendfootwear.co.uk/cdn/shop/articles/trail_vs_hiking_shoes_ac961a00-04e8-47fb-b3af-8bb5325a0cda.jpg?v=1743510045',
        category: 'Shoes',
        description: 'Comfortable walking shoes with arch support',
        colors: ['Black', 'White', 'Brown'],
        sizes: ['40', '41', '42', '43', '44', '45'],
        stock: 28,
      ),

      // Accessories Products
      Product(
        id: '39',
        name: 'Sports Watch',
        price: 120.00,
        imageUrl:
            'https://m.media-amazon.com/images/I/61iQ0vRLt7L._AC_SL1500_.jpg',
        category: 'Accessories',
        description: 'Smart sports watch with fitness tracking',
        colors: ['Black', 'Silver'],
        sizes: ['One Size'],
        stock: 25,
      ),
      Product(
        id: '40',
        name: 'Gym Bag',
        price: 45.00,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQgj42mxx5xAT160QdFXZQNUues34pEFB257Q&s',
        category: 'Accessories',
        description: 'Large gym bag with multiple compartments',
        colors: ['Black', 'Grey', 'Blue'],
        sizes: ['One Size'],
        stock: 35,
      ),
      Product(
        id: '41',
        name: 'Water Bottle',
        price: 15.00,
        imageUrl:
            'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=500&h=500&fit=crop',
        category: 'Accessories',
        description: 'Insulated water bottle 750ml',
        colors: ['Black', 'White', 'Blue', 'Pink'],
        sizes: ['750ml'],
        stock: 70,
      ),

      // Equipment Products
      Product(
        id: '42',
        name: 'Yoga Mat',
        price: 35.00,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShe19dG4JJgzXrRsJWC45Rbn2Q-J0S_3WK4w&s',
        category: 'Equipment',
        description: 'Premium non-slip yoga mat',
        colors: ['Purple', 'Blue', 'Pink', 'Black'],
        sizes: ['Standard'],
        stock: 40,
      ),
      Product(
        id: '43',
        name: 'Jump Rope',
        price: 18.00,
        imageUrl:
            'https://www.pro-tecathletics.com/wp-content/uploads/2022/04/Premium-Jump-Rope-product-only.jpg',
        category: 'Equipment',
        description: 'Adjustable speed jump rope',
        colors: ['Black', 'Red', 'Blue'],
        sizes: ['One Size'],
        stock: 50,
      ),
      Product(
        id: '44',
        name: 'Kettlebell',
        price: 55.00,
        imageUrl:
            'https://americanbarbell.com/cdn/shop/files/KB-1v2_grande.jpg?v=1698731284',
        category: 'Equipment',
        description: 'Cast iron kettlebell',
        colors: ['Black'],
        sizes: ['8kg', '12kg', '16kg', '20kg'],
        stock: 30,
      ),

      // Nutrition Products
      Product(
        id: '23',
        name: 'Protein Powder',
        price: 100.00,
        imageUrl:
            'https://m.media-amazon.com/images/I/71f+UBXh2vL._AC_UF1000,1000_QL80_.jpg',
        category: 'Nutrition',
        description: 'Optimum Nutrition Gold Standard 100% Whey Protein',
        colors: ['Black'],
        sizes: ['2.3kg', '5kg'],
        stock: 20,
      ),
      Product(
        id: '24',
        name: 'Creatine Monohydrate',
        price: 35.00,
        imageUrl:
            'https://shop.biotechusa.com/cdn/shop/products/100CreatineMonohydrate_Unflav_500g_1l.png?v=1623392653',
        category: 'Nutrition',
        description: 'Pure creatine monohydrate powder for strength and power',
        colors: ['White'],
        sizes: ['300g', '500g', '1kg'],
        stock: 45,
      ),
      Product(
        id: '25',
        name: 'BCAA Supplement',
        price: 45.00,
        imageUrl:
            'https://bpisports.com/cdn/shop/products/1MR-25SERV-RAINBOWICE.jpg?v=1741126687&width=1946',
        category: 'Nutrition',
        description: 'BCAA powder for muscle recovery',
        colors: ['White'],
        sizes: ['400g', '800g'],
        stock: 35,
      ),
      Product(
        id: '26',
        name: 'Multivitamin Tablets',
        price: 25.00,
        imageUrl:
            'https://m.faithful-to-nature.co.za/media/catalog/product/n/e/new_leaf_multivitamin_plus_iron_high_strength_tablets_sku150865_7.jpg',
        category: 'Nutrition',
        description: 'Complete multivitamin supplement for daily nutrition',
        colors: ['Multi'],
        sizes: ['60 Tablets', '120 Tablets'],
        stock: 50,
      ),
      Product(
        id: '27',
        name: 'Vitamin D3',
        price: 18.00,
        imageUrl:
            'https://www.hellenia.co.uk/cdn/shop/files/VIT_D_FRONT_AMAZON_2025_1.jpg?v=1750851730',
        category: 'Nutrition',
        description: 'High-strength Vitamin D3 capsules for bone health',
        colors: ['Clear'],
        sizes: ['60 Capsules', '120 Capsules'],
        stock: 40,
      ),
      Product(
        id: '28',
        name: 'Vitamin C Tablets',
        price: 15.00,
        imageUrl:
            'https://route2health.com/cdn/shop/files/vitamin-c.png?v=1731499075&width=1206',
        category: 'Nutrition',
        description: '1000mg Vitamin C tablets for immune support',
        colors: ['Orange'],
        sizes: ['60 Tablets', '120 Tablets'],
        stock: 55,
      ),
      Product(
        id: '29',
        name: 'Omega-3 Fish Oil',
        price: 30.00,
        imageUrl:
            'https://i5.walmartimages.com/seo/Spring-Valley-Proactive-Support-Omega-3-Mini-from-Fish-Oil-Dietary-Supplement-1000-mg-120-Count_fd5c6b64-5dce-4edf-bcd1-27c7637e8c2d.972350e8369a410542010c04437f23bc.jpeg?odnHeight=768&odnWidth=768&odnBg=FFFFFF',
        category: 'Nutrition',
        description: 'High-quality omega-3 fish oil capsules',
        colors: ['Clear'],
        sizes: ['60 Capsules', '120 Capsules'],
        stock: 38,
      ),
      Product(
        id: '30',
        name: 'Pre-Workout Supplement',
        price: 55.00,
        imageUrl:
            'https://images.unsplash.com/photo-1579722820308-d74e5719bc54?w=800&q=80',
        category: 'Nutrition',
        description: 'Energy-boosting pre-workout powder with caffeine',
        colors: ['Multi'],
        sizes: ['400g', '800g'],
        stock: 30,
      ),
      Product(
        id: '31',
        name: 'Post-Workout Recovery',
        price: 50.00,
        imageUrl:
            'https://outworknutrition.com/cdn/shop/files/Recovery-BS-front-fruit-1500px.jpg?v=1723092993&width=1946',
        category: 'Nutrition',
        description: 'Post-workout recovery blend with protein and carbs',
        colors: ['Multi'],
        sizes: ['500g', '1kg'],
        stock: 32,
      ),
      Product(
        id: '32',
        name: 'Energy Bars',
        price: 28.00,
        imageUrl:
            'https://veloforte.com/cdn/shop/collections/Veloforte___Di_Bosco___Endurance_2x3_d412b128-979c-4e72-b7ab-ed9b6094b5f6.jpg?v=1715339888',
        category: 'Nutrition',
        description: 'Pack of 12 high-protein energy bars',
        colors: ['Multi'],
        sizes: ['12 Pack'],
        stock: 60,
      ),
      Product(
        id: '33',
        name: 'Zinc Supplement',
        price: 20.00,
        imageUrl:
            'https://m.media-amazon.com/images/I/71ilnfQs9gL._AC_UF1000,1000_QL80_.jpg',
        category: 'Nutrition',
        description: 'Zinc tablets for immune system support',
        colors: ['White'],
        sizes: ['60 Tablets', '120 Tablets'],
        stock: 42,
      ),
      Product(
        id: '34',
        name: 'Magnesium Complex',
        price: 22.00,
        imageUrl:
            'https://d11qgm9a5k858y.cloudfront.net/s0vkx3bpm1jd2oja3045dgc62poj',
        category: 'Nutrition',
        description: 'Magnesium supplement for muscle function and recovery',
        colors: ['White'],
        sizes: ['60 Tablets', '120 Tablets'],
        stock: 36,
      ),

      // Outdoor & Adventure Products
      Product(
        id: '45',
        name: 'Hiking Backpack',
        price: 85.00,
        imageUrl:
            'https://m.media-amazon.com/images/I/41ItZYkxAyL._AC_SY1000_.jpg',
        category: 'Outdoor & Adventure',
        description: '30L hiking backpack with rain cover',
        colors: ['Black', 'Green', 'Blue'],
        sizes: ['30L'],
        stock: 25,
      ),
      Product(
        id: '46',
        name: 'Camping Tent',
        price: 150.00,
        imageUrl:
            'https://images.thdstatic.com/productImages/d1e19663-3a6e-4607-9bb7-469b22141bdb/svn/camping-tents-y-ww-eds3-64_600.jpg',
        category: 'Outdoor & Adventure',
        description: '2-person camping tent',
        colors: ['Green', 'Blue'],
        sizes: ['2 Person'],
        stock: 15,
      ),

      // Yoga & Wellness Products
      Product(
        id: '47',
        name: 'Yoga Block',
        price: 12.00,
        imageUrl:
            'https://cdn11.bigcommerce.com/s-zu9c0wie59/images/stencil/original/products/705/5062/Sunshine-Yoga-4-Yoga-Block-4-x-6-x-9_3457__03832.1740764216.jpg?c=2',
        category: 'Yoga & Wellness',
        description: 'Foam yoga block for support',
        colors: ['Purple', 'Blue', 'Pink'],
        sizes: ['Standard'],
        stock: 45,
      ),
      Product(
        id: '48',
        name: 'Meditation Cushion',
        price: 40.00,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGWraBMGbTAj1EncQ-4Ku0UYhH7F1z6JkUGg&s',
        category: 'Yoga & Wellness',
        description: 'Comfortable meditation cushion',
        colors: ['Purple', 'Blue', 'Beige'],
        sizes: ['Standard'],
        stock: 30,
      ),

      // Kids & Youth Products
      Product(
        id: '49',
        name: 'Kids Football Kit',
        price: 25.00,
        imageUrl:
            'https://ckl.uk.com/wp-content/uploads/2017/10/TFKK01-main.jpg',
        category: 'Kids & Youth',
        description: 'Football kit for kids',
        colors: ['Red', 'Blue', 'Green'],
        sizes: ['XS', 'S', 'M'],
        stock: 40,
      ),
      Product(
        id: '50',
        name: 'Kids Basketball',
        price: 20.00,
        imageUrl:
            'https://www.edinburghleisure.co.uk/wp-content/smush-webp/2025/01/Chris-Watt-Photography_151-scaled.jpg.webp',
        category: 'Kids & Youth',
        description: 'Size 5 basketball for kids',
        colors: ['Orange'],
        sizes: ['Size 5'],
        stock: 35,
      ),

      // Boxing & Combat Products
      Product(
        id: '51',
        name: 'Boxing Gloves',
        price: 65.00,
        imageUrl:
            'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?w=800&q=80',
        category: 'Boxing & Combat',
        description: 'Professional boxing gloves',
        colors: ['Red', 'Black', 'Blue'],
        sizes: ['12oz', '14oz', '16oz'],
        stock: 28,
      ),
      Product(
        id: '52',
        name: 'Punching Bag',
        price: 120.00,
        imageUrl:
            'https://i5.walmartimages.com/asr/c6c3aaea-785f-49e2-85e3-071c05f41a93.f2aa8f57a2325ca577bbef2638b691e0.jpeg?odnHeight=768&odnWidth=768&odnBg=FFFFFF',
        category: 'Boxing & Combat',
        description: 'Heavy-duty punching bag',
        colors: ['Black', 'Red'],
        sizes: ['50kg', '70kg'],
        stock: 12,
      ),

      // Deals & Collections Products
      Product(
        id: '53',
        name: 'Sports Bundle Pack',
        price: 150.00,
        imageUrl:
            'https://m.media-amazon.com/images/I/81eIyoE1EJL._AC_UF1000,1000_QL80_.jpg',
        category: 'Deals & Collections',
        description: 'Complete sports bundle: shirt, shorts, and shoes',
        colors: ['Multi'],
        sizes: ['M', 'L', 'XL'],
        stock: 20,
      ),
      Product(
        id: '54',
        name: 'Fitness Starter Kit',
        price: 200.00,
        imageUrl:
            'https://www.gymwarehouse.co.uk/wp-content/uploads/2015/05/Commercial-Gym-Starter-Pack-Gymwarehouse.jpg',
        category: 'Deals & Collections',
        description:
            'Everything you need to start: mat, weights, resistance bands',
        colors: ['Multi'],
        sizes: ['Starter Kit'],
        stock: 15,
      ),
    ];
  }
}
