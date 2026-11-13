import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'app/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(MdmApp(router: createAppRouter()));
}
