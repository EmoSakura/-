import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================================
// 1. 数据模型与全局配置 (Model & Config)
// ============================================================================

const Color kPrimaryColor = Color(0xFFD4AF37); // 赤金
const Color kBackgroundColor = Color(0xFF121212); // 玄色
const Color kCardColor = Color(0xFF1E1E1E);
const Color kTextSecondary = Color(0xFFB0BEC5);

class OliveItem {
  final String id;
  final String title;
  final String description;
  final String era;
  final String imageUrl;
  final String detailImage; // 详情页用更高清图

  OliveItem({
    required this.id,
    required this.title,
    required this.description,
    required this.era,
    required this.imageUrl,
    required this.detailImage,
  });
}

// 更加真实的模拟数据，使用 Unsplash 的高质量图片
final List<OliveItem> mockItems = [
  OliveItem(
    id: '1',
    title: '中华世纪龙舟',
    description: '船身雕刻了楼阁人物，门窗皆可开合。利用乌榄核天然的纺锤形态，将船身拉长，刻画出苏东坡夜游赤壁的宏大场景。船头龙头高昂，船尾凤尾摇曳，中间楼阁两层，窗户竟有芝麻大小且可自由开关。',
    era: '现代 · 大师作',
    imageUrl: 'https://images.unsplash.com/photo-1545657803-c469733405c9?q=80&w=600&auto=format&fit=crop',
    detailImage: 'https://images.unsplash.com/photo-1545657803-c469733405c9?q=80&w=1200&auto=format&fit=crop',
  ),
  OliveItem(
    id: '2',
    title: '十八罗汉',
    description: '在方寸榄核之上，雕刻出十八罗汉神态各异的表情。或喜或悲，或怒或嗔，每一个罗汉的面部表情都仅有米粒大小，却栩栩如生，须眉毕现。',
    era: '清代 · 宫廷藏',
    imageUrl: 'https://images.unsplash.com/photo-1628620888936-e04f2482381f?q=80&w=600&auto=format&fit=crop',
    detailImage: 'https://images.unsplash.com/photo-1628620888936-e04f2482381f?q=80&w=1200&auto=format&fit=crop',
  ),
  OliveItem(
    id: '3',
    title: '松下对弈',
    description: '展现古人闲情逸致，松针细节刻画入微。仿佛能听到松涛阵阵，棋子落盘之声。',
    era: '民国',
    imageUrl: 'https://images.unsplash.com/photo-1534065600685-6c68b72e5050?q=80&w=600&auto=format&fit=crop',
    detailImage: 'https://images.unsplash.com/photo-1534065600685-6c68b72e5050?q=80&w=1200&auto=format&fit=crop',
  ),
  OliveItem(
    id: '4',
    title: '镂空花篮',
    description: '通体镂空，技艺精湛，内层还有可转动的榄核球。',
    era: '现代',
    imageUrl: 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?q=80&w=600&auto=format&fit=crop',
    detailImage: 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?q=80&w=1200&auto=format&fit=crop',
  ),
];

// ============================================================================
// 2. 主入口 (Main)
// ============================================================================

void main() {
  runApp(const OliveCarvingApp());
}

class OliveCarvingApp extends StatelessWidget {
  const OliveCarvingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '榄雕云艺',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackgroundColor,
        primaryColor: kPrimaryColor,
        cardColor: kCardColor,
        useMaterial3: true,
        fontFamily: 'SimSerif', // 尝试使用衬线体，如果没有系统会自动回退
        colorScheme: const ColorScheme.dark(
          primary: kPrimaryColor,
          surface: kCardColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor, letterSpacing: 1.5),
        ),
      ),
      // 桌面端适配：限制最大宽度，让它看起来像个App
      builder: (context, child) {
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 900), // 模拟手机比例
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12, width: 1),
              borderRadius: BorderRadius.circular(20), // 如果是全屏运行Windows可设为0
              boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 20)],
            ),
            child: child,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}

// ============================================================================
// 3. 通用组件 (Common Widgets) - 修复图片加载的核心
// ============================================================================

