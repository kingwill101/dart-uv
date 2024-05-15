// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

final class addrinfo extends ffi.Struct {
  @ffi.Int()
  external int ai_flags;

  @ffi.Int()
  external int ai_family;

  @ffi.Int()
  external int ai_socktype;

  @ffi.Int()
  external int ai_protocol;

  @socklen_t()
  external int ai_addrlen;

  external ffi.Pointer<sockaddr> ai_addr;

  external ffi.Pointer<ffi.Char> ai_canonname;

  external ffi.Pointer<addrinfo> ai_next;
}

typedef addrinfo_t = addrinfo;

typedef socklen_t = __socklen_t;
typedef __socklen_t = ffi.UnsignedInt;
typedef Dart__socklen_t = int;

final class sockaddr extends ffi.Struct {
  @sa_family_t()
  external int sa_family;

  @ffi.Array.multi([14])
  external ffi.Array<ffi.Char> sa_data;
}

typedef sa_family_t = ffi.UnsignedShort;
typedef Dartsa_family_t = int;
