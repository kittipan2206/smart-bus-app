import 'package:get/get.dart';
import 'package:smart_bus/globals.dart';

class CoreMiddleware extends GetMiddleware {
  @override
  GetPage? onPageCalled(GetPage? page) {
    logger.i(page?.name);
    return super.onPageCalled(page);
  }
}
