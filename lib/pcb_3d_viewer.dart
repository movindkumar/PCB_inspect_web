import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web; // <--- 1. CHANGED IMPORT HERE

class PcbDefect3DViewer extends StatefulWidget {
  const PcbDefect3DViewer({super.key});

  @override
  State<PcbDefect3DViewer> createState() => _PcbDefect3DViewerState();
}

class _PcbDefect3DViewerState extends State<PcbDefect3DViewer> {
  // A unique ID for the iframe registry
  final String viewId = 'threejs-pcb-viewer';

  @override
  void initState() {
    super.initState();
    
    // <--- 2. CHANGED 'ui' to 'ui_web' HERE
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) => html.IFrameElement()
        ..width = '100%'
        ..height = '100%'
        // Accesses the HTML file you stored in your assets folder
        ..src = 'pcb_viewer.html' 
        ..style.border = 'none'
        ..style.borderRadius = '12px',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480, 
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF0a0f0a),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Uses Flutter Web's native HTML renderer
      child: HtmlElementView(viewType: viewId),
    );
  }
}