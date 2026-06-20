import 'package:cloud_firestore/cloud_firestore.dart';
import '../firestore/firestore_service.dart';
import 'package:get_it/get_it.dart';

import '../services/connectivity_service.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

import '../../features/auth/domain/usecases/verify_pin_usecase.dart';
import '../../features/auth/domain/usecases/recover_pin_usecase.dart';

import '../../features/auth/presentation/viewmodels/pin_viewmodel.dart';
import '../../features/auth/presentation/viewmodels/recover_pin_viewmodel.dart';

import '../../features/cotizaciones/data/datasources/cotizacion_local_datasource.dart';
import '../../features/cotizaciones/data/datasources/cotizacion_remote_datasource.dart';
import '../../features/cotizaciones/data/repository/cotizacion_repository_impl.dart';
import '../../features/cotizaciones/domain/repositories/cotizacion_repository.dart';
import '../../features/cotizaciones/presentation/viewmodels/cotizacion_form_viewmodel.dart';
import '../../features/cotizaciones/presentation/viewmodels/historial_cotizaciones_viewmodel.dart';

import '../../features/clientes/data/datasources/client_local_datasource.dart';
import '../../features/clientes/data/datasources/client_remote_datasource.dart';
import '../../features/clientes/data/repositories/client_repository_impl.dart';
import '../../features/clientes/domain/repositories/client_repository.dart';
import '../../features/clientes/presentation/viewmodels/client_viewmodel.dart';
import '../../features/clientes/presentation/viewmodels/client_form_viewmodel.dart';
import '../../features/clientes/presentation/viewmodels/clientes_paginados_viewmodel.dart';

import '../../features/configuracion/data/datasources/local_settings_datasource.dart';
import '../../features/configuracion/data/repositories/settings_repository_impl.dart';
import '../../features/configuracion/domain/repositories/settings_repository.dart';

import '../../features/auth/data/datasources/pin_security_service.dart';

import '../../features/configuracion/presentation/viewmodels/settings_viewmodel.dart';
import '../../features/configuracion/services/backup_service.dart';

final sl = GetIt.instance;

void setupDI() {
  //Connectivity
  sl.registerLazySingleton(
    () => ConnectivityService(),
  );

  // Firebase
  sl.registerLazySingleton(
    () => FirebaseFirestore.instance,
  );

  sl.registerLazySingleton(
    () => FirestoreService(sl()),
  );

  //Auth
  sl.registerLazySingleton(
    () => PinSecurityService(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(securityService: sl()),
  );

  // Use cases
  sl.registerLazySingleton<VerifyPinUsecase>(
    () => VerifyPinUsecase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<RecoverPinUsecase>(
    () => RecoverPinUsecase(sl<AuthRepository>()),
  );

  // ViewModels
  sl.registerFactory<PinViewModel>(
    () => PinViewModel(
      verifyPinUsecase: sl<VerifyPinUsecase>(),
      pinSecurityService: sl<PinSecurityService>(),
    ),
  );

  sl.registerFactory<RecoverPinViewModel>(
    () => RecoverPinViewModel(
      recoverPinUsecase: sl<RecoverPinUsecase>(),
    ),
  );

  //Cotizaciones
  //Datasources

  sl.registerLazySingleton(
    () => CotizacionLocalDatasource(sl()),
  );

  sl.registerLazySingleton(
    () => CotizacionRemoteDatasource(sl()),
  );

  //Repository

  sl.registerLazySingleton<CotizacionRepository>(
    () => CotizacionRepositoryImp(
      localDatasource: sl(),
      remoteDatasource: sl(),
    ),
  );

  //ViewModels
  sl.registerFactory(
    () => CotizacionFormViewModel(repository: sl()),
  );
  sl.registerFactory(
    () => HistorialCotizacionesViewModel(
      sl<CotizacionRepository>(),
    ),
  );

  //Clientes

  sl.registerLazySingleton(
    () => ClientLocalDatasource(sl()),
  );

  sl.registerLazySingleton(
    () => ClientRemoteDatasource(sl()),
  );

  sl.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl(
      sl<FirestoreService>(),
      sl<ClientRemoteDatasource>(),
    ),
  );

  sl.registerFactory(
    () => ClientViewModel(sl()),
  );

  sl.registerFactory(
    () => ClientFormViewModel(sl()),
  );

  sl.registerFactory(
    () => ClientesPaginadosViewModel(
      sl<ClientRepository>(),
    ),
  );

  // Settings
  sl.registerLazySingleton(
    () => LocalSettingsDatasource(),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDatasource: sl()),
  );

  // ViewModels - Settings
  sl.registerLazySingleton(
    () => SettingsViewModel(
      repository: sl(),
      pinSecurityService: sl(),
    ),
  );

  // Backup Service
  sl.registerLazySingleton<BackupService>(() => BackupService(
        cotizacionRepository: sl(),
        clientRepository: sl(),
      ));
}