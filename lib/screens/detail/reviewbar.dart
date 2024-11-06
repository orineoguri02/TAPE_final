import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Rating extends StatefulWidget {
  final String collectionName;
  final String id;
  final Map<String, String> ratingFields;

  const Rating({
    super.key,
    required this.collectionName,
    required this.id,
    required this.ratingFields,
  });

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _textController = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final Map<String, int> _ratings = {};
  String _profileImageUrl = '';
  String _nickname = '';

  @override
  void initState() {
    super.initState();
    _initializeRatings();
    _loadUserProfile();
    _loadUserNickname();
  }

  void _initializeRatings() {
    widget.ratingFields.forEach((key, _) => _ratings[key] = 0);
  }

  Future<void> _loadUserProfile() async {
    var userData =
        await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
    setState(() => _profileImageUrl = userData['image'] ?? '');
  }

  Future<void> _loadUserNickname() async {
    var userData =
        await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
    setState(() => _nickname = userData['nickname'] ?? '');
  }

  void _submitReview() async {
    if (_ratings.values.every((rating) => rating > 0)) {
      if (await _hasAlreadyReviewed()) {
        _showSnackBar('이미 리뷰를 작성했습니다!');
        return;
      }

      Map<String, dynamic> reviewData = {
        'userId': userId,
        'review': _textController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'parentCollection': widget.collectionName,
        ..._ratings,
      };

      await _firestore
          .collection(widget.collectionName)
          .doc(widget.id)
          .collection('ratings')
          .add(reviewData);

      _showSnackBar('리뷰가 저장되었습니다!');
      _resetForm();
    } else {
      _showSnackBar('모든 항목의 별점을 선택하세요!');
    }
  }

  Future<bool> _hasAlreadyReviewed() async {
    var review = await _firestore
        .collection(widget.collectionName)
        .doc(widget.id)
        .collection('ratings')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return review.docs.isNotEmpty;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetForm() {
    setState(() {
      _ratings.updateAll((key, value) => 0);
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('리뷰 작성')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Row(
              children: [
                _buildProfileImage(),
                SizedBox(width: 15),
                Text(_nickname, style: TextStyle(fontSize: 18))
              ],
            ),
            SizedBox(height: 25),
            ..._buildRatingFields(),
            _buildReviewTextField(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitReview();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/finish1.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SizedBox(
                  width: 330,
                  height: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 30,
      backgroundImage:
          _profileImageUrl.isNotEmpty ? NetworkImage(_profileImageUrl) : null,
      child: _profileImageUrl.isEmpty ? Icon(Icons.person) : null,
    );
  }

  List<Widget> _buildRatingFields() {
    return widget.ratingFields.entries.map((entry) {
      return Padding(
        padding: EdgeInsets.only(left: 4, right: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.value, style: TextStyle(fontSize: 17)),
                Row(
                  children: List.generate(
                    5,
                    (index) {
                      return IconButton(
                        icon: Icon(
                          index < _ratings[entry.key]!
                              ? Icons.star
                              : Icons.star_border,
                          color: Color(0xff4863E0),
                        ),
                        iconSize: 28,
                        onPressed: () =>
                            setState(() => _ratings[entry.key] = index + 1),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildReviewTextField() {
    return Column(
      children: [
        SizedBox(height: 40),
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: '이곳에 다녀온 경험을 자세히 공유해주세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xff4863E0), width: 1.5),
            ),
            labelStyle: TextStyle(color: Colors.grey),
          ),
          maxLines: null,
          minLines: 5,
          cursorColor: Color(0xff4863E0),
        ),
        SizedBox(height: 40),
      ],
    );
  }
}

class ReviewList extends StatelessWidget {
  final String collectionName;
  final String id;

  const ReviewList({super.key, required this.collectionName, required this.id});

  Future<Map<String, String>> _getUserInfo(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return {
      'name': userDoc.exists ? userDoc['nickname'] ?? '익명' : '익명',
      'imageUrl': userDoc.exists ? userDoc['image'] ?? '' : '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .doc(id)
          .collection('ratings')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('오류가 발생했습니다'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) =>
              _buildReviewItem(snapshot.data!.docs[index]),
        );
      },
    );
  }

  Widget _buildReviewItem(DocumentSnapshot doc) {
    var reviewData = doc.data() as Map<String, dynamic>?;
    if (reviewData == null) return ListTile(title: Text('리뷰 데이터를 불러올 수 없습니다.'));

    return FutureBuilder<Map<String, String>>(
      future: _getUserInfo(reviewData['userId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(title: Text('로딩 중...'));
        }
        if (snapshot.hasError) return ListTile(title: Text('오류 발생'));

        String userName = snapshot.data?['name'] ?? '익명';
        String userImageUrl = snapshot.data?['imageUrl'] ?? '';
        String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

        return Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundImage: userImageUrl.isNotEmpty
                        ? NetworkImage(userImageUrl)
                        : null,
                    child: userImageUrl.isEmpty ? Icon(Icons.person) : null,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      userName,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  if (reviewData['userId'] == currentUserId)
                    IconButton(
                      onPressed: () async {
                        await doc.reference.delete();
                      },
                      icon: Icon(Icons.delete_outline),
                    ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  _buildRatingStars(reviewData),
                  _buildRatingDetails(reviewData),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(reviewData['review'] ?? '리뷰 내용 없음'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingStars(Map<String, dynamic> reviewData) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < (reviewData['총별점'] ?? 0) ? Icons.star : Icons.star_border,
          color: Color(0xff4863E0),
          size: 20,
        );
      }),
    );
  }

  Widget _buildRatingDetails(Map<String, dynamic> reviewData) {
    return Wrap(
      children: reviewData.entries
          .where((e) => ![
                'userId',
                'review',
                'timestamp',
                '총별점',
                'parentCollection'
              ].contains(e.key))
          .map((e) => Container(
                constraints: BoxConstraints(maxWidth: 70),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${e.key}: ${e.value}',
                  style: TextStyle(fontSize: 14),
                ),
              ))
          .toList(),
    );
  }
}

class ReviewPage extends StatefulWidget {
  final String collectionName;
  final String id;
  final Map<String, String> ratingFields;

  const ReviewPage({
    super.key,
    required this.collectionName,
    required this.id,
    required this.ratingFields,
  });

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() => _profileImageUrl = userData['image'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: _profileImageUrl.isNotEmpty
                  ? NetworkImage(_profileImageUrl)
                  : null,
              child: _profileImageUrl.isEmpty ? Icon(Icons.person) : null,
            ),
            SizedBox(width: 15),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Rating(
                    collectionName: widget.collectionName,
                    id: widget.id,
                    ratingFields: widget.ratingFields,
                  ),
                ),
              ),
              child: SizedBox(
                width: 130,
                height: 30,
                child: Image.asset('assets/rating1.png'),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: ReviewList(
            //작성화면
            collectionName: widget.collectionName,
            id: widget.id,
          ),
        ),
      ],
    );
  }
}