class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final BoxFit fit;

  const NetworkImageWithFallback({super.key, required this.imageUrl, this.height, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          color: kCardColor,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: kPrimaryColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: const Color(0xFF2A2A2A),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.white24, size: height != null ? height! * 0.3 : 40),
              const SizedBox(height: 8),
              const Text("图片加载失败", style: TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// 4. 启动页 (Splash Screen) - 增加动画
// ============================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeNavScreen()));
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景纹理绘制
          Positioned.fill(child: CustomPaint(painter: BackgroundPatternPainter())),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimaryColor, width: 2),
                        boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 20)],
                      ),
                      child: const Icon(Icons.spa, size: 60, color: kPrimaryColor),
                    ),
                    const SizedBox(height: 30),
                    const Text('榄雕云艺', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8, color: kPrimaryColor)),
                    const SizedBox(height: 10),
                    Text('数字传承 · 匠心独运', style: TextStyle(fontSize: 14, color: kTextSecondary, letterSpacing: 4)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    for (double i = -size.height; i < size.height * 2; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i + size.width), paint); // 斜线纹理
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 5. 导航框架 (Navigation)
// ============================================================================

class HomeNavScreen extends StatefulWidget {
  const HomeNavScreen({super.key});

  @override
  State<HomeNavScreen> createState() => _HomeNavScreenState();
}

class _HomeNavScreenState extends State<HomeNavScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const GalleryScreen(),
    const ProcessScreen(),
    const InteractionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          backgroundColor: kBackgroundColor,
          currentIndex: _currentIndex,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.museum_outlined), activeIcon: Icon(Icons.museum), label: '赏·云阁'),
            BottomNavigationBarItem(icon: Icon(Icons.handyman_outlined), activeIcon: Icon(Icons.handyman), label: '技·工坊'),
            BottomNavigationBarItem(icon: Icon(Icons.fingerprint), activeIcon: Icon(Icons.fingerprint), label: '趣·互动'),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. 数字展馆 (Gallery) - 瀑布流 + Hero动画
// ============================================================================

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数字展馆')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockItems.length,
        itemBuilder: (context, index) {
          final item = mockItems[index];
          // 列表进入动画
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + (index * 100)), // 错峰显示
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildGalleryCard(context, item),
          );
        },
      ),
    );
  }

  Widget _buildGalleryCard(BuildContext context, OliveItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(item: item))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Hero(
                  tag: item.id,
                  child: NetworkImageWithFallback(imageUrl: item.imageUrl, height: 200),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(item.era, style: TextStyle(fontSize: 12, color: kPrimaryColor)),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final OliveItem item;
  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            backgroundColor: Colors.black,
            pinned: true,
            leading: IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.black45, child: Icon(Icons.arrow_back, color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: InteractiveViewer( // 支持双指缩放
                child: Hero(
                  tag: item.id,
                  child: NetworkImageWithFallback(imageUrl: item.detailImage, height: 400),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: kPrimaryColor), borderRadius: BorderRadius.circular(4)),
                    child: Text(item.era, style: TextStyle(color: kPrimaryColor, fontSize: 12)),
                  ),
                  const SizedBox(height: 24),
                  const Text("作品赏析", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(item.description, style: TextStyle(fontSize: 15, height: 1.8, color: kTextSecondary)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ============================================================================
// 7. 工艺解构 (Process) - 视差滚动 & 模拟视频播放
// ============================================================================

class ProcessScreen extends StatefulWidget {
  const ProcessScreen({super.key});

  @override
  State<ProcessScreen> createState() => _ProcessScreenState();
}

class _ProcessScreenState extends State<ProcessScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
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
      body: Stack(
        children: [
          // 1. 视差背景层 (移动速度慢)
          Positioned(
            top: -_scrollOffset * 0.3, // 视差因子
            left: 0, right: 0,
            height: 800,
            child: Image.network(
              'https://images.unsplash.com/photo-1620619767323-b95a89183081?q=80&w=800&auto=format&fit=crop',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.7),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // 2. 内容层
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('技 · 工坊'),
                  centerTitle: true,
                  background: Container(color: Colors.transparent), // 透明以透出背景
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("非遗工序解构", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  _buildProcessStep(1, "选料", "选取乌榄核，质地坚硬为上。", "https://images.unsplash.com/photo-1590845947698-8924d7409b56?q=80&w=400"),
                  _buildProcessStep(2, "开坯", "依形构思，粗略定型。", "https://images.unsplash.com/photo-1618160702438-9b02ab6515c9?q=80&w=400"),
                  _buildProcessStep(3, "精雕", "毫厘之间，刻画入微。", "https://images.unsplash.com/photo-1512413914633-b5043f4041ea?q=80&w=400"),
                  _buildProcessStep(4, "打磨", "细砂去燥，光泽温润。", "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=400"),
                  const SizedBox(height: 100),
                ]),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProcessStep(int index, String title, String desc, String thumbUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor.withOpacity(0.9), // 半透明卡片
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("0$index", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryColor)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: TextStyle(color: kTextSecondary)),
          const SizedBox(height: 16),
          // 模拟视频播放器入口
          MockVideoPlayer(thumbnail: thumbUrl),
        ],
      ),
    );
  }
}

