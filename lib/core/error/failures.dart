import 'package:equatable/equatable.dart';

// 1. CLASE BASE: Todos los errores de negocio deben heredar de esta.
abstract class Failure extends Equatable {
  // El mensaje es opcional pero ayuda para la depuración y UI.
  final String? message; 
  const Failure({this.message});

  @override
  // Equatable simplifica la comparación de objetos (Failure() == Failure()).
  List<Object?> get props => [message]; 
}

// 2. FALLAS DE CONEXIÓN Y TIEMPO DE ESPERA
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = "Verifica tu conexión a Internet."});
}

// 3. FALLAS DE SERVIDOR (Códigos 5xx)
class ServerFailure extends Failure {
  const ServerFailure({super.message = "Error en el servidor. Intenta de nuevo más tarde."});
}

// 4. FALLAS DE ACCESO/AUTENTICACIÓN (Códigos 401, 403)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = "Tu sesión ha expirado o no tienes permisos."});
}

// 5. FALLAS DE DATOS NO ENCONTRADOS (Códigos 404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = "El recurso solicitado no fue encontrado."});
}

// 6. FALLAS DE SOLICITUD INVÁLIDA (Códigos 400)
class BadRequestFailure extends Failure {
  // Útil para errores de validación de formulario retornados por el servidor.
  const BadRequestFailure({required super.message});
}

// 7. FALLAS DE CACHÉ/ALMACENAMIENTO LOCAL
class CacheFailure extends Failure {
  const CacheFailure({super.message = "No se pudo acceder a los datos locales."});
}

// 8. FALLAS DE ANÁLISIS DE DATOS (Mapeo de JSON)
class ParsingFailure extends Failure {
  const ParsingFailure({super.message = "Hubo un error al procesar la información."});
}

// 9. FALLA GENÉRICA O DESCONOCIDA (Catch-all)
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = "Ocurrió un error inesperado."});
}