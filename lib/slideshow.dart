import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Slideshow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SlideshowState();
  }
}

class SlideshowState extends State<Slideshow> {
  final PageController ctrl = PageController(viewportFraction: 0.8);

  final Firestore db = Firestore.instance;
  Stream slides;

  String activeTag = 'us';

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _queryDb();

    ctrl.addListener(() {
      int next = ctrl.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: slides,
      initialData: [],
      builder: (context, AsyncSnapshot snap) {
        List slideList = snap.data.toList();

        return PageView.builder(
          controller: ctrl,
          itemCount: slideList.length + 1,
          itemBuilder: (context, int currentIdx) {
            if (currentIdx == 0) {
              return _buildTagPage();
            } else if (slideList.length >= currentIdx) {
              // Active page
              bool active = currentIdx == currentPage;
              return _buildStoryPage(slideList[currentIdx - 1], active);
            }
          },
        );
      },
    );
  }

  void _queryDb({String tag = 'us'}) {
    Query query = db.collection('stories').where('tags', arrayContains: tag);

    slides =
        query.snapshots().map((list) => list.documents.map((doc) => doc.data));

    setState(() {
      activeTag = tag;
    });
  }

  _buildStoryPage(Map data, bool active) {
    // Animated Properties
    final double blur = active ? 30 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 100 : 200;

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(top: top, bottom: 50, right: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(data['img']),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black87,
              blurRadius: blur,
              offset: Offset(offset, offset))
        ],
      ),
      child: Center(
        child: Text(
          data['title'],
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 40, color: Colors.white),
        ),
      ),
    );
  }

  _buildTagPage() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Happy B\'day Babe',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text('FILTER', style: TextStyle(color: Colors.black26)),
        _buildButton('us'),
        _buildButton('dates yayy'),
        _buildButton('only you')
      ],
    ));
  }

  _buildButton(tag) {
    Color color = tag == activeTag ? Colors.purple : Colors.white;
    return FlatButton(
        color: color,
        child: Text(
          '#$tag',
        ),
        onPressed: () => _queryDb(tag: tag));
  }
}
