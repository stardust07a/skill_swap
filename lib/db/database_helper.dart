import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/skill.dart';
import '../models/message.dart';
import '../models/request.dart';
import '../models/review.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('skill_swap.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ad TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        sifre TEXT NOT NULL,
        sehir TEXT NOT NULL,
        ilce TEXT NOT NULL,
        bio TEXT DEFAULT '',
        isAdmin INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE skills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        beceriAdi TEXT NOT NULL,
        tip TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gonderenId INTEGER NOT NULL,
        aliciId INTEGER NOT NULL,
        metin TEXT NOT NULL,
        tarih TEXT NOT NULL,
        FOREIGN KEY (gonderenId) REFERENCES users (id),
        FOREIGN KEY (aliciId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gonderenId INTEGER NOT NULL,
        aliciId INTEGER NOT NULL,
        tip TEXT NOT NULL,
        durum TEXT DEFAULT 'bekliyor',
        mesaj TEXT DEFAULT '',
        tarih TEXT NOT NULL,
        FOREIGN KEY (gonderenId) REFERENCES users (id),
        FOREIGN KEY (aliciId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        yazanId INTEGER NOT NULL,
        hedefId INTEGER NOT NULL,
        puan INTEGER NOT NULL,
        yorum TEXT DEFAULT '',
        tarih TEXT NOT NULL,
        FOREIGN KEY (yazanId) REFERENCES users (id),
        FOREIGN KEY (hedefId) REFERENCES users (id)
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // Demo kullanıcılar
    final now = DateTime.now().toIso8601String();

    await db.insert('users', {
      'ad': 'Ahmet Yılmaz',
      'email': 'ahmet@skillswap.com',
      'sifre': '123456',
      'sehir': 'İstanbul',
      'ilce': 'Kadıköy',
      'bio': 'Full-stack geliştirici. Kod ve React öğretiyorum!',
      'isAdmin': 0,
    });

    await db.insert('users', {
      'ad': 'Selin Kaya',
      'email': 'selin@skillswap.com',
      'sifre': '123456',
      'sehir': 'İstanbul',
      'ilce': 'Kadıköy',
      'bio': 'Müzisyen. Gitar ve müzik teorisi öğretiyorum.',
      'isAdmin': 0,
    });

    await db.insert('users', {
      'ad': 'Merve Demir',
      'email': 'merve@skillswap.com',
      'sifre': '123456',
      'sehir': 'İstanbul',
      'ilce': 'Beşiktaş',
      'bio': 'İngilizce öğretmeni. Yoga öğrenmek istiyorum.',
      'isAdmin': 0,
    });

    await db.insert('users', {
      'ad': 'Kerem Şahin',
      'email': 'kerem@skillswap.com',
      'sifre': '123456',
      'sehir': 'İstanbul',
      'ilce': 'Şişli',
      'bio': 'Yoga eğitmeni. İngilizce öğrenmek istiyorum.',
      'isAdmin': 0,
    });

    await db.insert('users', {
      'ad': 'Deniz Arslan',
      'email': 'deniz@skillswap.com',
      'sifre': '123456',
      'sehir': 'İzmir',
      'ilce': 'Konak',
      'bio': 'Ressam. Müzik öğrenmek istiyorum.',
      'isAdmin': 0,
    });

    await db.insert('users', {
      'ad': 'Admin',
      'email': 'admin@skillswap.com',
      'sifre': '123456',
      'sehir': 'İstanbul',
      'ilce': 'Kadıköy',
      'bio': 'Platform yöneticisi.',
      'isAdmin': 1,
    });

    // Beceriler – Ahmet (id=1)
    await db.insert('skills', {'userId': 1, 'beceriAdi': 'Kod', 'tip': 'ogretir'});
    await db.insert('skills', {'userId': 1, 'beceriAdi': 'React', 'tip': 'ogretir'});
    await db.insert('skills', {'userId': 1, 'beceriAdi': 'Gitar', 'tip': 'ogrenir'});

    // Beceriler – Selin (id=2)
    await db.insert('skills', {'userId': 2, 'beceriAdi': 'Gitar', 'tip': 'ogretir'});
    await db.insert('skills', {'userId': 2, 'beceriAdi': 'Müzik', 'tip': 'ogretir'});
    await db.insert('skills', {'userId': 2, 'beceriAdi': 'Kod', 'tip': 'ogrenir'});

    // Beceriler – Merve (id=3)
    await db.insert('skills', {'userId': 3, 'beceriAdi': 'İngilizce', 'tip': 'ogretir'});
    await db.insert('skills', {'userId': 3, 'beceriAdi': 'Yoga', 'tip': 'ogrenir'});

    // Beceriler – Kerem (id=4)
    await db.insert('skills', {'userId': 4, 'beceriAdi': 'Yoga', 'tip': 'ogretir'});
    await db.insert('skills', {'userId': 4, 'beceriAdi': 'İngilizce', 'tip': 'ogrenir'});

    // Beceriler – Deniz (id=5)
    await db.insert('skills', {'userId': 5, 'beceriAdi': 'Resim', 'tip': 'ogretir'});
    await db.insert('skills', {'userId': 5, 'beceriAdi': 'Müzik', 'tip': 'ogrenir'});

    // Demo mesajlar
    await db.insert('messages', {
      'gonderenId': 2,
      'aliciId': 1,
      'metin': 'Merhaba! React öğrenmek istiyorum, ders verir misin?',
      'tarih': now,
    });
    await db.insert('messages', {
      'gonderenId': 1,
      'aliciId': 2,
      'metin': 'Tabii ki! Gitar takas yapalım mı?',
      'tarih': now,
    });

    // Demo talepler
    await db.insert('requests', {
      'gonderenId': 2,
      'aliciId': 1,
      'tip': 'takas',
      'durum': 'bekliyor',
      'mesaj': 'Gitar vs React takası yapalım!',
      'tarih': now,
    });
    await db.insert('requests', {
      'gonderenId': 3,
      'aliciId': 4,
      'tip': 'takas',
      'durum': 'kabul',
      'mesaj': 'İngilizce vs Yoga takas teklifi',
      'tarih': now,
    });

    // Demo yorumlar
    await db.insert('reviews', {
      'yazanId': 2,
      'hedefId': 1,
      'puan': 5,
      'yorum': 'Ahmet çok iyi bir öğretmen, React\'i çok iyi anlattı!',
      'tarih': now,
    });
    await db.insert('reviews', {
      'yazanId': 3,
      'hedefId': 4,
      'puan': 4,
      'yorum': 'Kerem yoga konusunda çok bilgili.',
      'tarih': now,
    });
  }

  // ─── USER ─────────────────────────────────────────────────────────────────

  Future<User?> loginUser(String email, String sifre) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND sifre = ?',
      whereArgs: [email, sifre],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return maps.isNotEmpty;
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((m) => User.fromMap(m)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ─── SKILL ────────────────────────────────────────────────────────────────

  Future<int> insertSkill(Skill skill) async {
    final db = await database;
    return await db.insert('skills', skill.toMap());
  }

  Future<List<Skill>> getSkillsByUser(int userId) async {
    final db = await database;
    final maps = await db.query('skills', where: 'userId = ?', whereArgs: [userId]);
    return maps.map((m) => Skill.fromMap(m)).toList();
  }

  Future<int> deleteSkill(int id) async {
    final db = await database;
    return await db.delete('skills', where: 'id = ?', whereArgs: [id]);
  }

  // ─── MESSAGE ──────────────────────────────────────────────────────────────

  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getMessagesBetween(int userId1, int userId2) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: '(gonderenId = ? AND aliciId = ?) OR (gonderenId = ? AND aliciId = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'id ASC',
    );
    return maps.map((m) => Message.fromMap(m)).toList();
  }

  Future<List<int>> getConversationPartners(int userId) async {
    final db = await database;
    final sent = await db.query(
      'messages',
      columns: ['aliciId'],
      where: 'gonderenId = ?',
      whereArgs: [userId],
      distinct: true,
    );
    final received = await db.query(
      'messages',
      columns: ['gonderenId'],
      where: 'aliciId = ?',
      whereArgs: [userId],
      distinct: true,
    );
    final ids = <int>{};
    for (var m in sent) ids.add(m['aliciId'] as int);
    for (var m in received) ids.add(m['gonderenId'] as int);
    return ids.toList();
  }

  // ─── REQUEST ──────────────────────────────────────────────────────────────

  Future<int> insertRequest(SwapRequest request) async {
    final db = await database;
    return await db.insert('requests', request.toMap());
  }

  Future<List<SwapRequest>> getRequestsForUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'requests',
      where: 'gonderenId = ? OR aliciId = ?',
      whereArgs: [userId, userId],
      orderBy: 'id DESC',
    );
    return maps.map((m) => SwapRequest.fromMap(m)).toList();
  }

  Future<int> updateRequestStatus(int id, String durum) async {
    final db = await database;
    return await db.update('requests', {'durum': durum}, where: 'id = ?', whereArgs: [id]);
  }

  // ─── REVIEW ───────────────────────────────────────────────────────────────

  Future<int> insertReview(Review review) async {
    final db = await database;
    return await db.insert('reviews', review.toMap());
  }

  Future<List<Review>> getReviewsForUser(int userId) async {
    final db = await database;
    final maps = await db.query('reviews', where: 'hedefId = ?', whereArgs: [userId], orderBy: 'id DESC');
    return maps.map((m) => Review.fromMap(m)).toList();
  }

  Future<bool> hasReviewed(int yazanId, int hedefId) async {
    final db = await database;
    final maps = await db.query(
      'reviews',
      where: 'yazanId = ? AND hedefId = ?',
      whereArgs: [yazanId, hedefId],
    );
    return maps.isNotEmpty;
  }

  Future<double> getAverageRating(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(puan) as avg FROM reviews WHERE hedefId = ?',
      [userId],
    );
    return (result.first['avg'] as num?)?.toDouble() ?? 0.0;
  }

  // ─── MATCH ALGORITHM ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMatches(int currentUserId) async {
    final allUsers = await getAllUsers();
    final mySkills = await getSkillsByUser(currentUserId);
    final currentUser = await getUserById(currentUserId);
    if (currentUser == null) return [];

    final myTeach = mySkills.where((s) => s.tip == 'ogretir').map((s) => s.beceriAdi.toLowerCase()).toSet();
    final myLearn = mySkills.where((s) => s.tip == 'ogrenir').map((s) => s.beceriAdi.toLowerCase()).toSet();

    final List<Map<String, dynamic>> results = [];

    for (final user in allUsers) {
      if (user.id == currentUserId) continue;
      if (user.isAdmin) continue;

      final theirSkills = await getSkillsByUser(user.id!);
      final theirTeach = theirSkills.where((s) => s.tip == 'ogretir').map((s) => s.beceriAdi.toLowerCase()).toSet();
      final theirLearn = theirSkills.where((s) => s.tip == 'ogrenir').map((s) => s.beceriAdi.toLowerCase()).toSet();

      int score = 0;

      // Onlar benim öğrenmek istediğimi öğretiyor mu?
      for (final l in myLearn) {
        if (theirTeach.contains(l)) {
          score += 40;
          break;
        }
      }

      // Ben onların öğrenmek istediğini öğretiyor muyum?
      for (final l in theirLearn) {
        if (myTeach.contains(l)) {
          score += 40;
          break;
        }
      }

      // Konum bonusları
      if (currentUser.sehir.toLowerCase() == user.sehir.toLowerCase()) score += 10;
      if (currentUser.ilce.toLowerCase() == user.ilce.toLowerCase()) score += 10;

      // Karşılıklı takas mümkün mü?
      bool karsilikli = false;
      for (final l in myLearn) {
        if (theirTeach.contains(l)) karsilikli = true;
      }
      for (final l in theirLearn) {
        if (myTeach.contains(l)) karsilikli = true;
      }
      if (karsilikli) score += 10;

      if (score > 0) {
        results.add({
          'user': user,
          'score': score.clamp(0, 100),
          'skills': theirSkills,
        });
      }
    }

    results.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return results;
  }
}
