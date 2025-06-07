import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/yugioh_card.dart';

class CardViewerScreen extends StatefulWidget {
  final YugiohCard card;
  final String imageUrl;

  const CardViewerScreen({
    Key? key,
    required this.card,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _CardViewerScreenState createState() => _CardViewerScreenState();
}

class _CardViewerScreenState extends State<CardViewerScreen> {
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  bool _useGyroscope = true;

  @override
  void initState() {
    super.initState();
    _startListeningGyroscope();
  }

  void _startListeningGyroscope() {
    if (_useGyroscope) {
      _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
        setState(() {
          // Membatasi rotasi maksimum sekitar 15 derajat
          _rotationX = (_rotationX + event.y * 0.05).clamp(-0.25, 0.25);
          _rotationY = (_rotationY - event.x * 0.05).clamp(-0.25, 0.25);
        });
      });
    } else if (_gyroscopeSubscription != null) {
      _gyroscopeSubscription!.cancel();
      _gyroscopeSubscription = null;
    }
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.card.name,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _useGyroscope ? Icons.screen_rotation : Icons.screen_rotation_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _useGyroscope = !_useGyroscope;
                if (_useGyroscope) {
                  _startListeningGyroscope();
                } else {
                  _gyroscopeSubscription?.cancel();
                  _gyroscopeSubscription = null;
                  _rotationX = 0;
                  _rotationY = 0;
                }
              });
            },
            tooltip: _useGyroscope ? 'Disable gyroscope effect' : 'Enable gyroscope effect',
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: _useGyroscope ? null : (details) {
          setState(() {
            _rotationY = (_rotationY + details.delta.dx / 100).clamp(-0.25, 0.25);
            _rotationX = (_rotationX + details.delta.dy / 100).clamp(-0.25, 0.25);
          });
        },
        child: Center(
          child: Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspektif
              ..rotateX(_rotationX)
              ..rotateY(_rotationY),
            child: Hero(
              tag: 'card_image_${widget.card.id}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 300,
                        height: 400,
                        color: Colors.grey[800],
                        child: Center(
                          child: Icon(Icons.error, size: 50, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
