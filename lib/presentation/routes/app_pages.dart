import 'package:smart_bus/presentation/pages/home/home_page.dart';
import 'package:smart_bus/presentation/shared_controller/home/home_controller.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = Paths.HOME;

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    // GetPage(
    //   name: Paths.CURRENT_PRICE,
    //   page: () => const CurrentCurrencyPricePage(),
    //   middlewares: [CoreMiddleware()],
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut<CurrentCurrencyPriceController>(
    //         CurrentCurrencyPriceController.new);
    //   }),
    //   children: [
    //     GetPage(
    //       name: Paths.CURRENCY_REPORT,
    //       page: () => const CurrencyReportPage(),
    //       binding: BindingsBuilder(() {
    //         Get.lazyPut<CurrencyReportController>(
    // CurrencyReportController.new);
    //       }),
    //     ),
    //   ],
    // ),
    GetPage(
        name: Paths.HOME,
        page: HomePage.new,
        // middlewares: [CoreMiddleware()],
        binding: BindingsBuilder(() {
          Get.lazyPut<HomeController>(HomeController.new);
        })),
  ];
}
