import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static SupabaseClient get _supabase => ApiService.supabase;

  // Convierte la contraseña en un hash SHA-256
  static String _hashClave(String clave) {
    final bytes = utf8.encode(clave);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Registrar nuevo usuario en Supabase Auth y en la tabla usuario
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

      // 1. Verificar duplicados manuales en la tabla usuario (Teléfono)
      if (telefono != null && telefono.isNotEmpty) {
        final existeTel = await _supabase
            .from(ApiService.tablaUsuarios)
            .select('id')
            .eq('telefono', telefono.trim())
            .maybeSingle();

        if (existeTel != null) {
          throw Exception('El número telefónico ya está en uso');
        }
      }

      // 2. Registrar en Supabase Auth (esto dispara el correo de confirmación)
      final AuthResponse authRes = await _supabase.auth.signUp(
        email: correoNormalizado,
        password: clave, // Supabase Auth maneja su propio hasheo
        data: {
          'nombre_usuario': nombreUsuario,
          'apellido': apellido,
          'documento': documento,
          'telefono': telefono,
          'direccion': direccion,
        },
      );

      if (authRes.user == null) {
        throw Exception('No se pudo crear el usuario en el servicio de autenticación');
      }

      // 3. Insertar en la tabla 'usuario' para mantener compatibilidad con el resto de la app
      final respuesta = await _supabase
          .from(ApiService.tablaUsuarios)
          .insert({
        'nombre_usuario': nombreUsuario,
        'apellido': apellido,
        'correo': correoNormalizado,
        'documento': documento ?? '',
        'telefono': telefono ?? '',
        'direccion': direccion ?? '', 
        'clave': _hashClave(clave), // Mantenemos el hash manual solo para la tabla si es necesario
        'id_rol': 1, 
        'estado': true, // ✅ Activo por defecto mientras se arregla el correo
      }).select().single();

      return respuesta;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('El correo o documento ya está registrado');
      }
      throw Exception('Error en la base de datos: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Enviar correo para restablecer contraseña
  static Future<void> recuperarClave(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        // Opcional: redirectTo: 'io.supabase.buitroncoffee://reset-password',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al solicitar recuperación: $e');
    }
  }

  // Actualizar contraseña (usado tras recuperación por email)
  static Future<void> actualizarClave(String nuevaClave) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: nuevaClave),
      );
      
      // Opcional: También actualizar en la tabla usuario si manejas hash manual ahí
      final correo = _supabase.auth.currentUser?.email;
      if (correo != null) {
        await _supabase
            .from(ApiService.tablaUsuarios)
            .update({'clave': _hashClave(nuevaClave)})
            .eq('correo', correo);
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al actualizar la contraseña: $e');
    }
  }

  // Verificar el código OTP enviado al correo
  static Future<void> verificarCodigo(String email, String token) async {
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );

      // Si la verificación es exitosa, activamos al usuario en la tabla
      await _supabase
          .from(ApiService.tablaUsuarios)
          .update({'estado': true})
          .eq('correo', email.toLowerCase().trim());

    } on AuthException catch (e) {
      throw Exception('Código inválido o expirado: ${e.message}');
    } catch (e) {
      throw Exception('Error al verificar: $e');
    }
  }

  // Reenviar el código de verificación al correo
  static Future<void> reenviarCodigo(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email.trim().toLowerCase(),
      );
    } on AuthException catch (e) {
      if (e.message.contains('60 seconds')) {
        throw Exception('Por favor espera un minuto antes de reenviar el código.');
      }
      throw Exception('Error al reenviar: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al reenviar: $e');
    }
  }

  // Iniciar sesión (Híbrido: Supabase Auth -> Fallback a Tabla usuario)
  static Future<Map<String, dynamic>> login({
    required String correo,
    required String clave,
  }) async {
    final correoNormalizado = correo.trim().toLowerCase();
    
    try {
      // 1. Intentar sesión en Supabase Auth (Método moderno)
      final AuthResponse authRes = await _supabase.auth.signInWithPassword(
        email: correoNormalizado,
        password: clave,
      );

      if (authRes.user != null) {
        // Si el usuario existe en Auth, verificamos sus datos adicionales en la tabla
        final respuesta = await _supabase
            .from(ApiService.tablaUsuarios)
            .select()
            .eq('correo', correoNormalizado)
            .maybeSingle();

        if (respuesta != null) {
          await _guardarSesionLocal(correoNormalizado, respuesta['id_rol'] ?? 1);
          return respuesta;
        }
      }
    } catch (e) {
      // Si falla Supabase Auth (por no estar confirmado o no existir), probamos el RESCATE
      debugPrint('Supabase Auth falló, intentando rescate por tabla: $e');
    }

    // 2. MODO RESCATE: Validar directamente contra la tabla 'usuario' (Método antiguo)
    try {
      final claveHasheada = _hashClave(clave);
      final respuesta = await _supabase
          .from(ApiService.tablaUsuarios)
          .select()
          .eq('correo', correoNormalizado)
          .eq('clave', claveHasheada)
          .maybeSingle();

      if (respuesta != null) {
        await _guardarSesionLocal(correoNormalizado, respuesta['id_rol'] ?? 1);
        return respuesta;
      }
    } catch (e) {
      debugPrint('Rescate por tabla falló: $e');
    }

    throw Exception('Correo o contraseña incorrectos');
  }

  // Helper para guardar sesión
  static Future<void> _guardarSesionLocal(String correo, int rol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario_correo', correo);
    await prefs.setInt('usuario_rol', rol);
  }

  // Cerrar sesión local
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_correo');
    await prefs.remove('usuario_rol');
  }

  // Obtener todos los usuarios (para el administrador)
  static Future<List<dynamic>> obtenerTodosUsuarios() async {
    try {
      return await _supabase
          .from(ApiService.tablaUsuarios)
          .select()
          .order('id', ascending: true);
    } catch (e) {
      debugPrint('Error obteniendo usuarios: $e');
      rethrow;
    }
  }

  // Obtener correo de la sesión guardada
  static Future<String?> obtenerCorreoSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_correo');
  }

  // Obtener ID del usuario de la sesión guardada
  static Future<int?> obtenerIdSesion() async {
    final correo = await obtenerCorreoSesion();
    if (correo == null) return null;

    try {
      final res = await _supabase
          .from(ApiService.tablaUsuarios)
          .select('id')
          .eq('correo', correo)
          .maybeSingle();
      
      return res?['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  // Obtener datos del usuario por ID
  static Future<Map<String, dynamic>> obtenerUsuario(int usuarioId) async {
    final respuesta = await _supabase
        .from(ApiService.tablaUsuarios)
        .select()
        .eq('id', usuarioId)
        .single();
    return respuesta;
  }
}