import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

// Features
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

// Services
import '../../shared/services/permissions_service.dart';
import '../../shared/services/security_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthCubit(
      authRepository: sl(),
      signInUseCase: sl(),
      signUpUseCase: sl(),
      getCurrentUserUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  //! External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  //! Services
  sl.registerLazySingleton(() => PermissionsService());
  sl.registerLazySingleton(() => SecurityService());
}
