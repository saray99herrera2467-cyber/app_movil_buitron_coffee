import 'dart:convert';
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

  // Registrar nuevo usuario
  static Future<Map<String, dynamic>> registrar({
    required String nombreUsuario,
    required String apellido,
    required String correo,
    required String clave,
    String? documento,
    String? telefono,
    String? direccion, // ✅ Nuevo campo
  }) async {
    try {
      final correoNormalizado = correo.trim().toLowerCase();

      // Verificar si el correo ya existe
      final existe = await _supabase
          .from(ApiService.tablaUsuarios)
          .select('id')
          .eq('correo', correoNormalizado)
          .maybeSingle();

      if (existe != null) {
        throw Exception('El correo ya está registrado');
      }

      // Insertar nuevo usuario con TODOS los campos
      // Generar un documento ficticio si no se proporciona para evitar errores de restricción
      final documentoFinal = documento ?? 'DOC-${DateTime.now().millisecondsSinceEpoch}';

      final respuesta = await _supabase
          .from(ApiService.tablaUsuarios)
          .insert({
        'nombre_usuario': nombreUsuario,
        'apellido': apellido,
        'correo': correoNormalizado,
        'documento': documentoFinal,
        'telefono': telefono ?? '',
        'direccion': direccion ?? '', 
        'clave': _hashClave(clave),
        'id_rol': 1, // Por defecto Rol Usuario
        'estado': true,
      }).select().single();

      // ✅ Guardar sesión local tras registro exitoso
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario_correo', correoNormalizado);
      await prefs.setInt('usuario_rol', 1);

      return respuesta;
    } on PostgrestException catch (e) {
      // Errores específicos de base de datos
      if (e.code == '23505') {
        throw Exception('El correo o documento ya está registrado');
      }
      throw Exception('Error en la base de datos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }

  // Iniciar sesión
  static Future<Map<String, dynamic>> login({
    required String correo,
    required String clave,
  }) async {
    try {
      final correoNormalizado = correo.trim().toLowerCase();
      final claveHasheada = _hashClave(clave);

      final respuesta = await _supabase
          .from(ApiService.tablaUsuarios)
          .select()
          .eq('correo', correoNormalizado)
          .eq('clave', claveHasheada)
          .eq('estado', true)
          .maybeSingle();

      if (respuesta == null) {
        throw Exception('Correo o contraseña incorrectos');
      }

      // ✅ Guardar sesión localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario_correo', correoNormalizado);
      await prefs.setInt('usuario_rol', respuesta['id_rol'] ?? 1);

      return respuesta;
    } catch (e) {
      throw Exception('Usuario o contraseña incorrectos');
    }
  }

  // Cerrar sesión local
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_correo');
    await prefs.remove('usuario_rol');
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