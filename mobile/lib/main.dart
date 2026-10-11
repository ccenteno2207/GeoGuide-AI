import 'features/tracking/infrastructure/route_session_worker.dart';

import 'package:flutter/widgets.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GeoGuideApp());
}

@pragma("vm:entry-point")
void b1RouteSessionMain() {
  runRouteSessionWorker();
}
