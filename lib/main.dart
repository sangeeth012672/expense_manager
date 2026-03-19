import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/theme.dart';
import 'utils/notification_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/sync_repository.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/category_bloc.dart';
import 'blocs/category_event.dart';
import 'blocs/transaction_bloc.dart';
import 'blocs/transaction_event.dart';
import 'blocs/sync_bloc.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService().init();
  
  final client = http.Client();
  final authRepository = AuthRepository(client: client);
  final categoryRepository = CategoryRepository(authRepository: authRepository);
  final transactionRepository = TransactionRepository(authRepository: authRepository);
  final syncRepository = SyncRepository(
     client: client,
     authRepository: authRepository,
     categoryRepository: categoryRepository,
     transactionRepository: transactionRepository,
  );

  runApp(MyApp(
    authRepository: authRepository,
    categoryRepository: categoryRepository,
    transactionRepository: transactionRepository,
    syncRepository: syncRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final SyncRepository syncRepository;

  const MyApp({
    super.key, 
    required this.authRepository,
    required this.categoryRepository,
    required this.transactionRepository,
    required this.syncRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: categoryRepository),
        RepositoryProvider.value(value: transactionRepository),
        RepositoryProvider.value(value: syncRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc(authRepository: authRepository)..add(CheckAuthStatus())),
          BlocProvider(create: (context) => CategoryBloc(repository: categoryRepository)..add(LoadCategories())),
          BlocProvider(create: (context) => TransactionBloc(repository: transactionRepository)..add(LoadTransactions())),
          BlocProvider(create: (context) => SyncBloc(syncRepository: syncRepository)),
        ],
        child: MaterialApp(
          title: 'Expense Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
