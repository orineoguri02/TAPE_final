import 'package:flutter/material.dart';

class Cos extends StatefulWidget {
  Cos({super.key});
  @override
  _CosState createState() => _CosState();
}

class _CosState extends State<Cos> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Menu Example'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '내 코스'),
            Tab(text: '다른 사람의 코스'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.blue),
                        onPressed: () {
                          // Add button action
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '내 코스 만들기',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '새로운 코스를 만들고 떠나보세요',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '이전 코스',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: [
                      CustomListTile(
                        title: '성수동데이트',
                        subtitle: '2024.8.29',
                      ),
                      // Add more ListTiles here
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: '원하는 장소를 검색해보세요',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        CustomListTile(
                          title: '성수동 데이트',
                          subtitle: '2024.9.10',
                        ),
                        CustomListTile(
                          title: '성수동 데이트',
                          subtitle: '2024.9.11',
                        ),
                        // Add more ListTiles here
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String title;
  final String subtitle;

  CustomListTile({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.edit),
          SizedBox(width: 10),
          Icon(Icons.delete),
        ],
      ),
    );
  }
}
