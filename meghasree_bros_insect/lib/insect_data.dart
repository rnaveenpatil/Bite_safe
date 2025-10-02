// insect_data_service.dart

import 'package:meghasree_bros_insect/insectinfo.dart';

class InsectDataService {
  
  Future<List<InsectInfo>> getAllInsects() async {
    // Sample data with more info links
    return [
      InsectInfo(
        name: 'Monarch Butterfly',
        image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        description: 'The Monarch butterfly is a milkweed butterfly in the family Nymphalidae. Other common names include wanderer and black veined brown. It is known for its spectacular long-distance migration.',
        habitat: 'Open fields, meadows, gardens, and along roadsides',
        diet: 'Nectar from flowers, particularly milkweed',
        lifespan: '6-8 months for migrating generation, 2-6 weeks for others',
        facts: [
          'Can migrate up to 3,000 miles from Canada to Mexico',
          'Uses magnetic fields and sun position for navigation',
          'Toxic to predators due to milkweed consumption',
          'Wingspan ranges from 8.9 to 10.2 cm'
        ],
        moreInfoLink: 'https://en.wikipedia.org/wiki/Monarch_butterfly',
      ),
      InsectInfo(
        name: 'Honeybee',
        image: 'https://images.unsplash.com/photo-1576618148400-f54bed99fcfd?w=600',
        description: 'Honeybees are flying insects closely related to wasps and ants, known for their role in pollination and producing honey and beeswax. They live in large colonies with complex social structures.',
        habitat: 'Beehives in hollow trees, rock crevices, or man-made hives',
        diet: 'Nectar and pollen from flowers',
        lifespan: '15-38 days for workers, 2-5 years for queen',
        facts: [
          'A colony can have up to 80,000 bees during peak season',
          'Can fly up to 15 mph and visit 50-100 flowers per trip',
          'Communicate through "waggle dance" to share food locations',
          'Produce about 2.95 million pounds of honey each year in US'
        ],
        moreInfoLink: 'https://en.wikipedia.org/wiki/Honey_bee',
      ),
      // Add more insects here as needed
      InsectInfo(
        name: 'Ladybug',
        image: 'https://images.unsplash.com/photo-1563281577-a7be47e20db9?w=600',
        description: 'Ladybugs are small beetles that are considered beneficial insects because they eat many agricultural pests. They are also known as ladybirds or lady beetles.',
        habitat: 'Gardens, fields, forests, and grasslands worldwide',
        diet: 'Aphids, scale insects, mites, and other soft-bodied insects',
        lifespan: '1-3 years depending on species and environment',
        facts: [
          'Can eat up to 5,000 aphids in their lifetime',
          'There are over 6,000 species worldwide',
          'Hibernate in large groups under rocks or logs',
          'Bright colors warn predators of their bad taste'
        ],
        moreInfoLink: 'https://en.wikipedia.org/wiki/Coccinellidae',
      ),

      InsectInfo(name:"bee",
       image:'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDmAsQAIDxdKdZagnP0LZok5uut2AWlZlG5A&s',
       description: "swdafff",
        habitat: "dsdff",
         diet: "ddsff",
          lifespan: "ddddsd",
           facts: ["ddfddd"],

           ),

InsectInfo(name: "navya ",
image: "https://www.popsci.com/wp-content/uploads/2021/05/18/spider-1555216-scaled.jpg?quality=85&w=2048",
 description: "dswdyag",
  habitat: "bddgg", 
  diet: "jddwd",
   lifespan: "hywd", 
   facts: ["jsd","jndjn"]
   ,
   moreInfoLink: "bsbs"
),




















































































    ];
  }



  // Future methods for adding/editing insects
  Future<void> addInsect(InsectInfo insect) async {
    // Implementation for adding new insects
  }

  Future<void> updateInsect(InsectInfo insect) async {
    // Implementation for updating insects
  }

  Future<void> deleteInsect(String insectName) async {
    // Implementation for deleting insects
  }
}