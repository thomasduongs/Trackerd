import 'package:flutter/material.dart';
import 'package:trackerd_app/app/navigation/app_router.dart';
import 'theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scrollController = ScrollController();
  bool _scrolled = false;
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final next = _scrollController.offset > 56; // threshold
      if (next != _scrolled) setState(() => _scrolled = next);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 50,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Start a new session',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.sessionInput),
                icon: const Icon(Icons.add, size: 30, color: AppColors.primary),
              ),
            ],
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOut,
              opacity: _scrolled ? 1.0 : 0.0,
              child: const Text(
                'Workout Tracker',
                style: TextStyle(fontSize: 16),
              ),
            ),
            flexibleSpace: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: _scrolled ? AppColors.bar : AppColors.background,
                border: Border(
                  bottom: BorderSide(
                    color: _scrolled ? AppColors.search : AppColors.background,
                    width: .8,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 5, 15, 15),
              child: Text(
                'Workout Tracker',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text('Recent Sessions', style: TextStyle(fontSize: 24)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
            sliver: SliverToBoxAdapter(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: List.generate(5, (index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text('$index'),
                            subtitle: Text('data'),
                            subtitleTextStyle: TextStyle(
                              color: AppColors.mutedText,
                            ),
                            tileColor: Colors.transparent,
                            onTap: () => null,
                          ),
                          Divider(
                            height: 0.8,
                            color: index == 4
                                ? Colors.transparent
                                : AppColors.search,
                            endIndent: 56,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text('Stats', style: TextStyle(fontSize: 24)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
            sliver: SliverToBoxAdapter(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Container(height: 50, child: Text('data'));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.search, // your border color
                width: 0.8,
              ),
            ),
          ),
          child: BottomAppBar(
            color: AppColors.bar,
            child: Column(
              children: [
                Text('Workouts'),
                Text(
                  '${months[DateTime.now().month - 1]} ${DateTime.now().day}, ${DateTime.now().year}',
                  style: TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
