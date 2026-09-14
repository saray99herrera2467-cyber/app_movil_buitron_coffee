import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class AuthService {
  // =========================================================
  // CLIENTE SUPABASE
  // =========================================================

  static SupabaseClient get _supabase => ApiService.supabase;

  // =========================================================
  // HASH DE CONTRASEÑA PARA LA TABLA usuario
  // =========================================================

  static String _hashClave(String clave) {
    final bytes = utf8.encode(clave);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // =========================================================
  // REGISTRAR USUARIO
  // =========================================================

  static Future<Map<String, dynamic>> registrar({
    required String nombreUsuario,
    required String apellido,
    required String correo,
    required String clave,
    String? documento,
    String? telefono,
    String? direccion,
  }) async {
    try {
      final correoNormalizado = correo.trim().toLowerCase();

      // -------------------------------------------------------
      // Verificar teléfono duplicado
      // -------------------------------------------------------

      if (telefono != null && telefono.trim().isNotEmpty) {
        final existeTel = await _supabase
            .from(ApiService.tablaUsuarios)
            .select('id')
            .eq('telefono', telefono.trim())
            .maybeSingle();

        if (existeTel != null) {
          throw Exception(
            'El número telefónico ya está en uso.',
          );
        }
      }

      // -------------------------------------------------------
      // Crear usuario en Supabase Auth
      //
      // Esto utiliza la plantilla:
      // Authentication > Email Templates > Confirm signup
      // -------------------------------------------------------

      final AuthResponse authRes =
      await _supabase.auth.signUp(
        email: correoNormalizado,
        password: clave,
        data: {
          'nombre_usuario': nombreUsuario,
          'apellido': apellido,
          'documento': documento,
          'telefono': telefono,
          'direccion': direccion,
        },
      );

      if (authRes.user == null) {
        throw Exception(
          'No se pudo crear el usuario en Supabase Auth.',
        );
      }

      // -------------------------------------------------------
      // Crear usuario en nuestra tabla usuario
      // -------------------------------------------------------

      final respuesta = await _supabase
          .from(ApiService.tablaUsuarios)
          .insert({
        'nombre_usuario': nombreUsuario,
        'apellido': apellido,
        'correo': correoNormalizado,
        'documento': documento ?? '',
        'telefono': telefono ?? '',
        'direccion': direccion ?? '',
        'clave': _hashClave(clave),
        'id_rol': 1,

        // Se activa después de verificar el código.
        'estado': false,
      })
          .select()
          .single();

      return respuesta;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception(
          'El correo o documento ya está registrado.',
        );
      }

      throw Exception(
        'Error en la base de datos: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // =========================================================
  // RECUPERAR CONTRASEÑA
  // =========================================================
  //
  // IMPORTANTE:
  // NO usamos auth.resend() aquí.
  //
  // resetPasswordForEmail() es el método correcto para
  // solicitar nuevamente el correo de recuperación.
  //
  // Supabase utilizará:
  // Authentication > Email Templates > Reset password
  //
  // Esa plantilla debe contener:
  //
  // {{ .Token }}
  //
  // =========================================================

  static Future<void> recuperarClave(String email) async {
    final correo = email.trim().toLowerCase();

    if (correo.isEmpty) {
      throw Exception(
        'Ingresa tu correo electrónico.',
      );
    }

    try {
      await _supabase.auth.resetPasswordForEmail(
        correo,
      );
    } on AuthException catch (e) {
      final mensaje = e.message.toLowerCase();

      if (mensaje.contains('rate limit') ||
          mensaje.contains('60 seconds') ||
          mensaje.contains('after 60') ||
          mensaje.contains('too many')) {
        throw Exception(
          'Debes esperar 60 segundos antes de solicitar '
              'otro código.',
        );
      }

      throw Exception(
        'No se pudo solicitar la recuperación: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Error al solicitar recuperación: $e',
      );
    }
  }

  // =========================================================
  // ACTUALIZAR CONTRASEÑA
  // =========================================================
  //
  // Este método se ejecuta DESPUÉS de verificar el código
  // de recuperación.
  //
  // verifyOTP con OtpType.recovery establece la sesión.
  // =========================================================

  static Future<void> actualizarClave(
      String nuevaClave,
      ) async {
    if (nuevaClave.trim().isEmpty) {
      throw Exception(
        'La contraseña no puede estar vacía.',
      );
    }

    try {
      // -------------------------------------------------------
      // Comprobar sesión de recuperación
      // -------------------------------------------------------

      final session = _supabase.auth.currentSession;

      if (session == null) {
        throw Exception(
          'La sesión de recuperación no está activa. '
              'Solicita nuevamente el código.',
        );
      }

      // -------------------------------------------------------
      // Actualizar contraseña en Supabase Auth
      // -------------------------------------------------------

      final respuesta = await _supabase.auth.updateUser(
        UserAttributes(
          password: nuevaClave,
        ),
      );

      if (respuesta.user == null) {
        throw Exception(
          'No se pudo actualizar la contraseña.',
        );
      }

      // -------------------------------------------------------
      // Actualizar también la contraseña de nuestra tabla
      // usuario
      // -------------------------------------------------------

      final correo =
          _supabase.auth.currentUser?.email;

      if (correo != null) {
        await _supabase
            .from(ApiService.tablaUsuarios)
            .update({
          'clave': _hashClave(nuevaClave),
        })
            .eq(
          'correo',
          correo.trim().toLowerCase(),
        );
      }
    } on AuthException catch (e) {
      throw Exception(
        'Error de autenticación: ${e.message}',
      );
    } on PostgrestException catch (e) {
      throw Exception(
        'La contraseña de la tabla no pudo actualizarse: '
            '${e.message}',
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // =========================================================
  // VERIFICAR CÓDIGO OTP
  // =========================================================
  //
  // REGISTRO:
  // OtpType.email
  //
  // RECUPERACIÓN:
  // OtpType.recovery
  //
  // =========================================================

  static Future<void> verificarCodigo(
      String email,
      String token, {
        bool esRecuperacion = false,
      }) async {
    final correo = email.trim().toLowerCase();
    final codigo = token.trim();

    // -------------------------------------------------------
    // Validar código
    // -------------------------------------------------------

    if (codigo.length != 6) {
      throw Exception(
        'El código debe tener 6 dígitos.',
      );
    }

    if (!RegExp(r'^\d{6}$').hasMatch(codigo)) {
      throw Exception(
        'El código solo puede contener números.',
      );
    }

    try {
      // -----------------------------------------------------
      // Verificar OTP
      // -----------------------------------------------------

      final AuthResponse respuesta =
      await _supabase.auth.verifyOTP(
        email: correo,
        token: codigo,
        type: esRecuperacion
            ? OtpType.recovery
            : OtpType.email,
      );

      // -----------------------------------------------------
      // Comprobar usuario
      // -----------------------------------------------------

      if (respuesta.user == null) {
        throw Exception(
          'No se pudo verificar el código.',
        );
      }

      // -----------------------------------------------------
      // REGISTRO
      // -----------------------------------------------------
      //
      // Solo en registro cambiamos estado a true.
      //
      // En recuperación NO modificamos estado.
      // -----------------------------------------------------

      if (!esRecuperacion) {
        await _supabase
            .from(ApiService.tablaUsuarios)
            .update({
          'estado': true,
        })
            .eq(
          'correo',
          correo,
        );
      }

      // -----------------------------------------------------
      // RECUPERACIÓN
      // -----------------------------------------------------
      //
      // verifyOTP con OtpType.recovery establece la sesión
      // que posteriormente utilizará actualizarClave().
      // -----------------------------------------------------
    } on AuthException catch (e) {
      final mensaje = e.message.toLowerCase();

      if (mensaje.contains('expired') ||
          mensaje.contains('invalid') ||
          mensaje.contains('otp_expired') ||
          mensaje.contains('token has expired')) {
        throw Exception(
          'El código es inválido o ya expiró. '
              'Solicita un código nuevo.',
        );
      }

      throw Exception(
        'Error al verificar el código: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // =========================================================
  // REENVIAR CÓDIGO
  // =========================================================
  //
  // REGISTRO:
  // auth.resend(OtpType.email)
  //
  // RECUPERACIÓN:
  // resetPasswordForEmail()
  //
  // =========================================================

  static Future<void> reenviarCodigo(
      String email, {
        bool esRecuperacion = false,
      }) async {
    final correo = email.trim().toLowerCase();

    if (correo.isEmpty) {
      throw Exception(
        'El correo electrónico es obligatorio.',
      );
    }

    try {
      // -------------------------------------------------------
      // RECUPERACIÓN
      // -------------------------------------------------------

      if (esRecuperacion) {
        await _supabase.auth.resetPasswordForEmail(
          correo,
        );
      }

      // -------------------------------------------------------
      // REGISTRO
      // -------------------------------------------------------

      else {
        await _supabase.auth.resend(
          type: OtpType.email,
          email: correo,
        );
      }
    } on AuthException catch (e) {
      final mensaje = e.message.toLowerCase();

      if (mensaje.contains('60 seconds') ||
          mensaje.contains('rate limit') ||
          mensaje.contains('too many') ||
          mensaje.contains('after 60')) {
        throw Exception(
          'Por favor espera 60 segundos antes '
              'de solicitar otro código.',
        );
      }

      throw Exception(
        'Error al reenviar: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Error inesperado al reenviar: $e',
      );
    }
  }

  // =========================================================
  // INICIAR SESIÓN
  // =========================================================

  static Future<Map<String, dynamic>> login({
    required String correo,
    required String clave,
  }) async {
    final correoNormalizado =
    correo.trim().toLowerCase();

    // -------------------------------------------------------
    // Intentar iniciar sesión mediante Supabase Auth
    // -------------------------------------------------------

    try {
      final AuthResponse authRes =
      await _supabase.auth.signInWithPassword(
        email: correoNormalizado,
        password: clave,
      );

      if (authRes.user != null) {
        final respuesta = await _supabase
            .from(ApiService.tablaUsuarios)
            .select()
            .eq(
          'correo',
          correoNormalizado,
        )
            .maybeSingle();

        if (respuesta != null) {
          await _guardarSesionLocal(
            correoNormalizado,
            respuesta['id_rol'] ?? 1,
          );

          return respuesta;
        }
      }
    } catch (e) {
      debugPrint(
        'Supabase Auth falló, intentando rescate por tabla: $e',
      );
    }

    // -------------------------------------------------------
    // MODO RESCATE
    // -------------------------------------------------------

    try {
      final claveHasheada =
      _hashClave(clave);

      final respuesta = await _supabase
          .from(ApiService.tablaUsuarios)
          .select()
          .eq(
        'correo',
        correoNormalizado,
      )
          .eq(
        'clave',
        claveHasheada,
      )
          .eq(
        'estado',
        true,
      )
          .maybeSingle();

      if (respuesta != null) {
        await _guardarSesionLocal(
          correoNormalizado,
          respuesta['id_rol'] ?? 1,
        );

        return respuesta;
      }
    } catch (e) {
      debugPrint(
        'Rescate por tabla falló: $e',
      );
    }

    throw Exception(
      'Correo o contraseña incorrectos.',
    );
  }

  // =========================================================
  // GUARDAR SESIÓN LOCAL
  // =========================================================

  static Future<void> _guardarSesionLocal(
      String correo,
      int rol,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      'usuario_correo',
      correo,
    );

    await prefs.setInt(
      'usuario_rol',
      rol,
    );
  }

  // =========================================================
  // CERRAR SESIÓN
  // =========================================================

  static Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      'usuario_correo',
    );

    await prefs.remove(
      'usuario_rol',
    );
  }

  // =========================================================
  // OBTENER PERFIL ACTUAL
  // =========================================================

  static Future<Map<String, dynamic>?>
  obtenerPerfilActual() async {
    final user =
        _supabase.auth.currentUser;

    if (user == null || user.email == null) {
      return null;
    }

    try {
      final respuesta = await _supabase
          .from(ApiService.tablaUsuarios)
          .select()
          .eq(
        'correo',
        user.email!,
      )
          .maybeSingle();

      return respuesta;
    } catch (e) {
      debugPrint(
        'Error al obtener perfil por token: $e',
      );

      return null;
    }
  }

  // =========================================================
  // OBTENER TODOS LOS USUARIOS
  // =========================================================

  static Future<List<dynamic>>
  obtenerTodosUsuarios() async {
    try {
      return await _supabase
          .from(ApiService.tablaUsuarios)
          .select()
          .order(
        'id',
        ascending: true,
      );
    } catch (e) {
      debugPrint(
        'Error obteniendo usuarios: $e',
      );

      rethrow;
    }
  }

  // =========================================================
  // OBTENER CORREO DE SESIÓN
  // =========================================================

  static Future<String?>
  obtenerCorreoSesion() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getString(
      'usuario_correo',
    );
  }

  // =========================================================
  // OBTENER ID DE SESIÓN
  // =========================================================

  static Future<int?> obtenerIdSesion() async {
    final correo =
    await obtenerCorreoSesion();

    if (correo == null) {
      return null;
    }

    try {
      final res = await _supabase
          .from(ApiService.tablaUsuarios)
          .select('id')
          .eq(
        'correo',
        correo,
      )
          .maybeSingle();

      return res?['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  // =========================================================
  // OBTENER USUARIO POR ID
  // =========================================================

  static Future<Map<String, dynamic>>
  obtenerUsuario(
      int usuarioId,
      ) async {
    final respuesta = await _supabase
        .from(ApiService.tablaUsuarios)
        .select()
        .eq(
      'id',
      usuarioId,
    )
        .single();

    return respuesta;
  }
}