import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/detail/reviewbar.dart';

class Myreview extends StatefulWidget {
  final String collectionName;
  final String id;

  const Myreview({
    super.key,
    required this.collectionName,
    required this.id,
  });

  @override
  State<Myreview> createState() => _MyreviewState();
}

class _MyreviewState extends State<Myreview> {
  final List<String> collections = [
    'cafe',
    'restaurant',
    'park',
    'display',
    'play'
  ];
  int selectedIndex = 0; // 선택된 카테고리 인덱스

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리뷰 카테고리 선택')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(collections.length, (index) {
              return ChoiceChip(
                label: Text(_getChipLabel(index)), // 각 카테고리의 라벨을 표시
                selected: selectedIndex == index,
                onSelected: (bool selected) {
                  setState(() {
                    selectedIndex = index; // 선택된 인덱스 업데이트
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildSelectedContent(),
          ),
        ],
      ),
    );
  }

  // 카테고리에 따른 레이블 반환 함수
  String _getChipLabel(int index) {
    switch (index) {
      case 0:
        return '카페';
      case 1:
        return '식당';
      case 2:
        return '공원';
      case 3:
        return '전시';
      case 4:
        return '공연';
      default:
        return '';
    }
  }

  // 선택된 카테고리에 따라 다른 콘텐츠 표시
  Widget _buildSelectedContent() {
    if (widget.collectionName.isNotEmpty && widget.id.isNotEmpty) {
      return ReviewList(
        collectionName: collections[selectedIndex], // 선택된 카테고리의 컬렉션 이름 전달
        id: widget.id,
      );
    } else {
      return Center(
        child: Text(
          '${_getChipLabel(selectedIndex)} 관련 리뷰가 없습니다.',
        ),
      );
    }
  }
}