// 模拟视频播放器组件
class MockVideoPlayer extends StatefulWidget {
  final String thumbnail;
  const MockVideoPlayer({super.key, required this.thumbnail});

  @override
  State<MockVideoPlayer> createState() => _MockVideoPlayerState();
}

class _MockVideoPlayerState extends State<MockVideoPlayer> {
  bool isPlaying = false;
  double progress = 0.0;
  Timer? _timer;

  void togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          progress += 0.01;
          if (progress >= 1.0) {
            progress = 0.0;
            isPlaying = false;
            timer.cancel();
          }
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: togglePlay,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: NetworkImage(widget.thumbnail), fit: BoxFit.cover),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(color: Colors.black38), // 遮罩
            if (!isPlaying)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                child: const Icon(Icons.play_arrow, size: 40, color: Colors.white),
              ),
            if (isPlaying)
              const Center(child: CircularProgressIndicator(color: Colors.white54)), // 模拟缓冲/播放中
            
            // 底部进度条
            Positioned(
              bottom: 10, left: 10, right: 10,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isPlaying ? "演示中..." : "点击播放", style: const TextStyle(color: Colors.white, fontSize: 10)),
                      Text("00:${(progress * 10).toInt()}0", style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, color: kPrimaryColor),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 8. 指尖互动 (Interaction) - 粒子特效升级
// ============================================================================

class InteractionScreen extends StatefulWidget {
  const InteractionScreen({super.key});

  @override
  State<InteractionScreen> createState() => _InteractionScreenState();
}

class _InteractionScreenState extends State<InteractionScreen> {
  List<Offset?> points = [];
  List<Offset> particles = []; // 木屑粒子

  void addParticle(Offset pos) {
    if (particles.length > 50) particles.removeAt(0); // 限制数量
    // 随机偏移
    particles.add(pos + Offset(Random().nextDouble() * 20 - 10, Random().nextDouble() * 20 - 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('趣 · 互动'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("换料", style: TextStyle(color: Colors.white)),
            onPressed: () => setState(() { points.clear(); particles.clear(); }),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("按住鼠标/手指滑动进行雕刻", style: TextStyle(color: kTextSecondary)),
            const SizedBox(height: 20),
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  // 支持 Windows 鼠标坐标获取
                  points.add(details.localPosition);
                  // 添加粒子特效
                  if (points.length % 3 == 0) addParticle(details.localPosition);
                });
              },
              onPanEnd: (details) => setState(() => points.add(null)),
              child: Container(
                width: 300,
                height: 550,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E2723), // 乌榄原色
                  borderRadius: BorderRadius.circular(150),
                  gradient: const RadialGradient(colors: [Color(0xFF5D4037), Color(0xFF3E2723)], radius: 0.8),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(150),
                  child: Stack(
                    children: [
                      CustomPaint(painter: CarvingPainter(points), size: Size.infinite),
                      CustomPaint(painter: ParticlePainter(particles), size: Size.infinite),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarvingPainter extends CustomPainter {
  final List<Offset?> points;
  CarvingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD7CCC8) // 雕刻后的浅色内质
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CarvingPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final List<Offset> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF8D6E63)..style = PaintingStyle.fill;
    for (var point in particles) {
      canvas.drawCircle(point, 2.0, paint);
    }
  }
  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}