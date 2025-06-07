import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/yugioh_card.dart';

class CardImageViewer extends StatefulWidget {
  final YugiohCard card;

  const CardImageViewer({Key? key, required this.card}) : super(key: key);

  @override
  _CardImageViewerState createState() => _CardImageViewerState();
}

class _CardImageViewerState extends State<CardImageViewer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _gyroController;
  
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _rotationZ = 0.0;
  
  bool _isGyroEnabled = true;
  bool _isLoading = true;
  
  StreamSubscription? _gyroSubscription;
  
  // Transform values
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  double _scale = 1.0;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _gyroController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    
    _startGyroscope();
    _animationController.forward();
  }

  void _startGyroscope() {
    // Simulasi gyroscope dengan accelerometer
    // Dalam implementasi nyata, gunakan sensors_plus package
    _simulateGyroscope();
  }
  
  void _simulateGyroscope() {
    // Simulasi pergerakan gyroscope untuk demo
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!mounted || !_isGyroEnabled) {
        timer.cancel();
        return;
      }
      
      // Simulasi data gyroscope (dalam implementasi nyata, gunakan sensor data)
      final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final simulatedX = math.sin(time * 0.5) * 0.3;
      final simulatedY = math.cos(time * 0.3) * 0.2;
      
      setState(() {
        _tiltX = simulatedX;
        _tiltY = simulatedY;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gyroController.dispose();
    _gyroSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGyroEnabled ? Icons.screen_rotation : Icons.screen_lock_rotation,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isGyroEnabled = !_isGyroEnabled;
                if (!_isGyroEnabled) {
                  _tiltX = 0.0;
                  _tiltY = 0.0;
                }
              });
              
              HapticFeedback.lightImpact();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isGyroEnabled ? 'Gyro Effect Enabled' : 'Gyro Effect Disabled'
                  ),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showCardInfo(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Center(
            child: GestureDetector(
              onScaleStart: (details) {
                _animationController.stop();
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = math.max(0.5, math.min(3.0, details.scale));
                });
              },
              onScaleEnd: (details) {
                if (_scale < 1.0) {
                  setState(() {
                    _scale = 1.0;
                  });
                }
              },
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateX(_isGyroEnabled ? _tiltX : 0.0)
                  ..rotateY(_isGyroEnabled ? _tiltY : 0.0)
                  ..scale(_scale),
                child: Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: Offset(
                          _isGyroEnabled ? _tiltY * 10 : 0,
                          _isGyroEnabled ? _tiltX * 10 : 5,
                        ),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: AspectRatio(
                      aspectRatio: 0.7, // Rasio kartu Yu-Gi-Oh standar
                      child: Stack(
                        children: [
                          // Background gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.purple.withOpacity(0.1),
                                  Colors.blue.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                          
                          // Card image
                          if (widget.card.cardImages.isNotEmpty)
                            Image.network(
                              widget.card.cardImages.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  _isLoading = false;
                                  return child;
                                }
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: Colors.purple,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Loading card image...',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 64,
                                        color: Colors.white54,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          
                          // Holographic effect overlay
                          if (_isGyroEnabled)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(_tiltY, _tiltX),
                                    end: Alignment(-_tiltY, -_tiltX),
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                    stops: [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.card.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoChip('Type', widget.card.type),
                if (widget.card.level != null)
                  _buildInfoChip('Level', widget.card.level.toString()),
                if (widget.card.atk != null)
                  _buildInfoChip('ATK', widget.card.atk.toString()),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Pinch to zoom • Tilt phone for 3D effect',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showCardInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.card.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (widget.card.desc.isNotEmpty) ...[
              Text(
                'Description:',
                style: TextStyle(
                  color: Colors.purple[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.card.desc,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
