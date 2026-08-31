import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'api_service.dart';

class AuthService {
  static final _supabase = ApiService.supabase;

  // Convierte la contraseña en un hash SHA-256 (no se guarda en texto plano)
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
  }) async {
    try {
      final correoNormalizado = correo.trim().toLowerCase();

      // Verificar si el correo ya existe (GET)
      final existe = await _supabase
          .from(ApiService.tablaUsuarios)
          .select('id')
          .eq('correo', correoNormalizado)
          .maybeSingle();

      if (existe != null) {
        throw Exception('El correo ya está registrado');
      }

      // Insertar nuevo usuario (con contraseña hasheada)(POST)
      final respuesta = await _supabase
          .from(ApiService.tablaUsuarios)
          .insert({
        'nombre_usuario': nombreUsuario,
        'apellido': apellido,
        'correo': correoNormalizado,
        'documento': documento ?? '',
        'telefono': telefono ?? '',
        'clave': _hashClave(clave), // ya no se guarda en texto plano
        'id_rol': 2, // 2 = Usuario normal
        'estado': true,
      })
          .select()
          .single();

      return respuesta;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Iniciar sesión (GET)
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
          .eq('clave', claveHasheada) // compara hash contra hash
          .eq('estado', true)
          .maybeSingle();

      if (respuesta == null) {
        throw Exception('Correo o contraseña incorrectos');
      }

      return respuesta;
    } catch (e) {
      throw Exception('Usuario o contraseña incorrectos');
    }
  }

  // Obtener datos del usuario por ID (GET)
  static Future<Map<String, dynamic>> obtenerUsuario(int usuarioId) async {
    final respuesta = await _supabase
        .from(ApiService.tablaUsuarios)
        .select()
        .eq('id', usuarioId)
        .single();
    return respuesta;
  }
}