import 'package:flutter/material.dart';
// Import the Flutter Material package, which contains widgets and tools to build a Material Design app.

import 'bp_pulse_form.dart';
// Import your custom form widget from the file 'bp_pulse_form.dart'.
// This file should define the BPPulseForm widget, which will be the main screen of your app.

class BPPulseApp extends StatelessWidget {
  // Define a new widget class called BPPulseApp.
  // It extends StatelessWidget because it doesn't manage any mutable state itself.

  @override
  Widget build(BuildContext context) {
    // The build method describes how to display this widget in terms of other, lower-level widgets.
    // It returns a widget tree.

    return MaterialApp(
      // MaterialApp is a convenience widget that wraps a number of widgets
      // that are commonly required for material design applications.
      // It also provides routing, theming, and more.
      title: 'BP & Pulse Recorder',

      // This is the title of your app.
      // It may be used by the OS to identify the app (e.g., app switcher).
      theme: ThemeData(primarySwatch: Colors.blue),

      // This defines the visual theme of the app.
      // Here, the primary color scheme is set to blue.
      home: BPPulseForm(),
      // The 'home' is the widget for the default route of the app.
      // Here, you set it to your BPPulseForm widget imported above,
      // so this form will be the first screen the user sees.
    );
  }
}
