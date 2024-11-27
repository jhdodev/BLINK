import 'package:get_it/get_it.dart';
import 'features/navigation/presentation/bloc/navigation_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => NavigationBloc());
}
